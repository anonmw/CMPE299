module dcache_weights_tb;
    parameter WIDTH = 32;

    reg RST = 0;
    initial begin
        #3 RST = 1;
        #5 RST = 0;
    end

    reg CLK = 0;
    always #5 CLK = !CLK;

    initial begin
        $dumpfile("dcache_weights_tb.vcd");
        $dumpvars(0, dcache_weights_tb);
    end

    reg [WIDTH-1:0] address;
    reg read;
    
    wire [64-1:0] data_out;
     
    dcache_weights weights(address, read, data_out, valid, CLK, RST);
    
    initial begin
        // initial code
        address = 0;
        read = 1;
        #10;
        address = 32'h00006200;
        read = 1;
        #10;
        address = 32'h00006380;
        read = 0;
        #10;
        address = 32'h000063a0;
        read = 1;
        #10;
        $finish;
    end
    
    initial
        $monitor("At time %t, address = %0d, read = %0d, data_out = %0d", $time, address, read, data_out);
    
endmodule // dcache_tb
