module regfile(indexA, indexB, writeIndex, writeData, regWrite, regA, regB, CLK, RST);
    parameter WIDTH = 32;
    parameter COUNT = 5;
    // first index is bit width, second index is paradoxically array size numerically
    reg [WIDTH-1:0] regvals [WIDTH-1:0];
    
    input wire [COUNT-1:0] indexA, indexB, writeIndex;
    input wire [WIDTH-1:0] writeData;
    input wire regWrite;
    
    output wire [WIDTH-1:0] regA, regB;
    input wire CLK, RST;
    
    //always do this no matter what (read always active basically)
    assign regA = regvals[indexA];
    assign regB = regvals[indexB];
    
    always @ (negedge CLK or posedge RST) begin
    	if (RST == 1) begin
    	    regvals[0] <= 32'h00000000;
    	    regvals[1] <= 32'h00000001;
    	    regvals[2] <= 32'h00000002;
    	    regvals[3] <= 32'h00000003;
    	    regvals[4] <= 32'h00000004;
    	    regvals[5] <= 32'h00000005;
    	    regvals[6] <= 32'h00000006;
    	    regvals[7] <= 32'h00000007;
    	    regvals[8] <= 32'h00000008;
    	    regvals[9] <= 32'h00000009;
    	    regvals[10] <= 32'h0000000A;
    	    regvals[11] <= 32'h0000000B;
    	    regvals[12] <= 32'h0000000C;
    	    regvals[13] <= 32'h0000000D;
    	    regvals[14] <= 32'h0000000E;
    	    regvals[15] <= 32'h0000000F;
    	    regvals[16] <= 32'h00000000;
    	    regvals[17] <= 32'h00000000;
    	    regvals[18] <= 32'h00000000;
    	    regvals[19] <= 32'h00000000;
    	    regvals[20] <= 32'h00000000;
    	    regvals[21] <= 32'h00000000;
    	    regvals[22] <= 32'h00000000;
    	    regvals[23] <= 32'h00000000;
    	    regvals[24] <= 32'h00000000;
    	    regvals[25] <= 32'h00000000;
    	    regvals[26] <= 32'h00000000;
    	    regvals[27] <= 32'h00000000;
    	    regvals[28] <= 32'h00000000;
    	    regvals[29] <= 32'h00000000;
    	    regvals[30] <= 32'h00000000;
    	    regvals[31] <= 32'h00000000;
    	end else if (regWrite == 1) begin
    	    if (writeIndex != 0) begin
        	    regvals[writeIndex] <= writeData;
    	    end else begin
    	        regvals[writeIndex] <= 32'h00000000;
    	    end
    	end
    end
    
    initial begin
        $dumpfile("main_tb.vcd");
        $dumpvars(0, regvals[0]);
        $dumpvars(0, regvals[1]);
        $dumpvars(0, regvals[2]);
        $dumpvars(0, regvals[3]);
        $dumpvars(0, regvals[4]);
        $dumpvars(0, regvals[5]);
        $dumpvars(0, regvals[6]);
        $dumpvars(0, regvals[7]);
        $dumpvars(0, regvals[8]);
        $dumpvars(0, regvals[9]);
        $dumpvars(0, regvals[10]);
        $dumpvars(0, regvals[11]);
        $dumpvars(0, regvals[12]);
        $dumpvars(0, regvals[13]);
        $dumpvars(0, regvals[14]);
        $dumpvars(0, regvals[15]);
        $dumpvars(0, regvals[16]);
        $dumpvars(0, regvals[17]);
        $dumpvars(0, regvals[18]);
        $dumpvars(0, regvals[19]);
        $dumpvars(0, regvals[20]);
        $dumpvars(0, regvals[21]);
        $dumpvars(0, regvals[22]);
        $dumpvars(0, regvals[23]);
        $dumpvars(0, regvals[24]);
        $dumpvars(0, regvals[25]);
        $dumpvars(0, regvals[26]);
        $dumpvars(0, regvals[27]);
        $dumpvars(0, regvals[28]);
        $dumpvars(0, regvals[29]);
        $dumpvars(0, regvals[30]);
        $dumpvars(0, regvals[31]);
    end

endmodule
