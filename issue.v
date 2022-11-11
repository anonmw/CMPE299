module issue(op, rd, rs1, rs2, regval1, regval2, valid, busy, CLK, RST);
// op, rd, rs1, rs2 for arithmetic
// regA/regB for setting base/stride plus maybe immediate?
// if valid and notbusy then we know the instruction has been latched

    parameter OPCODE_HI = 6;
    parameter OPCODE_LO = 0;
    parameter WIDTH = 32;
    parameter VEC_WIDTH = 64;
    parameter INDEX_WIDTH = 5;
    parameter VECIDX_WIDTH = 7;
    
    parameter OPCODE_ARRAY_ADD = 7'b1111000;
    parameter OPCODE_ARRAY_MULT = 7'b1111001;
    parameter OPCODE_ARRAY_LOAD = 7'b1111010;
    parameter OPCODE_ARRAY_STORE = 7'b1111011;
    parameter OPCODE_ARRAY_RELU =   7'b1111100;
    
    parameter STATE_IDLE    = 6'b000000;
    parameter STATE_MULT0   = 6'b100000; // assert start, read first reg
    parameter STATE_MULT1   = 6'b100001; // deassert start, read second reg
    parameter STATE_MULT2   = 6'b100010; // read third reg
    parameter STATE_MULT3   = 6'b100011; // assert stop, read fourth reg
    parameter STATE_MULT4   = 6'b100100; // deassert stop
    parameter STATE_MULT5   = 6'b100101; // 
    parameter STATE_MULT6   = 6'b100110; // 
    parameter STATE_MULT7   = 6'b100111; //
    parameter STATE_MULT8   = 6'b101000; // write first reg
    parameter STATE_MULT9   = 6'b101001; // write second reg
    parameter STATE_MULT10  = 6'b101010; // write third reg
    parameter STATE_MULT11  = 6'b101011; // write fourth reg
    parameter STATE_LOAD0   = 6'b101100; // read first reg from memory
    parameter STATE_LOAD1   = 6'b101101; // read second reg from memory
    parameter STATE_LOAD2   = 6'b101110; // read third reg from memory
    parameter STATE_LOAD3   = 6'b101111; // read fourth reg from memory
    parameter STATE_STORE0  = 6'b110000; // write first reg from memory
    parameter STATE_STORE1  = 6'b110001; // write second reg from memory
    parameter STATE_STORE2  = 6'b110010; // write third reg from memory
    parameter STATE_STORE3  = 6'b110011; // write fourth reg from memory
    parameter STATE_ADD0    = 6'b110100; // write first reg from memory
    parameter STATE_ADD1    = 6'b110101; // write second reg from memory
    parameter STATE_ADD2    = 6'b110110; // write third reg from memory
    parameter STATE_ADD3    = 6'b110111; // write fourth reg from memory
    parameter STATE_RELU0   = 6'b111000; // write first reg from memory
    parameter STATE_RELU1   = 6'b111001; // write second reg from memory
    parameter STATE_RELU2   = 6'b111010; // write third reg from memory
    parameter STATE_RELU3   = 6'b111011; // write fourth reg from memory

    input wire CLK, RST;
    
    input wire [OPCODE_HI-OPCODE_LO:0] op;
    input wire [INDEX_WIDTH-1:0] rd, rs1, rs2;
    input wire [WIDTH-1:0] regval1, regval2;
    input wire valid;
    output wire busy;
    
    //instruction buffer
    reg ibuf_full;
    reg [OPCODE_HI-OPCODE_LO:0] ibuf_op;
    reg [INDEX_WIDTH-1:0] ibuf_rd, ibuf_rs1, ibuf_rs2;
    reg [WIDTH-1:0] ibuf_regval1, ibuf_regval2;
    wire ibuf_full_next;

    reg [5:0] state_control;
    reg [WIDTH-1:0] base_addr;
    reg [WIDTH-1:0] stride;
    reg [VECIDX_WIDTH-1:0] index1, index2, dstIndex;
    
    wire [VECIDX_WIDTH-1:0] indexA, indexB, writeIndex;
    wire [VEC_WIDTH-1:0] writeData, regA, regB;
    wire regWrite;
    
    wire [VEC_WIDTH-1:0] data_out;
    
    wire [WIDTH-1:0] address;
    wire [VEC_WIDTH-1:0] data_in, dcache_out;
    wire read, write, data_valid;
    
    wire weights_valid, image_valid;
    wire [VEC_WIDTH-1:0] weights_out, image_out;
    
    wire [VEC_WIDTH-1:0] A_in, B_in;
    wire start_in, stop_in, array_valid;
    wire [VEC_WIDTH-1:0] adder_out, array_out, relu_out;
    
    assign data_out = address[15:13] < 3'b100 ? weights_out :
                      address[15:13] < 3'b101 ? image_out :
                      dcache_out;
    
    wire isAdd, isMult, isLoad, isStore;
    assign isAdd = (state_control == STATE_ADD0) || (state_control == STATE_ADD1) || (state_control == STATE_ADD2) || (state_control == STATE_ADD3);
    assign isMult = (state_control == STATE_MULT0) || (state_control == STATE_MULT1) || (state_control == STATE_MULT2) || (state_control == STATE_MULT3) ||
                    (state_control == STATE_MULT4) || (state_control == STATE_MULT5) || (state_control == STATE_MULT6) || (state_control == STATE_MULT7) ||
                    (state_control == STATE_MULT8) || (state_control == STATE_MULT9) || (state_control == STATE_MULT10) || (state_control == STATE_MULT11);
    assign isLoad = (state_control == STATE_LOAD0) || (state_control == STATE_LOAD1) || (state_control == STATE_LOAD2) || (state_control == STATE_LOAD3);
    assign isStore = (state_control == STATE_STORE0) || (state_control == STATE_STORE1) || (state_control == STATE_STORE2) || (state_control == STATE_STORE3);
    assign isRelu = (state_control == STATE_RELU0) || (state_control == STATE_RELU1) || (state_control == STATE_RELU2) || (state_control == STATE_RELU3);

    wire multWrite;
    assign multWrite = (state_control == STATE_MULT8) || (state_control == STATE_MULT9) || (state_control == STATE_MULT10) || (state_control == STATE_MULT11);
    
    
    assign indexA = index1;
    assign indexB = isMult ? {index2[6:2], ~index2[1:0]} :
                             index2;
    assign writeIndex = dstIndex;
    assign writeData = isAdd ? adder_out :
                       isMult ? array_out :
                       isLoad ? data_out :
                       isRelu ? relu_out :
                       64'hdeadbeefdeadbeef;
    assign regWrite = isAdd || multWrite || (isLoad && data_valid) || isRelu;
    assign address = base_addr;
    assign data_in = regA;
    assign read = isLoad;
    assign write = isStore;
    
    assign A_in = regA;
    assign B_in = regB;
    assign start_in = (state_control == STATE_MULT0);
    assign stop_in = (state_control == STATE_MULT3);
    
    regfile_vector register_array(indexA, indexB, writeIndex, writeData, regWrite, regA, regB, CLK, RST);
    dcache_vector dcache_array(address, data_in, read, write, dcache_out, data_valid, CLK, RST);
    dcache_weights weights(address, read, weights_out, weights_valid, CLK, RST);
    dcache_image image(address, read, image_out, image_valid, CLK, RST);
    vecadd_alu_int16_4 vecadder(A_in, B_in, adder_out);
    systolic_array array11(A_in, B_in, start_in, stop_in, array_out, array_valid, CLK, RST);
    relu_int16_4 relu(A_in, relu_out);
    
    /*********************************** Instruction buffer code *************************************/
    // if ibuf is empty, fill it if input instruction is an array op, else keep it empty
    // empty ibuf if state is idle, as instruction ops will be moved to control state machine
    assign ibuf_full_next = ibuf_full ? (state_control != STATE_IDLE) :
                            valid & ((op == OPCODE_ARRAY_ADD) || (op == OPCODE_ARRAY_MULT) || (op == OPCODE_ARRAY_LOAD) || (op == OPCODE_ARRAY_STORE) || (op == OPCODE_ARRAY_RELU));
                            
/*    assign ibuf_full_next = ((ibuf_full == 1'b0) && ((op == OPCODE_ARRAY_ADD) 
                                                  || (op == OPCODE_ARRAY_MULT) 
                                                  || (op == OPCODE_ARRAY_LOAD) 
                                                  || (op == OPCODE_ARRAY_STORE))) 
                         || ~((ibuf_full == 1'b1) && (state_control == STATE_IDLE));*/
    
    assign busy = ibuf_full;
    
    always @(posedge CLK or posedge RST) begin
        if (RST == 1) begin
            ibuf_full <= 1'b0;
            ibuf_op <= 7'b0000000;
            ibuf_rd <= 5'b00000;
            ibuf_rs1 <= 5'b00000;
            ibuf_rs2 <= 5'b00000;
            ibuf_regval1 <= 32'h00000000;
            ibuf_regval2 <= 32'h00000000;
        end else begin
            if (ibuf_full == 1'b1) begin
                ibuf_full <= ibuf_full_next;
                ibuf_op <= ibuf_op;
                ibuf_rd <= ibuf_rd;
                ibuf_rs1 <= ibuf_rs1;
                ibuf_rs2 <= ibuf_rs2;
                ibuf_regval1 <= ibuf_regval1;
                ibuf_regval2 <= ibuf_regval2;
            end else begin //ibuf_full == 1'b0
                ibuf_full <= ibuf_full_next;
                ibuf_op <= op;
                ibuf_rd <= rd;
                ibuf_rs1 <= rs1;
                ibuf_rs2 <= rs2;
                ibuf_regval1 <= regval1;
                ibuf_regval2 <= regval2;
            end
        end
    end
    
    /******************************Instruction buf end******************************************/
    
    /**************  State control logic*****************/
    always @(posedge CLK or posedge RST) begin
        if (RST == 1) begin
            state_control <= STATE_IDLE;
            base_addr <= 32'h00000000;
            stride <= 32'h00000000;
            index1 <= 7'b0000000;
            index2 <= 7'b0000000;
            dstIndex <= 7'b0000000;
        end else begin
            case(state_control)
                STATE_IDLE: begin
                    state_control <= (ibuf_full == 1'b1) && (ibuf_op == OPCODE_ARRAY_ADD) ? STATE_ADD0 :
                                     (ibuf_full == 1'b1) && (ibuf_op == OPCODE_ARRAY_MULT) ? STATE_MULT0 :
                                     (ibuf_full == 1'b1) && (ibuf_op == OPCODE_ARRAY_LOAD) ? STATE_LOAD0 :
                                     (ibuf_full == 1'b1) && (ibuf_op == OPCODE_ARRAY_STORE) ? STATE_STORE0 :
                                     (ibuf_full == 1'b1) && (ibuf_op == OPCODE_ARRAY_RELU) ? STATE_RELU0 :
                                     STATE_IDLE;
                    base_addr <= ibuf_regval1;
                    stride <= ibuf_regval2;
                    index1 <= {ibuf_rs1, 2'b00};
                    index2 <= {ibuf_rs2, 2'b00};
                    dstIndex <= {ibuf_rd, 2'b00};
                end
                STATE_ADD0: begin
                    state_control <= STATE_ADD1;
                    base_addr <= base_addr;
                    stride <= stride;
                    index1 <= index1 + 1'b1;
                    index2 <= index2 + 1'b1;
                    dstIndex <= dstIndex + 1'b1;
                end
                STATE_ADD1: begin
                    state_control <= STATE_ADD2;
                    base_addr <= base_addr;
                    stride <= stride;
                    index1 <= index1 + 1'b1;
                    index2 <= index2 + 1'b1;
                    dstIndex <= dstIndex + 1'b1;
                end
                STATE_ADD2: begin
                    state_control <= STATE_ADD3;
                    base_addr <= base_addr;
                    stride <= stride;
                    index1 <= index1 + 1'b1;
                    index2 <= index2 + 1'b1;
                    dstIndex <= dstIndex + 1'b1;
                end
                STATE_ADD3: begin
                    state_control <= STATE_IDLE;
                    base_addr <= base_addr;
                    stride <= stride;
                    index1 <= index1 + 1'b1;
                    index2 <= index2 + 1'b1;
                    dstIndex <= dstIndex + 1'b1;
                end
                
                STATE_RELU0: begin
                    state_control <= STATE_RELU1;
                    base_addr <= base_addr;
                    stride <= stride;
                    index1 <= index1 + 1'b1;
                    index2 <= index2 + 1'b1;
                    dstIndex <= dstIndex + 1'b1;
                end
                STATE_RELU1: begin
                    state_control <= STATE_RELU2;
                    base_addr <= base_addr;
                    stride <= stride;
                    index1 <= index1 + 1'b1;
                    index2 <= index2 + 1'b1;
                    dstIndex <= dstIndex + 1'b1;
                end
                STATE_RELU2: begin
                    state_control <= STATE_RELU3;
                    base_addr <= base_addr;
                    stride <= stride;
                    index1 <= index1 + 1'b1;
                    index2 <= index2 + 1'b1;
                    dstIndex <= dstIndex + 1'b1;
                end
                STATE_RELU3: begin
                    state_control <= STATE_IDLE;
                    base_addr <= base_addr;
                    stride <= stride;
                    index1 <= index1 + 1'b1;
                    index2 <= index2 + 1'b1;
                    dstIndex <= dstIndex + 1'b1;
                end
                
                STATE_LOAD0: begin
                    if (data_valid) begin
                        state_control <= STATE_LOAD1;
                        base_addr <= base_addr + stride;
                        stride <= stride;
                        index1 <= index1 + 1'b1;
                        index2 <= index2 + 1'b1;
                        dstIndex <= dstIndex + 1'b1;
                    end else begin
                        state_control <= state_control;
                        base_addr <= base_addr;
                        stride <= stride;
                        index1 <= index1;
                        index2 <= index2;
                        dstIndex <= dstIndex;
                    end
                end
                STATE_LOAD1: begin
                    if (data_valid) begin
                        state_control <= STATE_LOAD2;
                        base_addr <= base_addr + stride;
                        stride <= stride;
                        index1 <= index1 + 1'b1;
                        index2 <= index2 + 1'b1;
                        dstIndex <= dstIndex + 1'b1;
                    end else begin
                        state_control <= state_control;
                        base_addr <= base_addr;
                        stride <= stride;
                        index1 <= index1;
                        index2 <= index2;
                        dstIndex <= dstIndex;
                    end
                end
                STATE_LOAD2: begin
                    if (data_valid) begin
                        state_control <= STATE_LOAD3;
                        base_addr <= base_addr + stride;
                        stride <= stride;
                        index1 <= index1 + 1'b1;
                        index2 <= index2 + 1'b1;
                        dstIndex <= dstIndex + 1'b1;
                    end else begin
                        state_control <= state_control;
                        base_addr <= base_addr;
                        stride <= stride;
                        index1 <= index1;
                        index2 <= index2;
                        dstIndex <= dstIndex;
                    end
                end
                STATE_LOAD3: begin
                    if (data_valid) begin
                        state_control <= STATE_IDLE;
                        base_addr <= base_addr + stride;
                        stride <= stride;
                        index1 <= index1 + 1'b1;
                        index2 <= index2 + 1'b1;
                        dstIndex <= dstIndex + 1'b1;
                    end else begin
                        state_control <= state_control;
                        base_addr <= base_addr;
                        stride <= stride;
                        index1 <= index1;
                        index2 <= index2;
                        dstIndex <= dstIndex;
                    end
                end
                
                STATE_STORE0: begin
                    if (data_valid) begin
                        state_control <= STATE_STORE1;
                        base_addr <= base_addr + stride;
                        stride <= stride;
                        index1 <= index1 + 1'b1;
                        index2 <= index2 + 1'b1;
                        dstIndex <= dstIndex + 1'b1;
                    end else begin
                        state_control <= state_control;
                        base_addr <= base_addr;
                        stride <= stride;
                        index1 <= index1;
                        index2 <= index2;
                        dstIndex <= dstIndex;
                    end
                end
                STATE_STORE1: begin
                    if (data_valid) begin
                        state_control <= STATE_STORE2;
                        base_addr <= base_addr + stride;
                        stride <= stride;
                        index1 <= index1 + 1'b1;
                        index2 <= index2 + 1'b1;
                        dstIndex <= dstIndex + 1'b1;
                    end else begin
                        state_control <= state_control;
                        base_addr <= base_addr;
                        stride <= stride;
                        index1 <= index1;
                        index2 <= index2;
                        dstIndex <= dstIndex;
                    end
                end
                STATE_STORE2: begin
                    if (data_valid) begin
                        state_control <= STATE_STORE3;
                        base_addr <= base_addr + stride;
                        stride <= stride;
                        index1 <= index1 + 1'b1;
                        index2 <= index2 + 1'b1;
                        dstIndex <= dstIndex + 1'b1;
                    end else begin
                        state_control <= state_control;
                        base_addr <= base_addr;
                        stride <= stride;
                        index1 <= index1;
                        index2 <= index2;
                        dstIndex <= dstIndex;
                    end
                end
                STATE_STORE3: begin
                    if (data_valid) begin
                        state_control <= STATE_IDLE;
                        base_addr <= base_addr;
                        stride <= stride;
                        index1 <= index1;
                        index2 <= index2;
                        dstIndex <= dstIndex;
                    end else begin
                        state_control <= state_control;
                        base_addr <= base_addr;
                        stride <= stride;
                        index1 <= index1;
                        index2 <= index2;
                        dstIndex <= dstIndex;
                    end
                end
                
                STATE_MULT0: begin
                    state_control <= STATE_MULT1;
                    base_addr <= base_addr;
                    stride <= stride;
                    index1 <= index1 + 1'b1;
                    index2 <= index2 + 1'b1;
                    dstIndex <= dstIndex;
                end
                STATE_MULT1: begin
                    state_control <= STATE_MULT2;
                    base_addr <= base_addr;
                    stride <= stride;
                    index1 <= index1 + 1'b1;
                    index2 <= index2 + 1'b1;
                    dstIndex <= dstIndex;
                end
                STATE_MULT2: begin
                    state_control <= STATE_MULT3;
                    base_addr <= base_addr;
                    stride <= stride;
                    index1 <= index1 + 1'b1;
                    index2 <= index2 + 1'b1;
                    dstIndex <= dstIndex;
                end
                STATE_MULT3: begin
                    state_control <= STATE_MULT4;
                    base_addr <= base_addr;
                    stride <= stride;
                    index1 <= index1;
                    index2 <= index2;
                    dstIndex <= dstIndex;
                end
                STATE_MULT4: begin
                    state_control <= STATE_MULT5;
                    base_addr <= base_addr;
                    stride <= stride;
                    index1 <= index1;
                    index2 <= index2;
                    dstIndex <= dstIndex;
                end
                STATE_MULT5: begin
                    state_control <= STATE_MULT6;
                    base_addr <= base_addr;
                    stride <= stride;
                    index1 <= index1;
                    index2 <= index2;
                    dstIndex <= dstIndex;
                end
                STATE_MULT6: begin
                    state_control <= STATE_MULT7;
                    base_addr <= base_addr;
                    stride <= stride;
                    index1 <= index1;
                    index2 <= index2;
                    dstIndex <= dstIndex;
                end
                STATE_MULT7: begin
                    state_control <= STATE_MULT8;
                    base_addr <= base_addr;
                    stride <= stride;
                    index1 <= index1;
                    index2 <= index2;
                    dstIndex <= dstIndex;
                end
                STATE_MULT8: begin
                    state_control <= STATE_MULT9;
                    base_addr <= base_addr;
                    stride <= stride;
                    index1 <= index1;
                    index2 <= index2;
                    dstIndex <= dstIndex + 1'b1;
                end
                STATE_MULT9: begin
                    state_control <= STATE_MULT10;
                    base_addr <= base_addr;
                    stride <= stride;
                    index1 <= index1;
                    index2 <= index2;
                    dstIndex <= dstIndex + 1'b1;
                end
                STATE_MULT10: begin
                    state_control <= STATE_MULT11;
                    base_addr <= base_addr;
                    stride <= stride;
                    index1 <= index1;
                    index2 <= index2;
                    dstIndex <= dstIndex + 1'b1;
                end
                STATE_MULT11: begin
                    state_control <= STATE_IDLE;
                    base_addr <= base_addr;
                    stride <= stride;
                    index1 <= index1;
                    index2 <= index2;
                    dstIndex <= dstIndex;
                end
                default: begin
                    state_control <= STATE_IDLE;
                    base_addr <= 32'h00000000;
                    stride <= 32'h00000000;
                    index1 <= 7'b0000000;
                    index2 <= 7'b0000000;
                    dstIndex <= 7'b0000000;
                end
            endcase
        end
    end

endmodule //systolic_array
