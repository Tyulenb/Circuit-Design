`timescale 1ns / 1ps

module sum_fsm(
    input clk, r_i,
    input [31:0] a, b,
    output [31:0] res,
    output reg r_o
    );
    
    reg [3:0] state;
    reg [31:0] mx;
    reg [31:0] mn;
    reg [24:0] mant;
    reg [22:0] mant_res;
    reg [8:0] exp;
    reg [4:0] carry;
    reg [4:0] iter;
    reg [31:0] res_reg;
    
    initial
    begin
        state = 0;
        mx = 0;
        mn = 0;
        mant_res = 0;
        mant = 0;
        exp = 0;
        carry = 0;
        iter = 0;
        res_reg = 0;
        r_o = 0;
    end
    
    always@(posedge clk)
    begin
        case(state)
            3'b000:
            begin
                state <= 3'b001;
                mx <= 0;
                mn <= 0;
                mant_res <= 0;
                mant <= 0;
                exp <= 0;
                carry <= 0;
                iter <= 0;
                res_reg <= 0;
            end
            3'b001: if(r_i)
            begin
                mx = (a[30:23] > b[30:23]) ? a : (((a[30:23] == b[30:23])) ? (a[22:0] > b[22:0] ? a : b) : b );
                mn = (a == mx) ? b : a;
                state <= 3'b010;
            end
            3'b010:
            begin
                mant <= (mx[31]^mn[31]) ? {1'b1, mx[22:0]} - ({1'b1, mn[22:0]} >> (mx[30:23]-mn[30:23])): {1'b1, mx[22:0]}+({1'b1, mn[22:0]} >> (mx[30:23]-mn[30:23]));
                state <= 3'b011;
            end
            3'b011:
            begin
                for(iter = 0; iter <= 24; iter = iter + 1)
                begin
                    if(mant[iter])
                        carry = iter;
                    else
                        carry = carry;
                end
                state <= 3'b100;
            end
            3'b100:
            begin
                mant_res <= mant[24] ? (mant >> 1) : (mant << (23-carry)); 
                state <= 3'b101;
            end
            3'b101:
            begin
                exp <= mx[30:23]+carry-5'b10111;
                state <= 3'b110;
            end
            3'b110:
            begin
                res_reg <= mx[31] ? {1'b1, exp[7:0], mant_res} : {1'b0, exp[7:0], mant_res};
                state <= 3'b000;
            end
            default:
                state <= 3'b000;
                
        endcase
    end
    
    always@(posedge clk)
    begin
        case(state)
            3'b000: r_o <= 0;
            3'b110: r_o <= 1;
        endcase
    end
    assign res = res_reg;
endmodule
