package riscv_asm;

typedef struct packed {logic [ 6: 0] func7 ;                                                   logic [ 4: 0] rs2      ; logic [ 4: 0] rs1      ; logic [ 2: 0] func3    ; logic [ 4: 0] rd       ;                       logic [ 6: 0] opcode;} t_format_r ;
typedef struct packed {logic [ 4: 0] rs3   ; logic [ 1: 0] func2    ;                          logic [ 4: 0] rs2      ; logic [ 4: 0] rs1      ; logic [ 2: 0] func3    ; logic [ 4: 0] rd       ;                       logic [ 6: 0] opcode;} t_format_r4;
typedef struct packed {logic [11:11] imm_11; logic [10: 5] imm_10_05; logic [ 4: 1] imm_04_01; logic [ 0: 0] imm_00   ; logic [ 4: 0] rs1      ; logic [ 2: 0] func3    ; logic [ 4: 0] rd       ;                       logic [ 6: 0] opcode;} t_format_i ;
typedef struct packed {logic [11:11] imm_11; logic [10: 5] imm_10_05;                          logic [ 4: 0] rs2      ; logic [ 4: 0] rs1      ; logic [ 2: 0] func3    ; logic [ 4: 1] imm_04_01; logic [ 0: 0] imm_00; logic [ 6: 0] opcode;} t_format_s ;
typedef struct packed {logic [12:12] imm_12; logic [10: 5] imm_10_05;                          logic [ 4: 0] rs2      ; logic [ 4: 0] rs1      ; logic [ 2: 0] func3    ; logic [ 4: 1] imm_04_01; logic [11:11] imm_11; logic [ 6: 0] opcode;} t_format_sb;
typedef struct packed {logic [31:31] imm_31; logic [30:20] imm_30_20; logic [19:15] imm_19_15; logic [14:12] imm_14_12;                                                   logic [ 4: 0] rd       ;                       logic [ 6: 0] opcode;} t_format_u ;
typedef struct packed {logic [20:20] imm_20; logic [10: 5] imm_10_05; logic [ 4: 1] imm_04_01; logic [11:11] imm_11   ; logic [19:15] imm_19_15; logic [14:12] imm_14_12; logic [ 4: 0] rd       ;                       logic [ 6: 0] opcode;} t_format_uj;

typedef union packed {
  t_format_r  r ;
  t_format_r4 r4;
  t_format_i  i ;
  t_format_s  s ;
  t_format_sb sb;
  t_format_u  u ;
  t_format_uj uj;
} t_format;

typedef enum logic [3:0] {TYPE_R, TYPE_R4, TYPE_I, TYPE_S, TYPE_SB, TYPE_U, TYPE_UJ, TYPE_0, TYPE_X} t_format_sel;

function logic signed [31:0] immediate (t_format i, t_format_sel sel);
  case (sel)
    TYPE_I : immediate = {{21{i.i .imm_11}},                                                              i.i .imm_10_05, i.i .imm_04_01, i.i .imm_00};
    TYPE_S : immediate = {{21{i.s .imm_11}},                                                              i.s .imm_10_05, i.s .imm_04_01, i.s .imm_00};
    TYPE_SB: immediate = {{20{i.sb.imm_12}},                                                 i.sb.imm_11, i.sb.imm_10_05, i.sb.imm_04_01, 1'b0       };
    TYPE_U : immediate = {    i.u .imm_31  , i.u .imm_30_20, i.u .imm_19_15, i.u .imm_14_12, 12'h000                                                 };
    TYPE_UJ: immediate = {{12{i.uj.imm_20}},                 i.uj.imm_19_15, i.uj.imm_14_12, i.uj.imm_11, i.uj.imm_10_05, i.uj.imm_04_01, 1'b0       };
    default: immediate = '0; // TODO
  endcase
endfunction: immediate

// instruction formats
typedef enum bit [5:0] {FMT_R0, FMT_R1, FMT_R2, FMT_F1, FMT_F2, FMT_F3, FMT_FX, FMT_XF1, FMT_XF2, FMT_0, FMT_I, FMT_B, FMT_J, FMT_L, FMT_LD, FMT_ST, FMT_FLD, FMT_FST, FMT_AMO, FMT_R2_P} t_format_str;

///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////

typedef struct {
  string               nam;  // name
//  bit [18-1:0] [8-1:0] nam;  // name
  t_format_sel         typ;  // type
  t_format_str         fmt;  // formatting string
//integer              ext;  // extension
  logic [32-1:0]       bin;  // binary encoding
} t_opcode;

/* Automatically generated by parse-opcodes */
//parameter t_opcode opcode [0:182-1] = '{
parameter t_opcode opcode [0:97-1] = '{
//                                               fedcba9876543210fedcba9876543210
  '{"BEQ               ", TYPE_SB, FMT_B   , 32'b?????????????????000?????1100011},
  '{"BNE               ", TYPE_SB, FMT_B   , 32'b?????????????????001?????1100011},
  '{"BLT               ", TYPE_SB, FMT_B   , 32'b?????????????????100?????1100011},
  '{"BGE               ", TYPE_SB, FMT_B   , 32'b?????????????????101?????1100011},
  '{"BLTU              ", TYPE_SB, FMT_B   , 32'b?????????????????110?????1100011},
  '{"BGEU              ", TYPE_SB, FMT_B   , 32'b?????????????????111?????1100011},
  '{"JALR              ", TYPE_I , FMT_LD  , 32'b?????????????????000?????1100111},
  '{"JAL               ", TYPE_UJ, FMT_L   , 32'b?????????????????????????1101111},
  '{"LUI               ", TYPE_U , FMT_L   , 32'b?????????????????????????0110111},
  '{"AUIPC             ", TYPE_U , FMT_L   , 32'b?????????????????????????0010111},
  '{"ADDI              ", TYPE_I , FMT_I   , 32'b?????????????????000?????0010011},
  '{"SLLI              ", TYPE_R , FMT_I   , 32'b000000???????????001?????0010011},
  '{"SLTI              ", TYPE_I , FMT_I   , 32'b?????????????????010?????0010011},
  '{"SLTIU             ", TYPE_I , FMT_I   , 32'b?????????????????011?????0010011},
  '{"XORI              ", TYPE_I , FMT_I   , 32'b?????????????????100?????0010011},
  '{"SRLI              ", TYPE_R , FMT_I   , 32'b000000???????????101?????0010011},
  '{"SRAI              ", TYPE_R , FMT_I   , 32'b010000???????????101?????0010011},
  '{"ORI               ", TYPE_I , FMT_I   , 32'b?????????????????110?????0010011},
  '{"ANDI              ", TYPE_I , FMT_I   , 32'b?????????????????111?????0010011},
  '{"ADD               ", TYPE_R , FMT_R2  , 32'b0000000??????????000?????0110011},
  '{"SUB               ", TYPE_R , FMT_R2  , 32'b0100000??????????000?????0110011},
  '{"SLL               ", TYPE_R , FMT_R2  , 32'b0000000??????????001?????0110011},
  '{"SLT               ", TYPE_R , FMT_R2  , 32'b0000000??????????010?????0110011},
  '{"SLTU              ", TYPE_R , FMT_R2  , 32'b0000000??????????011?????0110011},
  '{"XOR               ", TYPE_R , FMT_R2  , 32'b0000000??????????100?????0110011},
  '{"SRL               ", TYPE_R , FMT_R2  , 32'b0000000??????????101?????0110011},
  '{"SRA               ", TYPE_R , FMT_R2  , 32'b0100000??????????101?????0110011},
  '{"OR                ", TYPE_R , FMT_R2  , 32'b0000000??????????110?????0110011},
  '{"AND               ", TYPE_R , FMT_R2  , 32'b0000000??????????111?????0110011},
  '{"ADDIW             ", TYPE_I , FMT_I   , 32'b?????????????????000?????0011011},
  '{"SLLIW             ", TYPE_R , FMT_I   , 32'b0000000??????????001?????0011011},
  '{"SRLIW             ", TYPE_R , FMT_I   , 32'b0000000??????????101?????0011011},
  '{"SRAIW             ", TYPE_R , FMT_I   , 32'b0100000??????????101?????0011011},
  '{"ADDW              ", TYPE_R , FMT_R2  , 32'b0000000??????????000?????0111011},
  '{"SUBW              ", TYPE_R , FMT_R2  , 32'b0100000??????????000?????0111011},
  '{"SLLW              ", TYPE_R , FMT_R2  , 32'b0000000??????????001?????0111011},
  '{"SRLW              ", TYPE_R , FMT_R2  , 32'b0000000??????????101?????0111011},
  '{"SRAW              ", TYPE_R , FMT_R2  , 32'b0100000??????????101?????0111011},
  '{"LB                ", TYPE_I , FMT_LD  , 32'b?????????????????000?????0000011},
  '{"LH                ", TYPE_I , FMT_LD  , 32'b?????????????????001?????0000011},
  '{"LW                ", TYPE_I , FMT_LD  , 32'b?????????????????010?????0000011},
  '{"LD                ", TYPE_I , FMT_LD  , 32'b?????????????????011?????0000011},
  '{"LBU               ", TYPE_I , FMT_LD  , 32'b?????????????????100?????0000011},
  '{"LHU               ", TYPE_I , FMT_LD  , 32'b?????????????????101?????0000011},
  '{"LWU               ", TYPE_I , FMT_LD  , 32'b?????????????????110?????0000011},
  '{"SB                ", TYPE_S , FMT_ST  , 32'b?????????????????000?????0100011},
  '{"SH                ", TYPE_S , FMT_ST  , 32'b?????????????????001?????0100011},
  '{"SW                ", TYPE_S , FMT_ST  , 32'b?????????????????010?????0100011},
  '{"SD                ", TYPE_S , FMT_ST  , 32'b?????????????????011?????0100011},
  '{"FENCE             ", TYPE_X , FMT_0   , 32'b?????????????????000?????0001111},
  '{"FENCE.I           ", TYPE_X , FMT_0   , 32'b?????????????????001?????0001111},
  '{"MUL               ", TYPE_R , FMT_R2  , 32'b0000001??????????000?????0110011},
  '{"MULH              ", TYPE_R , FMT_R2  , 32'b0000001??????????001?????0110011},
  '{"MULHSU            ", TYPE_R , FMT_R2  , 32'b0000001??????????010?????0110011},
  '{"MULHU             ", TYPE_R , FMT_R2  , 32'b0000001??????????011?????0110011},
  '{"DIV               ", TYPE_R , FMT_R2  , 32'b0000001??????????100?????0110011},
  '{"DIVU              ", TYPE_R , FMT_R2  , 32'b0000001??????????101?????0110011},
  '{"REM               ", TYPE_R , FMT_R2  , 32'b0000001??????????110?????0110011},
  '{"REMU              ", TYPE_R , FMT_R2  , 32'b0000001??????????111?????0110011},
  '{"MULW              ", TYPE_R , FMT_R2  , 32'b0000001??????????000?????0111011},
  '{"DIVW              ", TYPE_R , FMT_R2  , 32'b0000001??????????100?????0111011},
  '{"DIVUW             ", TYPE_R , FMT_R2  , 32'b0000001??????????101?????0111011},
  '{"REMW              ", TYPE_R , FMT_R2  , 32'b0000001??????????110?????0111011},
  '{"REMUW             ", TYPE_R , FMT_R2  , 32'b0000001??????????111?????0111011},
  '{"AMOADD.W          ", TYPE_R , FMT_AMO , 32'b00000????????????010?????0101111},
  '{"AMOXOR.W          ", TYPE_R , FMT_AMO , 32'b00100????????????010?????0101111},
  '{"AMOOR.W           ", TYPE_R , FMT_AMO , 32'b01000????????????010?????0101111},
  '{"AMOAND.W          ", TYPE_R , FMT_AMO , 32'b01100????????????010?????0101111},
  '{"AMOMIN.W          ", TYPE_R , FMT_AMO , 32'b10000????????????010?????0101111},
  '{"AMOMAX.W          ", TYPE_R , FMT_AMO , 32'b10100????????????010?????0101111},
  '{"AMOMINU.W         ", TYPE_R , FMT_AMO , 32'b11000????????????010?????0101111},
  '{"AMOMAXU.W         ", TYPE_R , FMT_AMO , 32'b11100????????????010?????0101111},
  '{"AMOSWAP.W         ", TYPE_R , FMT_AMO , 32'b00001????????????010?????0101111},
  '{"LR.W              ", TYPE_X , FMT_AMO , 32'b00010??00000?????010?????0101111},
  '{"SC.W              ", TYPE_R , FMT_AMO , 32'b00011????????????010?????0101111},
  '{"AMOADD.D          ", TYPE_R , FMT_AMO , 32'b00000????????????011?????0101111},
  '{"AMOXOR.D          ", TYPE_R , FMT_AMO , 32'b00100????????????011?????0101111},
  '{"AMOOR.D           ", TYPE_R , FMT_AMO , 32'b01000????????????011?????0101111},
  '{"AMOAND.D          ", TYPE_R , FMT_AMO , 32'b01100????????????011?????0101111},
  '{"AMOMIN.D          ", TYPE_R , FMT_AMO , 32'b10000????????????011?????0101111},
  '{"AMOMAX.D          ", TYPE_R , FMT_AMO , 32'b10100????????????011?????0101111},
  '{"AMOMINU.D         ", TYPE_R , FMT_AMO , 32'b11000????????????011?????0101111},
  '{"AMOMAXU.D         ", TYPE_R , FMT_AMO , 32'b11100????????????011?????0101111},
  '{"AMOSWAP.D         ", TYPE_R , FMT_AMO , 32'b00001????????????011?????0101111},
  '{"LR.D              ", TYPE_X , FMT_AMO , 32'b00010??00000?????011?????0101111},
  '{"SC.D              ", TYPE_R , FMT_AMO , 32'b00011????????????011?????0101111},
  '{"SCALL             ", TYPE_X , FMT_0   , 32'b00000000000000000000000001110011},
  '{"SBREAK            ", TYPE_X , FMT_0   , 32'b00000000000100000000000001110011},
  '{"SRET              ", TYPE_X , FMT_0   , 32'b10000000000000000000000001110011},
  '{"CSRRW             ", TYPE_X , FMT_I   , 32'b?????????????????001?????1110011},
  '{"CSRRS             ", TYPE_X , FMT_I   , 32'b?????????????????010?????1110011},
  '{"CSRRC             ", TYPE_X , FMT_I   , 32'b?????????????????011?????1110011},
  '{"CSRRWI            ", TYPE_X , FMT_I   , 32'b?????????????????101?????1110011},
  '{"CSRRSI            ", TYPE_X , FMT_I   , 32'b?????????????????110?????1110011},
  '{"CSRRCI            ", TYPE_X , FMT_I   , 32'b?????????????????111?????1110011},
//  '{"FADD_S            ", TYPE_,32'b0000000??????????????????1010011},
//  '{"FSUB_S            ", TYPE_,32'b0000100??????????????????1010011},
//  '{"FMUL_S            ", TYPE_,32'b0001000??????????????????1010011},
//  '{"FDIV_S            ", TYPE_,32'b0001100??????????????????1010011},
//  '{"FSGNJ_S           ", TYPE_,32'b0010000??????????000?????1010011},
//  '{"FSGNJN_S          ", TYPE_,32'b0010000??????????001?????1010011},
//  '{"FSGNJX_S          ", TYPE_,32'b0010000??????????010?????1010011},
//  '{"FMIN_S            ", TYPE_,32'b0010100??????????000?????1010011},
//  '{"FMAX_S            ", TYPE_,32'b0010100??????????001?????1010011},
//  '{"FSQRT_S           ", TYPE_,32'b010110000000?????????????1010011},
//  '{"FADD_D            ", TYPE_,32'b0000001??????????????????1010011},
//  '{"FSUB_D            ", TYPE_,32'b0000101??????????????????1010011},
//  '{"FMUL_D            ", TYPE_,32'b0001001??????????????????1010011},
//  '{"FDIV_D            ", TYPE_,32'b0001101??????????????????1010011},
//  '{"FSGNJ_D           ", TYPE_,32'b0010001??????????000?????1010011},
//  '{"FSGNJN_D          ", TYPE_,32'b0010001??????????001?????1010011},
//  '{"FSGNJX_D          ", TYPE_,32'b0010001??????????010?????1010011},
//  '{"FMIN_D            ", TYPE_,32'b0010101??????????000?????1010011},
//  '{"FMAX_D            ", TYPE_,32'b0010101??????????001?????1010011},
//  '{"FCVT_S_D          ", TYPE_,32'b010000000001?????????????1010011},
//  '{"FCVT_D_S          ", TYPE_,32'b010000100000?????????????1010011},
//  '{"FSQRT_D           ", TYPE_,32'b010110100000?????????????1010011},
//  '{"FLE_S             ", TYPE_,32'b1010000??????????000?????1010011},
//  '{"FLT_S             ", TYPE_,32'b1010000??????????001?????1010011},
//  '{"FEQ_S             ", TYPE_,32'b1010000??????????010?????1010011},
//  '{"FLE_D             ", TYPE_,32'b1010001??????????000?????1010011},
//  '{"FLT_D             ", TYPE_,32'b1010001??????????001?????1010011},
//  '{"FEQ_D             ", TYPE_,32'b1010001??????????010?????1010011},
//  '{"FCVT_W_S          ", TYPE_,32'b110000000000?????????????1010011},
//  '{"FCVT_WU_S         ", TYPE_,32'b110000000001?????????????1010011},
//  '{"FCVT_L_S          ", TYPE_,32'b110000000010?????????????1010011},
//  '{"FCVT_LU_S         ", TYPE_,32'b110000000011?????????????1010011},
//  '{"FMV_X_S           ", TYPE_,32'b111000000000?????000?????1010011},
//  '{"FCLASS_S          ", TYPE_,32'b111000000000?????001?????1010011},
//  '{"FCVT_W_D          ", TYPE_,32'b110000100000?????????????1010011},
//  '{"FCVT_WU_D         ", TYPE_,32'b110000100001?????????????1010011},
//  '{"FCVT_L_D          ", TYPE_,32'b110000100010?????????????1010011},
//  '{"FCVT_LU_D         ", TYPE_,32'b110000100011?????????????1010011},
//  '{"FMV_X_D           ", TYPE_,32'b111000100000?????000?????1010011},
//  '{"FCLASS_D          ", TYPE_,32'b111000100000?????001?????1010011},
//  '{"FCVT_S_W          ", TYPE_,32'b110100000000?????????????1010011},
//  '{"FCVT_S_WU         ", TYPE_,32'b110100000001?????????????1010011},
//  '{"FCVT_S_L          ", TYPE_,32'b110100000010?????????????1010011},
//  '{"FCVT_S_LU         ", TYPE_,32'b110100000011?????????????1010011},
//  '{"FMV_S_X           ", TYPE_,32'b111100000000?????000?????1010011},
//  '{"FCVT_D_W          ", TYPE_,32'b110100100000?????????????1010011},
//  '{"FCVT_D_WU         ", TYPE_,32'b110100100001?????????????1010011},
//  '{"FCVT_D_L          ", TYPE_,32'b110100100010?????????????1010011},
//  '{"FCVT_D_LU         ", TYPE_,32'b110100100011?????????????1010011},
//  '{"FMV_D_X           ", TYPE_,32'b111100100000?????000?????1010011},
//  '{"FLW               ", TYPE_,32'b?????????????????010?????0000111},
//  '{"FLD               ", TYPE_,32'b?????????????????011?????0000111},
//  '{"FSW               ", TYPE_,32'b?????????????????010?????0100111},
//  '{"FSD               ", TYPE_,32'b?????????????????011?????0100111},
//  '{"FMADD_S           ", TYPE_,32'b?????00??????????????????1000011},
//  '{"FMSUB_S           ", TYPE_,32'b?????00??????????????????1000111},
//  '{"FNMSUB_S          ", TYPE_,32'b?????00??????????????????1001011},
//  '{"FNMADD_S          ", TYPE_,32'b?????00??????????????????1001111},
//  '{"FMADD_D           ", TYPE_,32'b?????01??????????????????1000011},
//  '{"FMSUB_D           ", TYPE_,32'b?????01??????????????????1000111},
//  '{"FNMSUB_D          ", TYPE_,32'b?????01??????????????????1001011},
//  '{"FNMADD_D          ", TYPE_,32'b?????01??????????????????1001111},
//  '{"CUSTOM0           ", TYPE_,32'b?????????????????000?????0001011},
//  '{"CUSTOM0_RS1       ", TYPE_,32'b?????????????????010?????0001011},
//  '{"CUSTOM0_RS1_RS2   ", TYPE_,32'b?????????????????011?????0001011},
//  '{"CUSTOM0_RD        ", TYPE_,32'b?????????????????100?????0001011},
//  '{"CUSTOM0_RD_RS1    ", TYPE_,32'b?????????????????110?????0001011},
//  '{"CUSTOM0_RD_RS1_RS2", TYPE_,32'b?????????????????111?????0001011},
//  '{"CUSTOM1           ", TYPE_,32'b?????????????????000?????0101011},
//  '{"CUSTOM1_RS1       ", TYPE_,32'b?????????????????010?????0101011},
//  '{"CUSTOM1_RS1_RS2   ", TYPE_,32'b?????????????????011?????0101011},
//  '{"CUSTOM1_RD        ", TYPE_,32'b?????????????????100?????0101011},
//  '{"CUSTOM1_RD_RS1    ", TYPE_,32'b?????????????????110?????0101011},
//  '{"CUSTOM1_RD_RS1_RS2", TYPE_,32'b?????????????????111?????0101011},
//  '{"CUSTOM2           ", TYPE_,32'b?????????????????000?????1011011},
//  '{"CUSTOM2_RS1       ", TYPE_,32'b?????????????????010?????1011011},
//  '{"CUSTOM2_RS1_RS2   ", TYPE_,32'b?????????????????011?????1011011},
//  '{"CUSTOM2_RD        ", TYPE_,32'b?????????????????100?????1011011},
//  '{"CUSTOM2_RD_RS1    ", TYPE_,32'b?????????????????110?????1011011},
//  '{"CUSTOM2_RD_RS1_RS2", TYPE_,32'b?????????????????111?????1011011},
//  '{"CUSTOM3           ", TYPE_,32'b?????????????????000?????1111011},
//  '{"CUSTOM3_RS1       ", TYPE_,32'b?????????????????010?????1111011},
//  '{"CUSTOM3_RS1_RS2   ", TYPE_,32'b?????????????????011?????1111011},
//  '{"CUSTOM3_RD        ", TYPE_,32'b?????????????????100?????1111011},
//  '{"CUSTOM3_RD_RS1    ", TYPE_,32'b?????????????????110?????1111011},
//  '{"CUSTOM3_RD_RS1_RS2", TYPE_,32'b?????????????????111?????1111011},
  '{"NOP               ", TYPE_0 , FMT_0  , 32'b00000000000000000000000000010011},
  '{"-                 ", TYPE_0 , FMT_0  , 32'b00000000000000000100000000110011}  // 32'h00004033 - machine generated bubble
};

///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////

typedef bit [3-1:0] [8-1:0] rs3;
typedef bit [4-1:0] [8-1:0] rs4;

parameter rs3 [0:31] REG_X = '{" x0", " ra", " s0", " s1", " s2", " s3", " s4", " s5", " s6", " s7", " s8", " s9", "s10", "s11", " sp", " tp",
                               " v0", " v1", " a0", " a1", " a2", " a3", " a4", " a5", " a6", " a7", " a8", " a9", "a10", "a11", "a12", "a13"};
parameter rs4 [0:31] REG_F = '{" fs0"," fs1"," fs2"," fs3"," fs4"," fs5"," fs6"," fs7"," fs8"," fs9","fs10","fs11","fs12","fs13","fs14","fs15",
                               " fv0"," fv1"," fa0"," fa1"," fa2"," fa3"," fa4"," fa5"," fa6"," fa7"," fa8"," fa9","fa10","fa11","fa12","fa13"};
parameter rs4 [0:31] REG_P = '{" cr0"," cr1"," cr2"," cr3"," cr4"," cr5"," cr6"," cr7"," cr8"," cr9","cr10","cr11","cr12","cr13","cr14","cr15",
                               "cr16","cr17","cr18","cr19","cr20","cr21","cr22","cr23","cr24","cr25","cr26","cr27","cr28","cr29","cr30","cr31"};

///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////

function string dis (t_format code);

logic [32-1:0] imm;
t_opcode op;


for (int i=0; i<$size(opcode); i++) begin
  op = op;
  if (code ==? op.bin) begin
    imm = immediate(code, op.typ);
    case (op.fmt)
//      TYPE_R4: dis = $sformatf("%s r%0d, r%0d, r%0d, r%0d"  , op.nam, code.r4.rd, code.r4.rs1, code.r4.rs2, code.r4.rs3);
//      TYPE_R : dis = $sformatf("%s r%0d, r%0d, r%0d"        , op.nam, code.r .rd, code.r .rs1, code.r .rs2          );
//      TYPE_I : dis = $sformatf("%s r%0d, r%0d, 0x3%x # (%d)", op.nam, code.i .rd, code.i .rs1,              imm, imm);
//      TYPE_S : dis = $sformatf("%s r%0d, r%0d, 0x3%x # (%d)", op.nam,             code.s .rs1, code.s .rs2, imm, imm);
//      TYPE_SB: dis = $sformatf("%s r%0d, r%0d, 0x3%x # (%d)", op.nam,             code.sb.rs1, code.sb.rs2, imm, imm);
//      TYPE_U : dis = $sformatf("%s r%0d, 0x3%x # (%d)"      , op.nam, code.u .rd,                           imm, imm);
//      TYPE_UJ: dis = $sformatf("%s r%0d, 0x3%x # (%d)"      , op.nam, code.uj.rd,                           imm, imm);
//      TYPE_0 : dis = $sformatf("%s"                         , op.nam                                                );
//      default: dis =           "unknown"; // TODO

//      FMT_R2  : dis = $sformatf("%s r%0d, r%0d, r%0d"        , op.nam, code.r .rd, code.r .rs1, code.r .rs2          );
//      FMT_0   : dis = $sformatf("%s"                         , op.nam                                                );
//      TYPE_I  : dis = $sformatf("%s r%0d, r%0d, 0x3%x # (%d)", op.nam, code.i .rd, code.i .rs1,              imm, imm);
//      FMT_B   : dis = $sformatf("%s r%0d, r%0d, 0x3%x # (%d)", op.nam,             code.sb.rs1, code.sb.rs2, imm, imm);

      FMT_R2  :  dis = $sformatf("%s %s, %s, %s"        , op.nam, REG_X[code.r .rd],      REG_X[code.r .rs1], REG_X[code.r .rs2]     );
      FMT_0   :  dis = $sformatf("%s"                   , op.nam                                                                     );
      FMT_I   :  dis = $sformatf("%s %s, %s, 0x3%x"     , op.nam, REG_X[code.i .rd],      REG_X[code.i .rs1],                     imm);
      FMT_B   :  dis = $sformatf("%s %s, %s, 0x3%x"     , op.nam,                         REG_X[code.sb.rs1], REG_X[code.sb.rs2], imm);
      FMT_J   :  dis = $sformatf("%s 0x3%x"             , op.nam,                                                                 imm);
      FMT_L   :  dis = $sformatf("%s %s, 0x3%x"         , op.nam, REG_X[code.uj.rd],                                              imm);
      FMT_L   :  dis = $sformatf("%s %s, 0x3%x(%s)"     , op.nam, REG_X[code.uj.rd], imm, REG_X[code.i .rs1],                     imm);
      FMT_L   :  dis = $sformatf("%s %s, 0x3%x(%s)"     , op.nam, REG_X[code.uj.rd], imm, REG_X[code.i .rs1],                     imm);
      FMT_AMO :  dis = $sformatf("%s %s, %s, %s"        , op.nam, REG_X[code.r .rd],      REG_X[code.r .rs1], REG_X[code.r .rs2]     );
      default :  dis =           "unknown";
    endcase
  end
end

endfunction

///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////

//function logic [32-1:0] asm (
//  input byte [128-1:0] str;
//);
//endfunction

endpackage: riscv_asm
