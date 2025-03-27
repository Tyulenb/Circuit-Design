`timescale 1ns / 1ps


module mycalc(
    input [31:0] x, //n, //31 bit 31 - sign, 30-23 - exp, 22-0 mantissa
    output [31:0] res,
    output err
    );
    
 
    wire [8:0] exp_1;
    wire [47:0] mant_1;
    wire [22:0] mant_res;
    wire over_1;
    
    assign mant_1 = {1'b1,x[22:0]}*{1'b1,x[22:0]};
    assign mant_res = mant_1[47] ? mant_1[46:24] : mant_1[45:23]; //10.1101 -> 1.01101; 01.1101 -> 1.1101
    
    assign exp_1 = {1'b0,x[30:23]}+{1'b0,x[30:23]}-9'b001111111+mant_1[47];
    assign over_1 = x[30] ? exp_1 < x[30:23] : exp_1 > x[30:23]; // if x[30] is 1 -> decimal -> exp_1 < x[30:23] -> overflow
   
    
    assign res = over_1 ? 0 : {1'b0, exp_1[7:0], mant_res};
    assign err = over_1;
    
endmodule
