module dcache_tb;
    parameter WIDTH = 32;

    reg RST = 0;
    initial begin
        #3 RST = 1;
        #5 RST = 0;
    end

    reg CLK = 0;
    always #5 CLK = !CLK;

    initial begin
        $dumpfile("dcache_tb.vcd");
        $dumpvars(0, dcache_tb);
    end

    reg [WIDTH-1:0] address;
    reg [WIDTH-1:0] data_in;
    reg read;
    reg write;
    
    wire [WIDTH-1:0] data_out;
     
    dcache dmem(address, data_in, read, write, data_out, CLK, RST);
    
    initial begin
        // initial code
        address = 0;
        data_in = 0;
        read = 0;
        write = 0;
        #10;
        address = 4;
        data_in = 32'h00000011;
        read = 0;
        write = 1;
        #10;
        address = 4;
        data_in = 32'h00000011;
        read = 1;
        write = 0;
        #10;
        address = 8;
        data_in = 32'h00000012;
        read = 0;
        write = 1;
        #10;
        address = 8;
        data_in = 32'h00000022;
        read = 0;
        write = 1;
        #10;
        address = 8;
        data_in = 32'h00000000;
        read = 1;
        write = 0;
        #10;
        address = 12;
        data_in = 32'h00000011;
        read = 1;
        write = 0;
        #10;
        address = 16;
        data_in = 32'h00000011;
        read = 1;
        write = 0;
        #10;
        $finish;
    end
    
    initial
        $monitor("At time %t, address = %0d, data_in = %0d, read = %0d, write = %0d, data_out = %0d", $time, address, data_in, read, write, data_out);
    
endmodule // dcache_tb
