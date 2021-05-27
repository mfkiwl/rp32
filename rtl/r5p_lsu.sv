///////////////////////////////////////////////////////////////////////////////
// load/store unit
///////////////////////////////////////////////////////////////////////////////

import riscv_isa_pkg::*;

module r5p_lsu #(
  int unsigned XW = 32,   // XLEN
    // data bus
  int unsigned AW = 32,   // address width
  int unsigned DW = 32,   // data    width
  int unsigned BW = DW/8  // byte en width
)(
  // system signals
  input  logic                 clk,  // clock
  input  logic                 rst,  // reset
  // control
  input  lsu_t                 ctl,
  // data input/output
  input  logic        [XW-1:0] adr,  // address
  input  logic        [XW-1:0] wdt,  // write data
  output logic        [XW-1:0] rdt,  // read data
  output logic        [XW-1:0] mal,  // misaligned
  output logic                 dly,  // delayed writeback enable
  // data bus (load/store)
  output logic                 ls_req,  // write or read request
  output logic                 ls_wen,  // write enable
  output logic [AW-1:0]        ls_adr,  // address
  output logic [BW-1:0]        ls_ben,  // byte enable
  output logic [BW-1:0][8-1:0] ls_wdt,  // write data
  input  logic [BW-1:0][8-1:0] ls_rdt,  // read data
  input  logic                 ls_ack   // write or read acknowledge
);

// word address width
localparam int unsigned WW = $clog2(BW);

// request
assign ls_req = ctl.en & ~dly;

// write enable
assign ls_wen = ctl.we;

// address
assign ls_adr = {adr[AW-1:WW], WW'('0)};

// byte select
// TODO
always_comb
//for (int unsigned i=0; i<SW; i++) begin
//  ls_ben[i] = (2**id_ctl.i.st) &
//end
if (ctl.we) begin
  // write access
  unique case (ctl.f3)
    SB     : ls_ben = BW'(8'b0000_0001 << adr[WW-1:0]);
    SH     : ls_ben = BW'(8'b0000_0011 << adr[WW-1:0]);
    SW     : ls_ben = BW'(8'b0000_1111 << adr[WW-1:0]);
    SD     : ls_ben = BW'(8'b1111_1111 << adr[WW-1:0]);
    default: ls_ben = '0;
  endcase
end else begin
  // TODO: handle read access
  // read access
  ls_ben = '1;
end

// write data (apply byte select mask)
always_comb
unique case (ctl.f3)
  SB     : ls_wdt = (wdt & DW'(64'h00000000_000000ff)) << (8*adr[WW-1:0]);
  SH     : ls_wdt = (wdt & DW'(64'h00000000_0000ffff)) << (8*adr[WW-1:0]);
  SW     : ls_wdt = (wdt & DW'(64'h00000000_ffffffff)) << (8*adr[WW-1:0]);
  SD     : ls_wdt = (wdt & DW'(64'hffffffff_ffffffff)) << (8*adr[WW-1:0]);
  default: ls_wdt = 'x;
endcase

// read data (sign extend)
always_comb begin: blk_rdt
  logic [XW-1:0] tmp;
  tmp = ls_rdt >> (8*adr[WW-1:0]);
  unique case (ctl.f3)
    LB     : rdt = DW'(  $signed( 8'(tmp)));
    LH     : rdt = DW'(  $signed(16'(tmp)));
    LW     : rdt = DW'(  $signed(32'(tmp)));
    LD     : rdt = DW'(  $signed(64'(tmp)));
    LBU    : rdt = DW'($unsigned( 8'(tmp)));
    LHU    : rdt = DW'($unsigned(16'(tmp)));
    LWU    : rdt = DW'($unsigned(32'(tmp)));
    LDU    : rdt = DW'($unsigned(64'(tmp)));
    default: rdt = 'x;
  endcase
end: blk_rdt

// access delay
always_ff @ (posedge clk, posedge rst)
if (rst)  dly <= 1'b0;
else      dly <= ls_req & ls_ack & ~ls_wen;

endmodule: r5p_lsu