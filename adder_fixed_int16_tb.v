module adder_fixed_int16_tb;
    parameter WIDTH = 16;

    reg RST = 0;
    initial begin
        #3 RST = 1;
        #5 RST = 0;
    end

    reg CLK = 0;
    always #5 CLK = !CLK;

    initial begin
        $dumpfile("adder_fixed_int16_tb.vcd");
        $dumpvars(0, adder_fixed_int16_tb);
    end

    reg [WIDTH-1:0] A_in, B_in;
    
    wire [WIDTH-1:0] result_out;
     
    adder_fixed_int16 adder(A_in, B_in, result_out);
    
    initial begin
        // initial code
        A_in = 0;
        B_in = 0;
        #12;
        // first calculation
        A_in = 16'b0100000000000000; //result = 7fff
        B_in = 16'b0100000000000000;
        #10;
        A_in = 16'b1100000000000000; //result = ffff
        B_in = 16'b1100000000000000;
        #10;
        A_in = 16'b1100000000000000; //result = a000
        B_in = 16'b0010000000000000;
        #10;
        A_in = 16'b1010000000000000; //result = 2000
        B_in = 16'b0100000000000000;
        #10;
        A_in = 16'b0010000000000000; //result = a000
        B_in = 16'b1100000000000000;
        #10;
        A_in = 16'b0100000000000000; //result = 2000
        B_in = 16'b1010000000000000;
        #10;
        A_in = 16'b0010101010101010; //result = 7fff
        B_in = 16'b0101010101010101;
        #10;
        A_in = 16'b0000000000000001; //result = 0002
        B_in = 16'b0000000000000001;
        #10;
        // end second calculation
        #100;
        $finish;
    end
    
    initial
        $monitor("At time %t, A_in = %0d, B_in = %0d", $time, A_in, B_in);
    
endmodule // test
