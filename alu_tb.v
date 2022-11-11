module alu_tb;
    parameter WIDTH = 32;
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
    
    reg RST = 0;
    initial begin
        #3 RST = 1;
        #5 RST = 0;
    end

    reg CLK = 0;
    always #5 CLK = !CLK;

    initial begin
        $dumpfile("alu_tb.vcd");
        $dumpvars(0, alu_tb);
    end

    reg [WIDTH-1:0] A;
    reg [WIDTH-1:0] B;
    reg [2:0] op;
    reg alt;
    
    wire [WIDTH-1:0] result;
     
    alu uut(A, B, op, alt, result);
    
    initial begin
        // initial code
        A = 2;
        B = 1;
        op = FUNCT3_ADD;
        alt = 0;
        #10;
        A = 2;
        B = 1;
        op = FUNCT3_ADD;
        alt = 1;
        #10;
        A = 1;
        B = 0;
        op = FUNCT3_SLT;
        alt = 0;
        #10;
        A = 0;
        B = 1;
        op = FUNCT3_SLT;
        alt = 0;
        #10;
        A = 32'hffffffff;
        B = 32'haaaaaaaa;
        op = FUNCT3_AND;
        alt = 0;
        #10;
        A = 32'haaaa0000;
        B = 32'h55550000;
        op = FUNCT3_OR;
        alt = 0;
        #10;
        A = 32'haaaaff00;
        B = 32'h5555ff00;
        op = FUNCT3_XOR;
        alt = 0;
        #10;
        A = 32'hffffffff;
        B = 12;
        op = FUNCT3_SLL;
        alt = 0;
        #10;
        A = 32'hffffffff;
        B = 12;
        op = FUNCT3_SRL;
        alt = 0;
        #10;
        $finish;
    end
    
    initial
        $monitor("At time %t, A = %0d, B = %0d, op = %0d, alt = %0d, result = %0d", $time, A, B, op, alt, result);
    
endmodule // alu_tb
