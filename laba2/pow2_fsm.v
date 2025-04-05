`timescale 1ns / 1ps

module pow2_fsm(
    input [31:0] x, //n, //31 bit 31 - sign, 30-23 - exp, 22-0 mantissa
    input clk,
    input r_i,
    output [31:0] res,
    output err,
    output reg r_o
    );
    
    reg [8:0] exp_in;
    reg [22:0] mant_in;
    reg fb;
    reg [8:0] exp;
    reg [47:0] mant;
    reg [22:0] mant_res;
    reg [2:0] state;
    reg [31:0] res_reg;
    reg over;
    
    initial
    begin
        exp = 0;
        exp_in = 0;
        fb = 0;
        mant = 0;
        mant_res = 0;
        res_reg = 0;
        over = 0;
        state = 0;
        r_o = 0;
    end
    
    always@(posedge clk)
    begin
        case(state)
        3'b000: if(r_i)
        begin
            exp_in <= x[30:23];
            mant_in <= x[22:0];
            fb <= x[31];
            exp <= 0;
            mant <= 0;
            mant_res <= 0;
            over <= 0;
            state <= 3'b001;
        end
        
        3'b001:
        begin
            mant <= {1'b1,mant_in[22:0]}*{1'b1,mant_in};
            state <= 3'b010;
        end
        
        3'b010:
        begin
            mant_res <= mant[47] ? mant[46:24] : mant[45:23]; //10.1101 -> 1.01101; 01.1101 -> 1.1101
            state <= 3'b011;
        end
        
        3'b011:
        begin
            exp <= {1'b0,exp_in}+{1'b0,exp_in}-9'b001111111+mant[47];
            state <= 3'b100;
        end
        
        3'b100:
        begin
            over = x[30] ? exp < exp_in : exp > exp_in; // if x[30] is 1 -> decimal -> exp_1 < x[30:23] -> overflow
            res_reg = over ? 0 : {1'b0, exp[7:0], mant_res};
            state <= 3'b000;
        end
        
        endcase
    end
    
    always@(posedge clk)
    begin
        if(state == 3'b100)
            r_o = 1;
        else
            r_o = 0;
    end
    
    assign res = res_reg;
    assign err = over;
    
endmodule
