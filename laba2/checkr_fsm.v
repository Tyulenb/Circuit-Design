`timescale 1ns / 1ps

module checkfr_fsm(
    input [31:0] num_in,
    input clk, r_i,
    output res,
    output reg r_o
    );

    reg [4:0] lst;
    reg [4:0] iter;
    reg res_rg;
    reg [1:0] state;
    reg [31:0] num;
    initial
    begin
        state = 0;
        lst = 5'b11111;
        iter = 0;
        res_rg = 0;
        r_o = 0;
    end
    
    always@(posedge clk)
    begin
        case(state)
        2'b00: if(r_i)
            begin
                lst <= 5'b11111;
                iter <= 0;
                res_rg <= 0;
                num <= num_in;
                state <= 2'b01;
            end
        2'b01:
            begin
                for(iter = 0; iter <= 22; iter = iter + 1)
                begin
                    if (lst == 5'b11111 && num[iter])
                        lst = iter;
                    else
                        lst = lst;
                end
                state <= 2'b10;
            end
        2'b10:
            begin
                if (num[30:23] > 7'b1111111)
                begin
                   res_rg = num[31] || ((22-(num[30:23]-7'b1111111)) >= lst) && (lst!=5'b11111);
                end
                else
                begin
                    res_rg = 1;
                end
                state <= 2'b00;
            end
        default:
            state <= 2'b00;
        endcase
    end
    
    always@(posedge clk)
    begin
        if(state == 2'b10)
            r_o <= 1;
        else
            r_o <= 0;
    end
    
    assign res = res_rg;
    
    
endmodule
