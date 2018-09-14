package riscv_asm_pkg;

import riscv_isa_pkg::*;

///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////

localparam string REG_X [0:31] = '{"zero", "ra", "sp", "gp", "tp", "t0", "t1", "t2", "s0/fp", "s1", "a0", "a1", "a2", "a3", "a4", "a5",
                                   "a6", "a7", "s2", "s3", "s4", "s5", "s6", "s7", "s8", "s9", "s10", "s11", "t3", "t4", "t5", "t6"};
localparam string REG_F [0:31] = '{"ft0", "ft1", "ft2", "ft3", "ft4", "ft5", "ft6", "ft7", "fs0", "fs1", "fa0", "fa1", "fa2", "fa3", "fa4", "fa5",
                                   "fa6", "fa7", "fs2", "fs3", "fs4", "fs5", "fs6", "fs7", "fs8", "fs9", "fs10", "fs11", "ft8", "ft9", "ft10", "ft11"};

function string reg_x (logic [5-1:0] r, bit abi=1'b0);
  reg_x = abi ? REG_X[r] : $sformatf("x%0d", r);
endfunction: reg_x

///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////


function string disasm32 (frm32_t op, bit abi=0);
casez (op)
//  fedc_ba98_7654_3210_fedc_ba98_7654_3210
32'b0000_0000_0000_0000_0000_0000_0001_0011: disasm32 = $sformatf("nop");
32'b0000_0000_0000_0000_0100_0000_0011_0011: disasm32 = $sformatf("-"); // 32'h00004033 - machine generated bubble
32'b????_????_????_????_????_????_?011_0111: disasm32 = $sformatf("lui   %s, 0x%08x"     , reg_x(op.u.rd , abi), imm32(op, T32_U));
32'b????_????_????_????_????_????_?001_0111: disasm32 = $sformatf("auipc %s, 0x%08x"     , reg_x(op.u.rd , abi), imm32(op, T32_U));
32'b????_????_????_????_?000_????_?110_0111: disasm32 = $sformatf("jalr  %s, 0x%03x (%s)", reg_x(op.i.rd , abi), imm32(op, T32_J), reg_x(op.i.rs1, abi));
32'b????_????_????_????_????_????_?110_1111: disasm32 = $sformatf("jal       0x%06x"     ,                       imm32(op, T32_B));
32'b????_????_????_????_?000_????_?110_0011: disasm32 = $sformatf("beq   %s, %s, 0x%04x" , reg_x(op.b.rs1, abi), reg_x(op.b.rs2, abi), imm32(op, T32_B));
32'b????_????_????_????_?001_????_?110_0011: disasm32 = $sformatf("bne   %s, %s, 0x%04x" , reg_x(op.b.rs1, abi), reg_x(op.b.rs2, abi), imm32(op, T32_B));
32'b????_????_????_????_?100_????_?110_0011: disasm32 = $sformatf("blt   %s, %s, 0x%04x" , reg_x(op.b.rs1, abi), reg_x(op.b.rs2, abi), imm32(op, T32_B));
32'b????_????_????_????_?101_????_?110_0011: disasm32 = $sformatf("bge   %s, %s, 0x%04x" , reg_x(op.b.rs1, abi), reg_x(op.b.rs2, abi), imm32(op, T32_B));
32'b????_????_????_????_?110_????_?110_0011: disasm32 = $sformatf("bltu  %s, %s, 0x%04x" , reg_x(op.b.rs1, abi), reg_x(op.b.rs2, abi), imm32(op, T32_B));
32'b????_????_????_????_?111_????_?110_0011: disasm32 = $sformatf("bgeu  %s, %s, 0x%04x" , reg_x(op.b.rs1, abi), reg_x(op.b.rs2, abi), imm32(op, T32_B));
32'b????_????_????_????_?000_????_?000_0011: disasm32 = $sformatf("lb    %s, 0x%03x (%s)", reg_x(op.i.rd , abi), imm32(op, T32_I), reg_x(op.i.rs1, abi));
32'b????_????_????_????_?001_????_?000_0011: disasm32 = $sformatf("lh    %s, 0x%03x (%s)", reg_x(op.i.rd , abi), imm32(op, T32_I), reg_x(op.i.rs1, abi));
32'b????_????_????_????_?010_????_?000_0011: disasm32 = $sformatf("lw    %s, 0x%03x (%s)", reg_x(op.i.rd , abi), imm32(op, T32_I), reg_x(op.i.rs1, abi));
32'b????_????_????_????_?011_????_?000_0011: disasm32 = $sformatf("ld    %s, 0x%03x (%s)", reg_x(op.i.rd , abi), imm32(op, T32_I), reg_x(op.i.rs1, abi));
32'b????_????_????_????_?100_????_?000_0011: disasm32 = $sformatf("lbu   %s, 0x%03x (%s)", reg_x(op.i.rd , abi), imm32(op, T32_I), reg_x(op.i.rs1, abi));
32'b????_????_????_????_?101_????_?000_0011: disasm32 = $sformatf("lhu   %s, 0x%03x (%s)", reg_x(op.i.rd , abi), imm32(op, T32_I), reg_x(op.i.rs1, abi));
32'b????_????_????_????_?110_????_?000_0011: disasm32 = $sformatf("lwu   %s, 0x%03x (%s)", reg_x(op.i.rd , abi), imm32(op, T32_I), reg_x(op.i.rs1, abi));
32'b????_????_????_????_?000_????_?010_0011: disasm32 = $sformatf("sb    %s, 0x%03x (%s)", reg_x(op.s.rs2, abi), imm32(op, T32_S), reg_x(op.s.rs1, abi));
32'b????_????_????_????_?001_????_?010_0011: disasm32 = $sformatf("sh    %s, 0x%03x (%s)", reg_x(op.s.rs2, abi), imm32(op, T32_S), reg_x(op.s.rs1, abi));
32'b????_????_????_????_?010_????_?010_0011: disasm32 = $sformatf("sw    %s, 0x%03x (%s)", reg_x(op.s.rs2, abi), imm32(op, T32_S), reg_x(op.s.rs1, abi));
32'b????_????_????_????_?011_????_?010_0011: disasm32 = $sformatf("sd    %s, 0x%03x (%s)", reg_x(op.s.rs2, abi), imm32(op, T32_S), reg_x(op.s.rs1, abi));
32'b????_????_????_????_?000_????_?001_0011: disasm32 = $sformatf("addi  %s, 0x%03x (%s)", reg_x(op.i.rd , abi), imm32(op, T32_I), reg_x(op.i.rs1, abi));
32'b????_????_????_????_?010_????_?001_0011: disasm32 = $sformatf("slti  %s, 0x%03x (%s)", reg_x(op.i.rd , abi), imm32(op, T32_I), reg_x(op.i.rs1, abi));
32'b????_????_????_????_?011_????_?001_0011: disasm32 = $sformatf("sltiu %s, 0x%03x (%s)", reg_x(op.i.rd , abi), imm32(op, T32_I), reg_x(op.i.rs1, abi));
32'b????_????_????_????_?100_????_?001_0011: disasm32 = $sformatf("xori  %s, 0x%03x (%s)", reg_x(op.i.rd , abi), imm32(op, T32_I), reg_x(op.i.rs1, abi));
32'b????_????_????_????_?110_????_?001_0011: disasm32 = $sformatf("ori   %s, 0x%03x (%s)", reg_x(op.i.rd , abi), imm32(op, T32_I), reg_x(op.i.rs1, abi));
32'b????_????_????_????_?111_????_?001_0011: disasm32 = $sformatf("andi  %s, 0x%03x (%s)", reg_x(op.i.rd , abi), imm32(op, T32_I), reg_x(op.i.rs1, abi));
32'b0000_00??_????_????_?001_????_?001_0011: disasm32 = $sformatf("slli  %s, %s, 0x%02x" , reg_x(op.r.rd , abi), reg_x(op.r.rs1, abi), op[26:20]);
32'b0000_00??_????_????_?101_????_?001_0011: disasm32 = $sformatf("srli  %s, %s, 0x%02x" , reg_x(op.r.rd , abi), reg_x(op.r.rs1, abi), op[26:20]);
32'b0100_00??_????_????_?101_????_?001_0011: disasm32 = $sformatf("srai  %s, %s, 0x%02x" , reg_x(op.r.rd , abi), reg_x(op.r.rs1, abi), op[26:20]);
32'b0000_000?_????_????_?000_????_?011_0011: disasm32 = $sformatf("add   %s, %s, %s"     , reg_x(op.r.rd , abi), reg_x(op.r.rs1, abi), reg_x(op.r.rs2, abi));
32'b0100_000?_????_????_?000_????_?011_0011: disasm32 = $sformatf("sub   %s, %s, %s"     , reg_x(op.r.rd , abi), reg_x(op.r.rs1, abi), reg_x(op.r.rs2, abi));
32'b0000_000?_????_????_?010_????_?011_0011: disasm32 = $sformatf("slt   %s, %s, %s"     , reg_x(op.r.rd , abi), reg_x(op.r.rs1, abi), reg_x(op.r.rs2, abi));
32'b0000_000?_????_????_?011_????_?011_0011: disasm32 = $sformatf("sltu  %s, %s, %s"     , reg_x(op.r.rd , abi), reg_x(op.r.rs1, abi), reg_x(op.r.rs2, abi));
32'b0000_000?_????_????_?100_????_?011_0011: disasm32 = $sformatf("xor   %s, %s, %s"     , reg_x(op.r.rd , abi), reg_x(op.r.rs1, abi), reg_x(op.r.rs2, abi));
32'b0000_000?_????_????_?001_????_?011_0011: disasm32 = $sformatf("sll   %s, %s, %s"     , reg_x(op.r.rd , abi), reg_x(op.r.rs1, abi), reg_x(op.r.rs2, abi));
32'b0000_000?_????_????_?101_????_?011_0011: disasm32 = $sformatf("srl   %s, %s, %s"     , reg_x(op.r.rd , abi), reg_x(op.r.rs1, abi), reg_x(op.r.rs2, abi));
32'b0100_000?_????_????_?101_????_?011_0011: disasm32 = $sformatf("sra   %s, %s, %s"     , reg_x(op.r.rd , abi), reg_x(op.r.rs1, abi), reg_x(op.r.rs2, abi));
32'b0000_000?_????_????_?110_????_?011_0011: disasm32 = $sformatf("or    %s, %s, %s"     , reg_x(op.r.rd , abi), reg_x(op.r.rs1, abi), reg_x(op.r.rs2, abi));
32'b0000_000?_????_????_?111_????_?011_0011: disasm32 = $sformatf("and   %s, %s, %s"     , reg_x(op.r.rd , abi), reg_x(op.r.rs1, abi), reg_x(op.r.rs2, abi));
//32'b????_????_????_????_?000_????_?000_1111: disasm32 = $sformatf("fence 0b%04b, 0b%04b // fn=0x%01x, rd=%s, rs1=%s", op[27:24], op[23:20], op[31:28], reg_x(op.i.rd , abi), reg_x(op.i.rs1, abi));
32'b????_????_????_????_?001_????_?000_1111: disasm32 = $sformatf("fence.i");
32'b????_????_????_????_?001_????_?111_0011: disasm32 = $sformatf("csrrw  %s, 0x%03x, %s"    , reg_x(op.i.rd , abi), op.i.imm_11_0, reg_x(op.i.rs1, abi));
32'b????_????_????_????_?010_????_?111_0011: disasm32 = $sformatf("csrrs  %s, 0x%03x, %s"    , reg_x(op.i.rd , abi), op.i.imm_11_0, reg_x(op.i.rs1, abi));
32'b????_????_????_????_?011_????_?111_0011: disasm32 = $sformatf("csrrc  %s, 0x%03x, %s"    , reg_x(op.i.rd , abi), op.i.imm_11_0, reg_x(op.i.rs1, abi));
32'b????_????_????_????_?101_????_?111_0011: disasm32 = $sformatf("csrrwi %s, 0x%03x, 0b%05b", reg_x(op.i.rd , abi), op.i.imm_11_0, op.i.rs1);
32'b????_????_????_????_?110_????_?111_0011: disasm32 = $sformatf("csrrsi %s, 0x%03x, 0b%05b", reg_x(op.i.rd , abi), op.i.imm_11_0, op.i.rs1);
32'b????_????_????_????_?111_????_?111_0011: disasm32 = $sformatf("csrrci %s, 0x%03x, 0b%05b", reg_x(op.i.rd , abi), op.i.imm_11_0, op.i.rs1);
32'b0000_0000_0000_0000_0000_0000_0111_0011: disasm32 = $sformatf("ecall");
32'b0000_0000_0001_0000_0000_0000_0111_0011: disasm32 = $sformatf("ebreak");
32'b1000_0000_0000_0000_0000_0000_0111_0011: disasm32 = $sformatf("eret");
32'b0001_0000_0010_0000_0000_0000_0111_0011: disasm32 = $sformatf("wfi");

//  32'b????_????_????_????_?000_????_?001_1011: disasm32 = $sformatf("addiw             ", TYPE_32_I};
//  32'b0000_000?_????_????_?001_????_?001_1011: disasm32 = $sformatf("slliw             ", TYPE_32_R};
//  32'b0000_000?_????_????_?101_????_?001_1011: disasm32 = $sformatf("srliw             ", TYPE_32_R};
//  32'b0100_000?_????_????_?101_????_?001_1011: disasm32 = $sformatf("sraiw             ", TYPE_32_R};
//  32'b0000_000?_????_????_?000_????_?011_1011: disasm32 = $sformatf("addw              ", TYPE_32_R};
//  32'b0100_000?_????_????_?000_????_?011_1011: disasm32 = $sformatf("subw              ", TYPE_32_R};
//  32'b0000_000?_????_????_?001_????_?011_1011: disasm32 = $sformatf("sllw              ", TYPE_32_R};
//  32'b0000_000?_????_????_?101_????_?011_1011: disasm32 = $sformatf("srlw              ", TYPE_32_R};
//  32'b0100_000?_????_????_?101_????_?011_1011: disasm32 = $sformatf("sraw              ", TYPE_32_R};

//  32'b0000_001?_????_????_?000_????_?011_0011: disasm32 = $sformatf("mul               ", TYPE_32_R};
//  32'b0000_001?_????_????_?001_????_?011_0011: disasm32 = $sformatf("mulh              ", TYPE_32_R};
//  32'b0000_001?_????_????_?010_????_?011_0011: disasm32 = $sformatf("mulhsu            ", TYPE_32_R};
//  32'b0000_001?_????_????_?011_????_?011_0011: disasm32 = $sformatf("mulhu             ", TYPE_32_R};
//  32'b0000_001?_????_????_?100_????_?011_0011: disasm32 = $sformatf("div               ", TYPE_32_R};
//  32'b0000_001?_????_????_?101_????_?011_0011: disasm32 = $sformatf("divu              ", TYPE_32_R};
//  32'b0000_001?_????_????_?110_????_?011_0011: disasm32 = $sformatf("rem               ", TYPE_32_R};
//  32'b0000_001?_????_????_?111_????_?011_0011: disasm32 = $sformatf("remu              ", TYPE_32_R};
//  32'b0000_001?_????_????_?000_????_?011_1011: disasm32 = $sformatf("mulw              ", TYPE_32_R};
//  32'b0000_001?_????_????_?100_????_?011_1011: disasm32 = $sformatf("divw              ", TYPE_32_R};
//  32'b0000_001?_????_????_?101_????_?011_1011: disasm32 = $sformatf("divuw             ", TYPE_32_R};
//  32'b0000_001?_????_????_?110_????_?011_1011: disasm32 = $sformatf("remw              ", TYPE_32_R};
//  32'b0000_001?_????_????_?111_????_?011_1011: disasm32 = $sformatf("remuw             ", TYPE_32_R};
//  32'b0000_0???_????_????_?010_????_?010_1111: disasm32 = $sformatf("amoadd.w          ", TYPE_32_R};
//  32'b0010_0???_????_????_?010_????_?010_1111: disasm32 = $sformatf("amoxor.w          ", TYPE_32_R};
//  32'b0100_0???_????_????_?010_????_?010_1111: disasm32 = $sformatf("amoor.w           ", TYPE_32_R};
//  32'b0110_0???_????_????_?010_????_?010_1111: disasm32 = $sformatf("amoand.w          ", TYPE_32_R};
//  32'b1000_0???_????_????_?010_????_?010_1111: disasm32 = $sformatf("amomin.w          ", TYPE_32_R};
//  32'b1010_0???_????_????_?010_????_?010_1111: disasm32 = $sformatf("amomax.w          ", TYPE_32_R};
//  32'b1100_0???_????_????_?010_????_?010_1111: disasm32 = $sformatf("amominu.w         ", TYPE_32_R};
//  32'b1110_0???_????_????_?010_????_?010_1111: disasm32 = $sformatf("amomaxu.w         ", TYPE_32_R};
//  32'b0000_1???_????_????_?010_????_?010_1111: disasm32 = $sformatf("amoswap.w         ", TYPE_32_R};
//  32'b0001_0??0_0000_????_?010_????_?010_1111: disasm32 = $sformatf("lr.w              ", TYPE_32_R};
//  32'b0001_1???_????_????_?010_????_?010_1111: disasm32 = $sformatf("sc.w              ", TYPE_32_R};
//  32'b0000_0???_????_????_?011_????_?010_1111: disasm32 = $sformatf("amoadd.d          ", TYPE_32_R};
//  32'b0010_0???_????_????_?011_????_?010_1111: disasm32 = $sformatf("amoxor.d          ", TYPE_32_R};
//  32'b0100_0???_????_????_?011_????_?010_1111: disasm32 = $sformatf("amoor.d           ", TYPE_32_R};
//  32'b0110_0???_????_????_?011_????_?010_1111: disasm32 = $sformatf("amoand.d          ", TYPE_32_R};
//  32'b1000_0???_????_????_?011_????_?010_1111: disasm32 = $sformatf("amomin.d          ", TYPE_32_R};
//  32'b1010_0???_????_????_?011_????_?010_1111: disasm32 = $sformatf("amomax.d          ", TYPE_32_R};
//  32'b1100_0???_????_????_?011_????_?010_1111: disasm32 = $sformatf("amominu.d         ", TYPE_32_R};
//  32'b1110_0???_????_????_?011_????_?010_1111: disasm32 = $sformatf("amomaxu.d         ", TYPE_32_R};
//  32'b0000_1???_????_????_?011_????_?010_1111: disasm32 = $sformatf("amoswap.d         ", TYPE_32_R};
//  32'b0001_0??0_0000_????_?011_????_?010_1111: disasm32 = $sformatf("lr.d              ", TYPE_32_R};
//  32'b0001_1???_????_????_?011_????_?010_1111: disasm32 = $sformatf("sc.d              ", TYPE_32_R};

default                                    : disasm32 = $sformatf("ILLEGAL");
endcase
endfunction: disasm32

endpackage: riscv_asm_pkg
