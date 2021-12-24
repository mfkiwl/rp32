////////////////////////////////////////////////////////////////////////////////
// R5P: system bus decoder
////////////////////////////////////////////////////////////////////////////////

module r5p_bus_dec #(
  // bus parameters
  int unsigned AW = 32,    // address width
  int unsigned DW = 32,    // data width
  // interconnect parameters
  int unsigned BN = 2,     // bus number
  logic [BN-1:0] [AW-1:0] AS = '{BN{'x}}
)(
  r5p_bus_if.sub s        ,  // system bus subordinate port  (master device connects here)
  r5p_bus_if.man m[BN-1:0]   // system bus manager     ports (slave  devices connect here)
);

////////////////////////////////////////////////////////////////////////////////
// local signals
////////////////////////////////////////////////////////////////////////////////

// decoder signals
logic [BN-1:0]          s_dec;
logic [BN-1:0]          m_dec;

// temporary signals
logic [BN-1:0] [DW-1:0] t_rdt;  // read data
logic [BN-1:0]          t_rdy;  // acknowledge

generate
for (genvar i=0; i<BN; i++) begin
  // decoder
  assign s_dec[i] = s.adr ==? AS[i];
  // forward path
  assign m[i].vld = s_dec[i] ? s.vld : '0;
  assign m[i].wen = s_dec[i] ? s.wen : 'x;
  assign m[i].ben = s_dec[i] ? s.ben : 'x;
  assign m[i].adr = s_dec[i] ? s.adr : 'x;
  assign m[i].wdt = s_dec[i] ? s.wdt : 'x;
  // backward path
  assign t_rdt[i] = m_dec[i] ? m[i].rdt : '0;
  assign t_rdy[i] = s_dec[i] ? m[i].rdy : '0;
end
endgenerate

always_comb
begin
  s.rdt = '0;
  s.rdy = '0;
  for (int unsigned i=0; i<BN; i++) begin
    s.rdt |= t_rdt[i];
    s.rdy |= t_rdy[i];
  end
end

// TODO: 
//assign s.rdt = m.rdt.and;
//assign s.rdy = m.rdy.and;

// copy of decoder at a bus transfer
always_ff @(posedge s.clk, posedge s.rst)
if (s.rst) begin
  m_dec <= '0;
end else if (s.vld & s.rdy) begin
  m_dec <= s_dec;
end

endmodule: r5p_bus_dec