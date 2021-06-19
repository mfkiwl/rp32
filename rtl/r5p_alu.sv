///////////////////////////////////////////////////////////////////////////////
// arithmetic/logic unit (ALU)
///////////////////////////////////////////////////////////////////////////////

import riscv_isa_pkg::alu_t;

module r5p_alu #(
  int unsigned XLEN = 32
)(
  // system signals
  input  logic            clk,  // clock
  input  logic            rst,  // reset
  // control
  input  alu_t            ctl,
  // data input/output
  input  logic [XLEN-1:0] imm,  // immediate
  input  logic [XLEN-1:0] pc ,  // PC
  input  logic [XLEN-1:0] rs1,  // source register 1
  input  logic [XLEN-1:0] rs2,  // source register 2
  output logic [XLEN-1:0] rd,   // destination register
  // dedicated output for branch address
  output logic [XLEN-1:0] sum   // equal
);

// multiplexed inputs
logic [XLEN-1:0] in1;  // input 1
logic [XLEN-1:0] in2;  // input 2

logic ovf;  // overflow bit

// ALU input multiplexer
always_comb begin
  // RS1
  unique casez (ctl.ai)
    AI_R1_R2: begin in1 = rs1; in2 = rs2; end
    AI_R1_IM: begin in1 = rs1; in2 = imm; end
    AI_PC_IM: begin in1 = pc ; in2 = imm; end
    default : begin in1 = 'x ; in2 = 'x ; end
  endcase
end

// TODO: construct proper subtraction condition
// adder (summation, subtraction)
//assign {ovf, sum} = $signed(rs1) + (ctl.alu.sig ? -$signed(rs2) : +$signed(rs2));
assign {ovf, sum} = $signed(in1) + $signed(in2);

// TODO:
// * see if overflow can be used

always_comb
unique casez (ctl.ao)
  // adder based instructions
  AO_ADD : rd =   $signed(in1) +   $signed(in2);
  AO_SUB : rd =   $signed(in1) -   $signed(in2);
  AO_SLT : rd =   $signed(in1) <   $signed(in2) ? XLEN'(1) : XLEN'(0);
  AO_SLTU: rd = $unsigned(in1) < $unsigned(in2) ? XLEN'(1) : XLEN'(0);
  // bitwise logical operations
  AO_AND : rd = in1 & in2;
  AO_OR  : rd = in1 | in2;
  AO_XOR : rd = in1 ^ in2;
  // barrel shifter
  AO_SRA : rd =   $signed(in1) >>> in2[$clog2(XLEN)-1:0];
  AO_SRL : rd = $unsigned(in1)  >> in2[$clog2(XLEN)-1:0];
  AO_SLL : rd = $unsigned(in1)  << in2[$clog2(XLEN)-1:0];
  default: rd = 'x;
endcase

endmodule: r5p_alu