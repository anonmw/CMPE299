module issue_tb;
    parameter VECWIDTH = 64;
    parameter WIDTH = 32;
    parameter IDXWIDTH = 5;
    
    parameter OPCODE_ARRAY_ADD = 7'b1111000;
    parameter OPCODE_ARRAY_MULT = 7'b1111001;
    parameter OPCODE_ARRAY_LOAD = 7'b1111010;
    parameter OPCODE_ARRAY_STORE = 7'b1111011;
    parameter OPCODE_ARRAY_RELU =   7'b1111100;

    reg RST = 0;
    initial begin
        #3 RST = 1;
        #5 RST = 0;
    end

    reg CLK = 0;
    always #5 CLK = !CLK;

    initial begin
        $dumpfile("issue_tb.vcd");
        $dumpvars(0, issue_tb);
    end

	reg [6:0] op;
    reg [IDXWIDTH-1:0] rd, rs1, rs2;
	reg [WIDTH-1:0] regval1, regval2;
	reg valid;
    
    wire busy;
    
    issue uut(op, rd, rs1, rs2, regval1, regval2, valid, busy, CLK, RST);
    
    initial begin
        // initial code
        op = 7'b0000000;
        rd = 5'b00000;
        rs1 = 5'b00000;
        rs2 = 5'b00000;
        regval1 = 32'hdeadbeef;
        regval2 = 32'hdeadbeef;
        valid = 0;
        #12;
        // first calculation
        op = OPCODE_ARRAY_ADD;
        rd = 5'b00010;
        rs1 = 5'b00000;
        rs2 = 5'b00001;
        regval1 = 32'hdeadbeef;
        regval2 = 32'hdeadbeef;
        valid = 1;
        #10;
        op = OPCODE_ARRAY_ADD;
        rd = 5'b00011;
        rs1 = 5'b00010;
        rs2 = 5'b00010;
        regval1 = 32'hdeadbeef;
        regval2 = 32'hdeadbeef;
        valid = 1;
        #10;
        #50;
        op = OPCODE_ARRAY_MULT;
        rd = 5'b00011;
        rs1 = 5'b00010;
        rs2 = 5'b00010;
        regval1 = 32'hdeadbeef;
        regval2 = 32'hdeadbeef;
        valid = 1;
        #10;
        op = OPCODE_ARRAY_ADD;
        rd = 5'b00100;
        rs1 = 5'b00010;
        rs2 = 5'b00010;
        regval1 = 32'hdeadbeef;
        regval2 = 32'hdeadbeef;
        valid = 1;
        #10;
        #10;
        #10;
        #10;
        #10;
        // end second calculation
        op = 7'b0000000;
        rd = 5'b00000;
        rs1 = 5'b00000;
        rs2 = 5'b00000;
        regval1 = 32'hdeadbeef;
        regval2 = 32'hdeadbeef;
        valid = 0;
        #190;
        op = OPCODE_ARRAY_LOAD;
        rd = 5'b00101;
        rs1 = 5'b00000;
        rs2 = 5'b00000;
        regval1 = 32'h00000020;
        regval2 = 32'h00000008;
        valid = 0;
        #10;
        op = OPCODE_ARRAY_STORE;
        rd = 5'b00000;
        rs1 = 5'b00011;
        rs2 = 5'b00000;
        regval1 = 32'h00000000;
        regval2 = 32'h00000008;
        valid = 1;
        #10;
        op = OPCODE_ARRAY_LOAD;
        rd = 5'b00101;
        rs1 = 5'b00000;
        rs2 = 5'b00000;
        regval1 = 32'h00000020;
        regval2 = 32'h00000008;
        valid = 1;
        #40;
        op = OPCODE_ARRAY_RELU;
        rd = 5'b01000;
        rs1 = 5'b00110;
        rs2 = 5'b00000;
        regval1 = 32'hdeadbeef;
        regval2 = 32'hdeadbeef;
        valid = 1;
        #40;
        op = 7'b0000000;
        rd = 5'b00000;
        rs1 = 5'b00000;
        rs2 = 5'b00000;
        regval1 = 32'hdeadbeef;
        regval2 = 32'hdeadbeef;
        valid = 0;
        #100;
        $finish;
    end
    
    initial
        $monitor("At time %t, op = %0d, rd = %0d, rs1 = %0d, rs2 = %0d, regval1 = %0d, regval2 = %0d, valid = %0d, busy = %0d", $time, op, rd, rs1, rs2, regval1, regval2, valid, busy);
    
endmodule // test
