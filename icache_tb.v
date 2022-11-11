module icache_tb;
    parameter WIDTH = 32;

    reg RST = 0;
    initial begin
        #3 RST = 1;
        #5 RST = 0;
    end

    reg CLK = 0;
    always #5 CLK = !CLK;

    initial begin
        $dumpfile("icache_tb.vcd");
        $dumpvars(0, icache_tb);
    end

    reg [WIDTH-1:0] PC;
    
    wire [WIDTH-1:0] instruction;
     
    icache imem(PC, instruction, CLK, RST);
    
    initial begin
        // initial code
        PC = 0;
        #10;
        PC = 1;
        #10;
        PC = 2;
        #10;
        PC = 3;
        #10;
        PC = 4;
        #10;
        PC = 5;
        #10;
        PC = 6;
        #10;
        PC = 7;
        #10;
        $finish;
    end
    
    initial
        $monitor("At time %t, PC = %0d, instruction = %0d,", $time, PC, instruction);
    
endmodule // icache_tb
