module main_tb;
    parameter WIDTH = 32;
    
    reg RST = 0;
    initial begin
        #3 RST = 1;
        #5 RST = 0;
    end

    reg CLK = 0;
    always #5 CLK = !CLK;

    main uut(CLK, RST);

    initial begin
        $dumpfile("main_tb.vcd");
        $dumpvars(0, main_tb);
    end
    
    initial begin
        #250000;
        $finish;
    end
    
endmodule // alu_tb
