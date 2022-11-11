module icache_assembly(PC, instruction, CLK, RST);
    parameter WIDTH = 32;
    reg [WIDTH-1:0] icache [15:0];
    
    input wire [WIDTH-1:0] PC;
    output wire [WIDTH-1:0] instruction;
    input wire CLK, RST;
    
    wire [3:0] index = PC[5:2];
    
    assign instruction = icache[index];
    always @ (posedge CLK or posedge RST) begin
    	if (RST == 1) begin
    	`ifdef TEST_ISSUE
    	    /*
        	    r0 contains pointer to weights1
        	    r1 contains pointer to weights2
        	    r2 contains pointer to bias1
        	    r3 contains pointer to bias2
        	    r4 contains pointer to imagearray
        	    r5 contains pointer to general memory
    	    */
    	    icache[0] <= 32'b00000000000000000110_00001_0110111; // lui r1, 0x00006 #r1 = 32'h00006000
    	    icache[1] <= 32'b001000000000_00001_000_00001_0010011; // addi r1, r1, 0x200 #r1 = 32'h00006200
    	    icache[2] <= 32'b00000000000000000110_00010_0110111; // lui r2, 0x00006 #r2 = 32'h00006000
    	    icache[3] <= 32'b001110000000_00010_000_00010_0010011; // addi r2, r2, 0x380 #r2 = 32'h00006380
    	    icache[4] <= 32'b00000000000000000110_00011_0110111; // lui r3, 0x00006 #r3 = 32'h00006000
    	    icache[5] <= 32'b001110100000_00011_000_00011_0010011; // addi r3, r3, 0x3a0 #r3 = 32'h000063a0
    	    icache[6] <= 32'b00000000000000001000_00100_0110111; // lui r4, 0x00008 #r4 = 32'h00008000
    	    icache[7] <= 32'b00000000000000001010_00101_0110111; // lui r5, 0x0000a #r5 = 32'h0000a000
    	    
    	    icache[8] <= 32'b000000000001_00001_000_00001_0010011; // addi r1, r1, 1 #r1 = 4
    	    icache[9] <= 32'b000000000001_00000_000_00011_0010011; // addi r3, r0, 1 #r3 = 1 (quadword aligned stride)
    	    icache[10] <= 32'b000000000001_00010_000_00101_1111010; // load4 v5, r2(1) # v20-23 = mem[32-56]
    	    icache[11] <= 32'b000000000001_00000_000_00011_1111011; // store4 v3, r0(1) # mem[0-24] = v12-v15
    	    icache[12] <= 32'b000000000001_00010_000_00101_1111010; // load4 v5, r2(1) # v20-23 = mem[32-56]
    	    icache[13] <= 32'b000000000000_00110_000_01000_1111100; // relu4 v8, v6 # v32-35 = relu(v24-27)
    	    icache[14] <= 32'b000000000000_00000_000_00000_0010011; // addi r0, r0, 0 #nop
    	    icache[15] <= 32'b1_111111_00000_00000_000_1110_1_1100011; // beq r0, r0, -4 # branch to 14
	    `endif
    	end else begin
    	// do nothing
    	end
    end

endmodule
