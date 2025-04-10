`timescale 1ns / 1ps


module testfsm();
    reg clk;
    reg [31:0] a; //n, //31 bit 31 - sign, 30-23 - exp, 22-0 mantissa
    reg [31:0] b;
    reg r_i;
    wire [31:0] res;
    wire rs;
    wire err;
    wire r_o;
    wire r_o1;
    
    initial
    begin
        clk = 0;
        a = 32'b01000000101000000000000000000000;
        b = 32'b01000000111000000000000000000000;
        r_i = 0;
        #10;
        r_i = 1;
        #30;
        r_i = 0;
        a = 32'b01001000101001000001100000000000;
        b = 32'b01000100111111000000000011100000;
        #5000;
        r_i = 1;
        #50;
        r_i = 0;
        #5000;
        r_i = 1;
        b = 32'b01001000101001000001100000000000;
        a = 32'b01000100111111000000000011100000;
        #100;
        r_i = 0;
        #5000;
        
        $finish;
    end
    
    always #10 clk = ~clk;
    
//    pow2_fsm FSM2(
//        .clk(clk),
//        .x(a),
//        .r_i(r_i),
//        .res(res),
//        .err(err),
//        .r_o(r_o)
//    );
    
    del_fsm FSMDEL(
        .clk(clk),
        .n(a),
        .x(b),
        .r_i(r_i),
        .res(res),
        .r_o(r_o)
    );
//    checkfr_fsm FSMCH(
//        .clk(clk),
//        .r_i(r_i),
//        .num_in(a),
//        .res(rs),
//        .r_o(r_o1)
//    );
endmodule
