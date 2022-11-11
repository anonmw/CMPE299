module alu(A, B, op, alt, result);
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
    
    input [WIDTH-1:0] A, B;
    input [2:0] op;
    input alt;
    output reg [WIDTH-1:0] result;
    wire [WIDTH-1:0] subdiff = A + ~B + 1'b1;
    wire equals = (A == B);
    wire sign = subdiff[31];
    wire [4:0] shamt = B[4:0];
    wire [WIDTH-1:0] sign_extend = A[31] ? ~(32'hffffffff >> shamt) : 32'h00000000;
    wire [WIDTH-1:0] op_add = alt ? subdiff : A + B;
    wire [WIDTH-1:0] op_slt = sign && ~equals;
    wire [WIDTH-1:0] op_sltu = A < B;
    wire [WIDTH-1:0] op_and = A & B;
    wire [WIDTH-1:0] op_or = A | B;
    wire [WIDTH-1:0] op_xor = A ^ B;
    wire [WIDTH-1:0] op_sll = A << shamt;
    wire [WIDTH-1:0] op_srl = alt ? (A >> shamt) | sign_extend : A >> shamt;
//calculate A-B, use result for both add and SLT/SLTU
    always @(*) begin
        case(op)
            FUNCT3_ADD: result = op_add;
            FUNCT3_SLT: result = op_slt;
            FUNCT3_SLTU: result = op_sltu;
            FUNCT3_AND: result = op_and;
            FUNCT3_OR: result = op_or;
            FUNCT3_XOR: result = op_xor;
            FUNCT3_SLL: result = op_sll;
            FUNCT3_SRL: result = op_srl;
            default: result = 32'hdeadbeef;
        endcase
    end
endmodule
