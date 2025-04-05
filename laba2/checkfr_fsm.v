`timescale 1ns / 1ps


module checkfr_fsm(
    input [31:0] num,
    input clk, r_i,
    output res,
    output reg r_o
    );

    reg [4:0] lst;
    reg [4:0] iter;
    reg res_rg;
    reg [1:0] state;
    initial
    begin
        lst = 0;
        iter = 0;
        res_rg = 0;
    end
    
    always@(posedge clk)
    begin
        case(state)
        2'b00: if(r_i)
            begin
                for(iter = 0; iter <= 22; iter = iter + 1)
                begin
                    if (lst == 0 && num[iter])
                        lst = iter;
                end
                state <= 2'b01;
            end
        2'b01:
            begin
                if (num[30:23] > 7'b1111111)
                begin
                    if ((22-(num[30:23]-7'b1111111)) >= lst)
                        res_rg = 0;
                    else
                        res_rg = 1;
                end
                state <= 2'b10;
            end
        2'b10:
            state <= 2'b00;
        endcase
    end
    
    always@(posedge clk)
    begin
        if(state == 2'b10)
            r_o = 1;
        else
            r_o = 0;
    end
    
    assign res = res_rg;
    
    
endmodule
