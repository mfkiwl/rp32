import riscv_isa_pkg::*;

module r5p_core #(
  // RISC-V ISA
  isa_t        ISA = '{RV_32I, RV_M},  // see `riscv_isa_pkg` for enumeration definition
  int unsigned XW  = 32,    // TODO: calculate it from ISA
  // instruction bus
  int unsigned IAW = 32,    // program address width
  int unsigned IDW = 32,    // program data    width
  int unsigned IBW = IDW/8, // program byte en width
  // data bus
  int unsigned DAW = 32,    // data    address width
  int unsigned DDW = 32,    // data    data    width
  int unsigned DBW = DDW/8, // data    byte en width
  // constants ???
  logic [IAW-1:0] PC0 = '0
)(
  // system signals
  input  logic                  clk,
  input  logic                  rst,
  // program bus (instruction fetch)
  output logic                  if_req,
  output logic [IAW-1:0]        if_adr,
  input  logic [IBW-1:0][8-1:0] if_rdt,
  input  logic                  if_ack,
  // data bus (load/store)
  output logic                  ls_req,  // write or read request
  output logic                  ls_wen,  // write enable
  output logic [DAW-1:0]        ls_adr,  // address
  output logic [DBW-1:0]        ls_ben,  // byte enable
  output logic [DBW-1:0][8-1:0] ls_wdt,  // write data
  input  logic [DBW-1:0][8-1:0] ls_rdt,  // read data
  input  logic                  ls_ack   // write or read acknowledge
);

///////////////////////////////////////////////////////////////////////////////
// local signals
///////////////////////////////////////////////////////////////////////////////

// instruction fetch
logic           if_run;  // running status
logic           if_tkn;  // taken
logic [IAW-1:0] if_pc;   // program counter
logic [IAW-1:0] if_pci;  // program counter incrementing adder
logic [IAW-1:0] if_pcb;  // program counter branch adder
logic [IAW-1:0] if_pcn;  // program counter next
logic           stall;

// instruction decode
op32_t          id_op32; // 32-bit operation code
op16_t          id_op16; // 16-bit operation code
ctl_t           id_ctl;  // control structure
logic           id_vld;  // instruction valid

// GPR
logic  [XW-1:0] gpr_rs1;  // register source 1
logic  [XW-1:0] gpr_rs2;  // register source 2
logic  [XW-1:0] gpr_rd ;  // register destination

// ALU
logic  [XW-1:0] alu_rd ;  // register destination
logic  [XW-1:0] alu_sum;  // sum (can be used regardless of ALU command

// MUL/DIV/REM
logic  [XW-1:0] mul_rd;   // multiplier unit output

// CSR
logic  [XW-1:0] csr_rdt;  // read  data

// CSR
logic           csr_expt = '0;
logic [IAW-1:0] csr_evec;
logic [IAW-1:0] csr_epc;

// load/sore unit temporary signals
logic [XW-1:0] lsu_adr;  // address
logic [XW-1:0] lsu_wdt;  // write data
logic [XW-1:0] lsu_rdt;  // read data
logic [XW-1:0] lsu_mal;  // MisALigned
logic          lsu_dly;  // DeLaYed writeback enable

///////////////////////////////////////////////////////////////////////////////
// instruction fetch
///////////////////////////////////////////////////////////////////////////////

// start running after reset
always_ff @ (posedge clk, posedge rst)
if (rst)  if_run <= 1'b0;
else      if_run <= 1'b1;

// request becomes active after reset
assign if_req = if_run & ~(ls_req & ~ls_wen);

// PC next is used as IF address
assign if_adr = if_pcn;

// instruction valid
always_ff @ (posedge clk, posedge rst)
if (rst)  id_vld <= 1'b0;
else      id_vld <= (if_req & if_ack) | (id_vld & stall);

///////////////////////////////////////////////////////////////////////////////
// program counter
///////////////////////////////////////////////////////////////////////////////

// TODO:
assign stall = (if_req & ~if_ack) | (ls_req & ~ls_ack) | (ls_req & ~ls_wen);

// program counter
always_ff @ (posedge clk, posedge rst)
if (rst)  if_pc <= PC0;
else begin
  if (id_vld & ~stall) if_pc <= if_pcn;
end

// branch ALU for checking branch conditions
r5p_br #(
  .XW      (XW)
) br (
  // control
  .ctl     (id_ctl.i.br),
  // data
  .rs1     (gpr_rs1),
  .rs2     (gpr_rs2),
  // status
  .tkn     (if_tkn)
);

// TODO: optimization parameters
// 1. branch immediate direct branch type decoder (kind of obvious, but see if it beats the tool optimizations)
// 2. separate adder for PC next and branch address, since mux control signal from ALU is late and is best used just before output
// 3. a separate branch ALU with explicit [un]signed comparator instead of adder in the main ALU

// program counter incrementing adder
assign if_pci = if_pc + IAW'(opsiz(id_op16[16-1:0]));

// branch address adder
//assign if_pcb = if_pc + IAW'(imm32(id_op32,T_B));
assign if_pcb = if_pc + IAW'(id_ctl.imm);

// program counter next
always_comb
if (csr_expt)  if_pcn = csr_evec;
else if (if_ack & id_vld) begin
  case (id_ctl.i.pc)
    PC_PCI: if_pcn = if_pci;
    PC_BRN: if_pcn = if_tkn ? if_pcb : if_pci;
    PC_JMP: if_pcn = {alu_sum[IAW-1:1], 1'b0};  // TODO: do not use ALU for branches
    PC_EPC: if_pcn = csr_epc;
    default: if_pcn = 'x;
  endcase
end else begin
  if_pcn = if_pc;
end

///////////////////////////////////////////////////////////////////////////////
// instruction decode
///////////////////////////////////////////////////////////////////////////////

// opcode from instruction fetch
assign id_op32 = if_rdt[4-1:0];
assign id_op16 = if_rdt[2-1:0];

// 32-bit instruction decoder
assign id_ctl = dec(ISA, id_op32);

///////////////////////////////////////////////////////////////////////////////
// execute
///////////////////////////////////////////////////////////////////////////////

// general purpose registers
r5p_gpr #(
  .AW      (ISA.base.E ? 4 : 5),
  .XW      (XW)
) gpr (
  // system signals
  .clk     (clk),
  .rst     (rst),
  // read/write enable
  .e_rs1   (id_ctl.gpr.e.rs1),
  .e_rs2   (id_ctl.gpr.e.rs2),
  .e_rd    (id_ctl.gpr.e.rd & (id_ctl.i.wb == WB_MEM ? lsu_dly : 1'b1)),
  // read/write address
  .a_rs1   (id_ctl.gpr.a.rs1),
  .a_rs2   (id_ctl.gpr.a.rs2),
  .a_rd    (id_ctl.gpr.a.rd ),
  // read/write data
  .d_rs1   (gpr_rs1),
  .d_rs2   (gpr_rs2),
  .d_rd    (gpr_rd )
);

// base ALU
r5p_alu #(
  .XW      (XW)
) alu (
   // system signals
  .clk     (clk),
  .rst     (rst),
  // control
  .ctl     (id_ctl.i.alu),
  // data input/output
  .imm     (id_ctl.imm),
  .pc      (XW'(if_pc)),
  .rs1     (gpr_rs1),
  .rs2     (gpr_rs2),
  .rd      (alu_rd ),
  // dedicated output for branch address
  .sum     (alu_sum)
);

// mul/div/rem unit
r5p_mdu #(
  .XW      (XW)
) mdu (
  // system signals
  .clk     (clk),
  .rst     (rst),
  // control
  .ctl     (id_ctl.m),
  // data input/output
  .rs1     (gpr_rs1),
  .rs2     (gpr_rs2),
  .rd      (mul_rd )
);

///////////////////////////////////////////////////////////////////////////////
// CSR
///////////////////////////////////////////////////////////////////////////////

r5p_csr #(
  .ISA     (ISA)
) csr (
  // system signals
  .clk     (clk),
  .rst     (rst),
  // control
  .ctl     (id_ctl.csr),
  // data input/output
  .wdt     (gpr_rs1),
  .rdt     (csr_rdt)
);

///////////////////////////////////////////////////////////////////////////////
// load/store
///////////////////////////////////////////////////////////////////////////////

// temprary values
assign lsu_adr = alu_sum;
assign lsu_wdt = gpr_rs2;

// load/store unit
r5p_lsu #(
  .XW      (XW),
  // data bus
  .AW      (DAW),
  .DW      (DDW),
  .BW      (DBW)
) lsu (
  // system signals
  .clk     (clk),
  .rst     (rst),
  // control
  .ctl     (id_ctl.i.lsu),
  // data input/output
  .adr     (lsu_adr),
  .wdt     (lsu_wdt),
  .rdt     (lsu_rdt),
  .mal     (lsu_mal),
  .dly     (lsu_dly),
  // data bus (load/store)
  .ls_req  (ls_req),
  .ls_wen  (ls_wen),
  .ls_adr  (ls_adr),
  .ls_ben  (ls_ben),
  .ls_wdt  (ls_wdt),
  .ls_rdt  (ls_rdt),
  .ls_ack  (ls_ack)
);

///////////////////////////////////////////////////////////////////////////////
// write back
///////////////////////////////////////////////////////////////////////////////

// write back multiplexer
always_comb begin
  unique case (id_ctl.i.wb)
    WB_ALU : gpr_rd = alu_rd;       // ALU output
    WB_MEM : gpr_rd = lsu_rdt;      // memory read data
    WB_PCI : gpr_rd = XW'(if_pci);  // PC next
    WB_IMM : gpr_rd = id_ctl.imm;   // immediate  // TODO: optimize this code // imm32(id_op32, T_U)
    WB_CSR : gpr_rd = csr_rdt;      // CSR
    WB_MUL : gpr_rd = mul_rd;       // mul/div/rem
    default: gpr_rd = 'x;           // none
  endcase
end

endmodule: r5p_core