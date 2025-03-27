`timescale 1ns / 1ps


module checkfr(
    input [31:0] num,
    output res,
    output reg [4:0] lst,
    output [7:0] calc
    );
    
    initial
    begin
        lst = 0;
    end
    wire [22:0] mant;
    assign mant = num[22:0];
    reg [4:0] iter;
    //reg [4:0] lst = 0;
    always@(mant)
    begin
        for(iter = 0; iter <= 22; iter = iter + 1)
        begin
            if (lst == 0 && mant[iter])
                lst = iter;
        end
    end
    assign calc = 22-(num[30:23]-7'b1111111);
    assign res = (num[30:23] > 7'b1111111) ? (22-(num[30:23]-7'b1111111)) >= lst : 1;
endmodule
