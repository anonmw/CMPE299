module main(CLK, RST);
    parameter WIDTH = 32;

    input CLK, RST;

    // IF_ fetch stage
    reg [WIDTH-1:0] IF_PC;
    wire [WIDTH-1:0] nextPC;
    // need a stall signal, squash signal
    
    //forward declare jump/branch address variables
    wire [WIDTH-1:0] ID_branchAddr, ID_jumpAddr;
    //forward declare isIssue and issue busy signal
    wire ID_issue_busy;
    wire ID_isIssue;
    
    assign nextPC = (ID_isIssue & ID_issue_busy) ? IF_PC :
                    (ID_isBranch) ? ID_branchAddr: 
                    (ID_isJump)   ? ID_jumpAddr :
                                    IF_PC + 4; // TODO add simple TLB
    
    always @ (posedge CLK or posedge RST) begin
        if (RST == 1) begin
            IF_PC <= 32'h00000000;
        end
        else begin
            IF_PC <= nextPC;
        end
    end
    
    wire [WIDTH-1:0] IF_instruction;
    
    icache icache(IF_PC, IF_instruction, CLK, RST);
    
    //reg [WIDTH-1:0] IF_ID_instruction;
    
    // ID_ decode stage
    // decode fields, split ID_EX_instruction
    // send result back to ID stage, clean up relevant registers
    /*
        OPIMM
        OP
        JAL
        JALR
        BRANCH
        LOAD
        STORE
    
        R I S B U J formats
        clean up immediates for I S B U J
        
        generate control signals
    */
    
    wire [WIDTH-1:0] ID_instruction = IF_instruction;
    wire [WIDTH-1:0] ID_PC = IF_PC;
    // break up instruction into all possible fields
    parameter OPCODE_HI = 6;
    parameter OPCODE_LO = 0;
    parameter FUNCT3_HI = 14;
    parameter FUNCT3_LO = 12;
    parameter RD_HI = 11;
    parameter RD_LO = 7;
    parameter RS1_HI = 19;
    parameter RS1_LO = 15;
    parameter IMM_11_0_HI = 31;
    parameter IMM_11_0_LO = 20;
    parameter IMM_SHAMT_HI = 24;
    parameter IMM_SHAMT_LO = 20;
    parameter IMM_11_5_HI = 31;
    parameter IMM_11_5_LO = 25;
    parameter IMM_31_12_HI = 31;
    parameter IMM_31_12_LO = 12;
    parameter FUNCT7_HI = 31;
    parameter FUNCT7_LO = 25;
    parameter RS2_HI = 24;
    parameter RS2_LO = 20;
    parameter IMM_20_HI = 31;
    parameter IMM_20_LO = 31;
    parameter IMM_10_1_HI = 30;
    parameter IMM_10_1_LO = 21;
    parameter IMM_11_J_HI = 20;
    parameter IMM_11_J_LO = 20;
    parameter IMM_19_12_HI = 19;
    parameter IMM_19_12_LO = 12;
    parameter IMM_12_HI = 31;
    parameter IMM_12_LO = 31;
    parameter IMM_10_5_HI = 30;
    parameter IMM_10_5_LO = 25;
    parameter IMM_4_1_HI = 11;
    parameter IMM_4_1_LO = 8;
    parameter IMM_11_B_HI = 7;
    parameter IMM_11_B_LO = 7;
    parameter IMM_4_0_HI = 11;
    parameter IMM_4_0_LO = 7;
        
    wire [OPCODE_HI-OPCODE_LO:0]        ID_opcode =     ID_instruction[OPCODE_HI:OPCODE_LO];
    wire [FUNCT3_HI-FUNCT3_LO:0]        ID_funct3 =     ID_instruction[FUNCT3_HI:FUNCT3_LO];
    wire [RD_HI-RD_LO:0]                ID_rd =         ID_instruction[RD_HI:RD_LO];
    wire [RS1_HI-RS1_LO:0]              ID_rs1 =        ID_instruction[RS1_HI:RS1_LO];
    wire [IMM_11_0_HI-IMM_11_0_LO:0]    ID_imm_11_0 =   ID_instruction[IMM_11_0_HI:IMM_11_0_LO];
    wire [IMM_SHAMT_HI-IMM_SHAMT_LO:0]  ID_imm_SHAMT =  ID_instruction[IMM_SHAMT_HI:IMM_SHAMT_LO];
    wire [IMM_11_5_HI-IMM_11_5_LO:0]    ID_imm_11_5 =   ID_instruction[IMM_11_5_HI:IMM_11_5_LO];
    wire [IMM_31_12_HI-IMM_31_12_LO:0]  ID_imm_31_12 =  ID_instruction[IMM_31_12_HI:IMM_31_12_LO];
    wire [FUNCT7_HI-FUNCT7_LO:0]        ID_funct7 =     ID_instruction[FUNCT7_HI:FUNCT7_LO];
    wire [RS2_HI-RS2_LO:0]              ID_rs2 =        ID_instruction[RS2_HI:RS2_LO];
    wire [IMM_20_HI-IMM_20_LO:0]        ID_imm_20 =     ID_instruction[IMM_20_HI:IMM_20_LO];
    wire [IMM_10_1_HI-IMM_10_1_LO:0]    ID_imm_10_1 =   ID_instruction[IMM_10_1_HI:IMM_10_1_LO];
    wire [IMM_11_J_HI-IMM_11_J_LO:0]    ID_imm_11_J =   ID_instruction[IMM_11_J_HI:IMM_11_J_LO];
    wire [IMM_19_12_HI-IMM_19_12_LO:0]  ID_imm_19_12 =  ID_instruction[IMM_19_12_HI:IMM_19_12_LO];
    wire [IMM_12_HI-IMM_12_LO:0]        ID_imm_12 =     ID_instruction[IMM_12_HI:IMM_12_LO];
    wire [IMM_10_5_HI-IMM_10_5_LO:0]    ID_imm_10_5 =   ID_instruction[IMM_10_5_HI:IMM_10_5_LO];
    wire [IMM_4_1_HI-IMM_4_1_LO:0]      ID_imm_4_1 =    ID_instruction[IMM_4_1_HI:IMM_4_1_LO];
    wire [IMM_11_B_HI-IMM_11_B_LO:0]    ID_imm_11_B =   ID_instruction[IMM_11_B_HI:IMM_11_B_LO];
    wire [IMM_4_0_HI-IMM_4_0_LO:0]      ID_imm_4_0 =    ID_instruction[IMM_4_0_HI:IMM_4_0_LO];
    
    // construct I S B U J immediates
    parameter SEXT_HI = 31;
    parameter SEXT_LO = 12;
    parameter SEXT_J_HI = 19;
    parameter SEXT_J_LO = 8;
    // calculate sign extends for immediates
    wire [SEXT_HI-SEXT_LO:0] ID_sext = IF_instruction[31] ? 20'hfffff: 20'h00000;
    
    // concatenate immediates together
    wire [WIDTH-1:0] ID_imm_I = {ID_sext, ID_imm_11_0};
    wire [WIDTH-1:0] ID_imm_S = {ID_sext, ID_imm_11_5, ID_imm_4_0};
    wire [WIDTH-1:0] ID_imm_B = {ID_sext, ID_imm_11_B, ID_imm_10_5, ID_imm_4_1, 1'b0};
    wire [WIDTH-1:0] ID_imm_U = {ID_imm_31_12, 12'h000};
    wire [WIDTH-1:0] ID_imm_J = {ID_sext[SEXT_J_HI:SEXT_J_LO], ID_imm_19_12, ID_imm_11_J, ID_imm_10_1, 1'b0};
    
    // control signals
    // isJump, isBranch
    // memRead, memWrite, memToReg
    // aluOP, aluAlt - bit 30 of logic/arithmetic instructions
    // aluSrc - source of second alu operand, either immediate or regB
    // regWrite
    parameter OPCODE_OPIMM = 7'b0010011;
    parameter OPCODE_OP = 7'b0110011;
    parameter OPCODE_LUI = 7'b0110111;
    parameter OPCODE_AUIPC = 7'b0010111;
    parameter OPCODE_JAL = 7'b1101111;
    parameter OPCODE_JALR = 7'b1100111;
    parameter OPCODE_BRANCH = 7'b1100011;
    parameter OPCODE_LOAD = 7'b0000011;
    parameter OPCODE_STORE = 7'b0100011;
    
    parameter OPCODE_ARRAY_ADD =    7'b1111000;
    parameter OPCODE_ARRAY_MULT =   7'b1111001;
    parameter OPCODE_ARRAY_LOAD =   7'b1111010;
    parameter OPCODE_ARRAY_STORE =  7'b1111011;
    parameter OPCODE_ARRAY_RELU =   7'b1111100;
    
    parameter FUNCT7_ALT = 5;
    
    parameter FUNCT3_ADD = 3'b000;
    parameter FUNCT3_SUB = 3'b000;
    parameter FUNCT3_SLT = 3'b010;
    parameter FUNCT3_SLTU = 3'b011;
    parameter FUNCT3_AND = 3'b111;
    parameter FUNCT3_OR = 3'b110;
    parameter FUNCT3_XOR = 3'b100;
    parameter FUNCT3_SLL = 3'b001;
    parameter FUNCT3_SRL = 3'b101;
    parameter FUNCT3_SRA = 3'b101;

    wire doBranch;
    wire ID_isJump = (ID_opcode == OPCODE_JAL) || (ID_opcode == OPCODE_JALR); // in this case regA is pc+4, we can cheat and take IF_PC from previous stage
    wire ID_isBranch = (ID_opcode == OPCODE_BRANCH) & doBranch; //TODO this needs to actually determine if branch occurs (compare regA regB using comparator
    wire ID_memRead = (ID_opcode == OPCODE_LOAD);
    wire ID_memWrite = (ID_opcode == OPCODE_STORE);
    wire ID_memToReg = ID_memRead;
    wire ID_aluSrc = (ID_opcode == OPCODE_OP); //if 1 use regB else use immediate
    wire ID_aluAlt = (ID_aluSrc && (ID_funct3 == FUNCT3_ADD)) || (((ID_opcode == OPCODE_OP) || (ID_opcode == OPCODE_OPIMM)) && (ID_funct3 == FUNCT3_SRL)) ? ID_funct7[FUNCT7_ALT] : 1'b0;// this bit only matters for op-add/sub and op/opimm sr, else 0
    wire ID_regWrite = (ID_opcode == OPCODE_OP) || (ID_opcode == OPCODE_OPIMM) || (ID_opcode == OPCODE_AUIPC) || (ID_opcode == OPCODE_LUI) || (ID_opcode == OPCODE_JAL) || (ID_opcode == OPCODE_JALR) || (ID_opcode == OPCODE_LOAD); // Everything but branch and store update a register, JAL[R] instructions store pc+4 into rd
    wire ID_isAUIPC = (ID_opcode == OPCODE_AUIPC); // regA = pc in this case only
    wire ID_isLUI = (ID_opcode == OPCODE_LUI); // use imm_U as regB, regA is r0
    wire [FUNCT3_HI-FUNCT3_LO:0] ID_aluOp = (ID_opcode == OPCODE_LOAD) || (ID_opcode == OPCODE_STORE) || ID_isJump || ID_isAUIPC || ID_isLUI ? 3'b000 : ID_funct3; //this is funct3 for op/opimm, or manually set to add for load/store, JAL/JALR, LUI/AUIPC
    // immediate selector that goes into execute stage to determine alu input
    // stores use the weird disjointed s type immediate, LUI/AUIPC uses U, everything else relevant uses I type
    // B/J type immediates are handled in decode stage entirely for PC calculations
    wire [WIDTH-1:0] ID_imm = (ID_opcode == OPCODE_STORE) ? ID_imm_S : //store immediate goes through pipeline
                              (ID_isLUI || ID_isAUIPC) ? ID_imm_U: //LUI/AUIPC immediates must go through pipeline writeback
                              ID_imm_I; // all other immediates
                              //JAL/JALR immediates are consumed in decode stage for address calculation
    
    wire [WIDTH-1:0] ID_regA, ID_regB;// rename to reg1, reg2?
    
    //Branch Logic
    parameter FUNCT3_BEQ = 3'b000;
    parameter FUNCT3_BNE = 3'b001;
    parameter FUNCT3_BLT = 3'b100;
    parameter FUNCT3_BLTU = 3'b101;
    parameter FUNCT3_BGE = 3'b110;
    parameter FUNCT3_BGEU = 3'b111;
    
    
    wire branchEquals = ID_regA == ID_regB;
    wire branchNotEquals = ~branchEquals;
    // if both signs are the same, then a simple less than works
    // if regA is negative and regB is positive then return 1
    // if regA is positive and regB is negative then return 0
    wire branchLessThan = ID_regA[31] & ~ID_regB[31] ? 1'b1 :
                          ~ID_regA[31] & ID_regB[31] ? 1'b0 :
                          ID_regA < ID_regB;
    wire branchLessThanUnsigned = ID_regA < ID_regB;
    wire branchGreaterEquals = ~branchLessThan;
    wire branchGreaterEqualsUnsigned = ~branchGreaterEquals;
    assign doBranch = ((ID_funct3 == FUNCT3_BEQ) & branchEquals) | ((ID_funct3 == FUNCT3_BNE) & branchNotEquals) |
                    ((ID_funct3 == FUNCT3_BLT) & branchLessThan) | ((ID_funct3 == FUNCT3_BGE) & branchGreaterEquals) |
                    ((ID_funct3 == FUNCT3_BLTU) & branchLessThanUnsigned) | ((ID_funct3 == FUNCT3_BGEU) & branchGreaterEqualsUnsigned);
    
    //forward declare WB stage stuff for register file
    wire [RD_HI-RD_LO:0] WB_rd;
    wire [WIDTH-1:0] WB_writeData;
    wire WB_regWrite;
    regfile registerfile(ID_rs1, ID_rs2, WB_rd, WB_writeData, WB_regWrite, ID_regA, ID_regB, CLK, RST);
    
    assign ID_branchAddr = ID_PC + ID_imm_B;
    assign ID_jumpAddr = (ID_opcode == OPCODE_JAL) ?    ID_imm_J + ID_PC :
                         (ID_opcode == OPCODE_JALR) ?   ID_regA + ID_imm_I : // this is technically wrong, should set least significant bit to 0
                                                        ID_PC + 8;// default case, never used
    
    /****************** issue logic ******************/
    wire [RD_HI-RD_LO:0] ID_issue_rd, ID_issue_rs1, ID_issue_rs2;
    wire [WIDTH-1:0] ID_issue_regval1, ID_issue_regval2;
    
    assign ID_issue_rd = ID_rd;
    assign ID_issue_rs1 = (ID_opcode == OPCODE_ARRAY_STORE) ? ID_rd : ID_rs1; // rd is reg index for stores
    assign ID_issue_rs2 = ID_rs2;
    assign ID_issue_regval1 = ID_regA; // memory base address, always rs1
    // stride is quad word aligned (every eighth byte, i.e. 64byte vectors)
    assign ID_issue_regval2 = {ID_imm_I[28:0], 3'b000};
    
    assign ID_isIssue = (ID_opcode == OPCODE_ARRAY_ADD) || (ID_opcode == OPCODE_ARRAY_MULT) || (ID_opcode == OPCODE_ARRAY_LOAD) || (ID_opcode == OPCODE_ARRAY_STORE) || (ID_opcode == OPCODE_ARRAY_RELU);
    
    issue arrayissue(ID_opcode, ID_issue_rd, ID_issue_rs1, ID_issue_rs2, ID_issue_regval1, ID_issue_regval2, ID_isIssue, ID_issue_busy, CLK, RST);
    /*************************************************/
    
    
    // EX_ execute stage
    wire [WIDTH-1:0] EX_PC = ID_PC;
    wire [RD_HI-RD_LO:0] EX_rd = ID_rd;
    wire [FUNCT3_HI-FUNCT3_LO:0] EX_aluOp = ID_aluOp;
    wire [FUNCT3_HI-FUNCT3_LO:0] EX_funct3 = ID_funct3;
    wire EX_isJump = ID_isJump;
    wire EX_memRead = ID_memRead;
    wire EX_memWrite = ID_memWrite;
    wire EX_memToReg = ID_memToReg;
    wire EX_aluAlt = ID_aluAlt;
    wire EX_aluSrc = ID_aluSrc; //same as OPCODE_OP basically
    wire EX_regWrite = ID_regWrite;
    wire EX_isAUIPC = ID_isAUIPC;
    wire EX_isLUI = ID_isLUI;
    wire [WIDTH-1:0] EX_regA, EX_regB;
    wire [WIDTH-1:0] EX_val1, EX_val2;
    wire [WIDTH-1:0] EX_imm = ID_imm;
    wire [WIDTH-1:0] EX_aluOut;
    assign EX_regA = ID_regA;
    assign EX_regB = ID_regB;
    
    // mux for alu operand 1, this is 0 for LUI instructions, PC for AUIPC/Jump, else just register A output
    assign EX_val1 = EX_isAUIPC || EX_isJump ? EX_PC :
                     EX_isLUI ? 32'h00000000 :
                     EX_regA;
                     
    // mux for alu operand 2, this is regB for OP instructions, 4 for jump instructions (pc+4 stored in rd), else immediate
    assign EX_val2 = EX_isJump ? 32'h00000004 :
                     EX_aluSrc ? EX_regB :
                     EX_imm;
                     
    alu alu(EX_val1, EX_val2, EX_aluOp, EX_aluAlt, EX_aluOut);
    
    // ME_ memory stage
    parameter FUNCT3_LB = 3'b000;
    parameter FUNCT3_LH = 3'b001;
    parameter FUNCT3_LW = 3'b010;
    parameter FUNCT3_LBU = 3'b100;
    parameter FUNCT3_LHU = 3'b101;
    
    parameter FUNCT3_SB = 3'b000;
    parameter FUNCT3_SH = 3'b001;
    parameter FUNCT3_SW = 3'b010;
    
    wire [WIDTH-1:0] ME_PC = EX_PC;
    wire [RD_HI-RD_LO:0] ME_rd = EX_rd;
    wire [FUNCT3_HI-FUNCT3_LO:0] ME_funct3 = EX_funct3;
    wire ME_isJump = EX_isJump;
    wire ME_memRead = EX_memRead;
    wire ME_memWrite = EX_memWrite;
    wire ME_memToReg = EX_memToReg;
    wire ME_regWrite = EX_regWrite;
    wire [WIDTH-1:0] ME_regB = EX_regB;
    wire [WIDTH-1:0] ME_aluOut = EX_aluOut;
    wire [WIDTH-1:0] ME_memData;
    wire [WIDTH-1:0] ME_dataIn = (ME_funct3 == FUNCT3_SB) ? 32'h000000ff & ME_regB :
                                 (ME_funct3 == FUNCT3_SH) ? 32'h0000ffff & ME_regB :
                                 ME_regB;//just mask for now, I think this actually requires a read modify write
    wire [WIDTH-1:0] ME_dataOut;
    
    // mask regB input, mask memData output
    dcache dmem(ME_aluOut, ME_dataIn, ME_memRead, ME_memWrite, ME_dataOut, CLK, RST);// TODO bit masks for byte/word read/writes
    
    wire ME_LBsign = ME_dataOut[7];
    wire ME_LHsign = ME_dataOut[15];
    wire [WIDTH-1:0] ME_memSext = (ME_funct3 == FUNCT3_LB) & (ME_LBsign) ? 32'hffffff00 :
                               (ME_funct3 == FUNCT3_LH) & (ME_LHsign) ? 32'hffff0000 :
                               32'h00000000;
    assign ME_memData = (ME_funct3 == FUNCT3_LBU) ? ME_dataOut & 32'h000000ff :
                        (ME_funct3 == FUNCT3_LHU) ? ME_dataOut & 32'h0000ffff :
                        (ME_funct3 == FUNCT3_LB) ? ME_dataOut | ME_memSext :
                        (ME_funct3 == FUNCT3_LH) ? ME_dataOut | ME_memSext :
                        (ME_funct3 == FUNCT3_LW) ? ME_dataOut :
                        ME_dataOut;//mask plus sign extend
    
    // WB_ writeback stage
    wire [WIDTH-1:0] WB_PC = ME_PC;
    assign WB_rd = ME_rd;
    wire WB_isJump = ME_isJump;// TODO maybe delete this
    wire WB_memToReg = ME_memToReg;
    assign WB_regWrite = ME_regWrite;
    wire [WIDTH-1:0] WB_memData = ME_memData;
    wire [WIDTH-1:0] WB_aluOut = ME_aluOut;
    assign WB_writeData = (WB_memToReg == 1) ? WB_memData :
                                               WB_aluOut;

endmodule
