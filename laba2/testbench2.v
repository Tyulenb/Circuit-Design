`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 27.03.2025 00:44:31
// Design Name: 
// Module Name: testbench2
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: 
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////


module testbench2();
    reg clk = 0;
    always #10 clk = ~clk;
    /*
    reg [31:0] a = 32'b00111101110011001100110011001101;
    wire [31:0] res;
    wire err;
    
    mycalc calc(
        .x(a),
        .res(res),
        .err(err)
    );
    */
    reg [31:0] s1 = 32'b01000000111000000000000000000000; //32'b0_10000011_00110001111110011101001;
    reg [31:0] s2 = 32'b01000000101000000000000000000000; //32'b0_10000001_01001110111001001011100;
    /*
    wire [31:0] res1;
    //wire [24:0] mant;
    mysum sum(
        .a(s1),
        .b(s2), 
        .res(res1)
    );
    
    wire res3;
    wire [4:0] lst;
    wire [7:0] clc;
    checkfr check(
        .num(s2),
        .lst(lst),
        .res(res3),
        .calc(clc)
    );
    */
    //wire [4:0] carry;
    wire [31:0] res2;
    mydel del(
        .n(s1),
        .x(s2),
        .clk(clk),
        .res(res2)
    );
endmodule
