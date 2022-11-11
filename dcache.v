module dcache(address, data_in, read, write, data_out, CLK, RST);
    parameter WIDTH = 32;
    reg [WIDTH-1:0] dcache [7:0];
    
    input wire [WIDTH-1:0] address, data_in;
    input wire read, write;
    output wire [WIDTH-1:0] data_out;
    input CLK, RST;
    
    wire [2:0] index = address[4:2];
    
    //always do this no matter what (read always active basically)
    assign data_out = dcache[index];
    
    always @ (posedge CLK or posedge RST) begin
    	if (RST == 1) begin
    	    dcache[0] <= 32'h00000000;
    	    dcache[1] <= 32'h00000001;
    	    dcache[2] <= 32'h00000002;
    	    dcache[3] <= 32'h00000003;
    	    dcache[4] <= 32'h00000004;
    	    dcache[5] <= 32'h00000005;
    	    dcache[6] <= 32'h00000006;
    	    dcache[7] <= 32'h00000007;
    	end else if (write == 1) begin
    	    dcache[index] <= data_in;
    	// update value
    	end
    end

    initial begin
        $dumpfile("main_tb.vcd");
        $dumpvars(0, dcache[0]);
        $dumpvars(0, dcache[1]);
        $dumpvars(0, dcache[2]);
        $dumpvars(0, dcache[3]);
        $dumpvars(0, dcache[4]);
        $dumpvars(0, dcache[5]);
        $dumpvars(0, dcache[6]);
        $dumpvars(0, dcache[7]);
    end

endmodule
