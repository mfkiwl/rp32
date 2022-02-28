///////////////////////////////////////////////////////////////////////////////
// R5P: arithmetic/logic unit (ALU)
///////////////////////////////////////////////////////////////////////////////
// Copyright 2022 Iztok Jeras
//
// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at
//
//     http://www.apache.org/licenses/LICENSE-2.0
//
// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.
///////////////////////////////////////////////////////////////////////////////

import riscv_isa_pkg::*;

module r5p_alu #(
  int unsigned XLEN = 32,
  // timing versus area compromises
  bit          CFG_LSA = 1'b0,   // enable dedicated Load/Store Adder
  bit          CFG_LOM = 1'b0    // enable dedicated Logical Operand Multiplexer
)(
  // system signals
  input  logic            clk,  // clock
  input  logic            rst,  // reset
  // control structure from instruction decode
  input  ctl_t            ctl,
  // data input/output
  input  logic [XLEN-1:0] pc ,  // PC
  input  logic [XLEN-1:0] rs1,  // source register 1
  input  logic [XLEN-1:0] rs2,  // source register 2
  output logic [XLEN-1:0] rd ,  // destination register
  // side ouputs
  output logic [XLEN-0:0] sum   // summation result including overflow bit
);

// logarithm of XLEN
localparam int unsigned XLOG = $clog2(XLEN);

// invert operand 2
logic            inv;

// multiplexed inputs
logic [XLEN-1:0] in1;  // input 1
logic [XLEN-1:0] in2;  // input 2

// arithmetic operands (sign extended by 1 bit)
logic [XLEN-0:0] ao1;  // arithmetic operand 1
logic [XLEN-0:0] ao2;  // arithmetic operand 2

// logical operands
logic [XLEN-1:0] lo1;  // logical operand 1
logic [XLEN-1:0] lo2;  // logical operand 2

// barrel shifter shift ammount
logic [XLOG-1:0] sam;  // multiplexed
logic [XLOG-1:0] sa;

// operation result
logic [XLEN-1:0] val;

///////////////////////////////////////////////////////////////////////////////
// arithmetic operations
///////////////////////////////////////////////////////////////////////////////

// ALU input multiplexer
generate
if (CFG_LSA) begin: gen_lsa_ena

  // load/store address adders are implemented outside the ALU
  // TODO: it appears commenting out the AI_R1_IL line has negative timing/area efec with Xilinx Vivado 2021.2 on Arty
  // NOTE: for Arty enable the AI_R1_IL line
  always_comb
  unique casez (ctl.i.alu.ai)
    AI_R1_R2: begin in1 = rs1; in2 = rs2;              end  // R-type
    AI_R1_II: begin in1 = rs1; in2 = XLEN'(ctl.imm.i); end  // I-type (arithmetic/logic)
  //AI_R1_IL: begin in1 = rs1; in2 = XLEN'(ctl.imm.l); end  // I-type (load)
  //AI_R1_IS: begin in1 = rs1; in2 = XLEN'(ctl.imm.s); end  // S-type (store)
    AI_PC_IU: begin in1 = pc ; in2 = XLEN'(ctl.imm.u); end  // U-type
    AI_PC_IJ: begin in1 = pc ; in2 = XLEN'(ctl.imm.j); end  // J-type (jump)
    AI_R1_R2: begin in1 = rs1; in2 = rs2;              end  // R-type
    AI_R1_RA: begin in1 = 'x ; in2 = 'x;               end  // A-type (shift ammount)
    default : begin in1 = 'x ; in2 = 'x;               end
  endcase

end:gen_lsa_ena
else begin: gen_lsa_alu

  // ALU is used to calculate load/store address
  always_comb
  unique casez (ctl.i.alu.ai)
    AI_R1_R2: begin in1 = rs1; in2 = rs2;              end  // R-type
    AI_R1_II: begin in1 = rs1; in2 = XLEN'(ctl.imm.i); end  // I-type (arithmetic/logic)
    AI_R1_IL: begin in1 = rs1; in2 = XLEN'(ctl.imm.l); end  // I-type (load)
    AI_R1_IS: begin in1 = rs1; in2 = XLEN'(ctl.imm.s); end  // S-type (store)
    AI_PC_IU: begin in1 = pc ; in2 = XLEN'(ctl.imm.u); end  // U-type
    AI_PC_IJ: begin in1 = pc ; in2 = XLEN'(ctl.imm.j); end  // J-type (jump)
    AI_R1_RA: begin in1 = 'x ; in2 = 'x;               end  // A-type (shift ammount)
    default : begin in1 = 'x ; in2 = 'x;               end
  endcase

end: gen_lsa_alu
endgenerate

// signed/unsigned extension
always_comb
unique casez (ctl.i.alu.rt)
//  R_XX,
  R_SX   : ao1 = (XLEN+1)'(  signed'(in1        ));  //   signed XLEN
  R_UX   : ao1 = (XLEN+1)'(unsigned'(in1        ));  // unsigned XLEN
//  R_XW,
  R_SW   : ao1 = (XLEN+1)'(  signed'(in1[32-1:0]));  //   signed word
  R_UW   : ao1 = (XLEN+1)'(unsigned'(in1[32-1:0]));  // unsigned word
  default: ao1 = 'x;                                 //   signed XLEN
endcase

// signed/unsigned extension
always_comb
unique casez (ctl.i.alu.rt)
//  R_XX,
  R_SX   : ao2 = (XLEN+1)'(  signed'(in2        ));  //   signed XLEN
  R_UX   : ao2 = (XLEN+1)'(unsigned'(in2        ));  // unsigned XLEN
//  R_XW,
  R_SW   : ao2 = (XLEN+1)'(  signed'(in2[32-1:0]));  //   signed word
  R_UW   : ao2 = (XLEN+1)'(unsigned'(in2[32-1:0]));  // unsigned word
  default: ao2 = 'x;                                 //   signed XLEN
endcase

// invert operand 2 (bit 5 of f7 segment of operand)
always_comb
unique casez (ctl.i.alu.ao)
  AO_ADD : inv = 1'b0;
  AO_SUB ,
  AO_SLT ,
  AO_SLTU: inv = 1'b1;
  default: inv = 1'bx;
endcase

// TODO: inversion is only needed for AI_R1_R2 ???
// adder (summation, subtraction)
assign sum = $signed(ao1) + $signed(inv ? ~ao2 : ao2) + $signed((XLEN+1)'(inv));
//assign sum = $signed(ao1) + $signed(ao2) + $signed((XLEN+1)'(inv));

///////////////////////////////////////////////////////////////////////////////
// bitwise logical operations
///////////////////////////////////////////////////////////////////////////////

// logical operands
generate
if (CFG_LOM) begin: gen_lom_ena

  // dedicated logical operand multiplexer
  always_comb
  unique casez (ctl.i.alu.ai)
    AI_R1_R2: begin lo1 = rs1; lo2 = rs2;              end  // R-type
    AI_R1_II: begin lo1 = rs1; lo2 = XLEN'(ctl.imm.i); end  // I-type (arithmetic/logic)
    default : begin lo1 = 'x ; lo2 = 'x;               end
  endcase

end:gen_lom_ena
else begin: gen_lom_alu

  // shared ALU common multiplexer
  assign lo1 = rs1;
  assign lo2 = in2;

end: gen_lom_alu
endgenerate

///////////////////////////////////////////////////////////////////////////////
// barrel shifter
///////////////////////////////////////////////////////////////////////////////

// shift ammount multiplexer
always_comb
unique casez (ctl.i.alu.ai)
  AI_R1_RA: sam = rs2      [XLOG-1:0];
  AI_R1_II: sam = ctl.imm.i[XLOG-1:0];
  default : sam = 'x;
endcase

// shift length
always_comb
unique casez (ctl.i.alu.rt)
//  R_XX,
  R_SX,
  R_UX   : sa =         sam[XLOG-1:0] ;  // XLEN
//  R_XW,
  R_SW,
  R_UW   : sa = (XLOG)'(sam[   5-1:0]);  // word
  default: sa = 'x;
endcase

///////////////////////////////////////////////////////////////////////////////
// output multiplexer
///////////////////////////////////////////////////////////////////////////////

// operations
always_comb
unique casez (ctl.i.alu.ao)
  // adder based instructions
  AO_ADD ,
  AO_SUB : val = XLEN'(sum);
  AO_SLT ,
  AO_SLTU: val = XLEN'(sum[XLEN]);
  // bitwise logical operations
  AO_AND : val = lo1 & lo2;
  AO_OR  : val = lo1 | lo2;
  AO_XOR : val = lo1 ^ lo2;
  // barrel shifter
  AO_SRA : val =   $signed(rs1) >>> sa;
  AO_SRL : val = $unsigned(rs1)  >> sa;
  AO_SLL : val = $unsigned(rs1)  << sa;
  default: val = 'x;
endcase

// handling operations narower than XLEN
// TODO: check if all or only adder based instructions have 32 versions
always_comb
unique casez (ctl.i.alu.rt)
//  R_XX,
  R_SX,
  R_UX   : rd =                 val          ;  // XLEN
//  R_XW,
  R_SW,
  R_UW   : rd = (XLEN)'($signed(val[32-1:0]));  // sign extended word
  default: rd = 'x;
endcase

endmodule: r5p_alu