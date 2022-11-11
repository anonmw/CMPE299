module adder_fixed_int16(A_in, B_in, alu_out);
    parameter WIDTH = 16;
    
    input [WIDTH-1:0] A_in, B_in;
    output [WIDTH-1:0] alu_out;

    wire a_sign = A_in[15];
    wire [14:0] a_num = A_in[14:0];
    wire b_sign = B_in[15];
    wire [14:0] b_num = B_in[14:0];
    
    wire [14:0] a_minus_b = a_num - b_num;
    wire [14:0] b_minus_a = b_num - a_num;
    wire [15:0] a_plus_b = a_num + b_num;
    wire overflow = a_plus_b[15];
    wire a_bigger = a_num > b_num;

    wire [14:0] diff = a_bigger ? a_minus_b : b_minus_a;
    
    wire sign_out = a_bigger ? a_sign : b_sign;
    
    wire[14:0] num_out = a_sign ^ b_sign ? diff : 
                         overflow ? 15'h7fff : a_plus_b;
    
    assign alu_out = {sign_out, num_out};

endmodule //systolic alu
