`timescale 1ns / 1ps

module del_fsm(
    input [31:0] n, x,
    input clk, r_i,
    output [31:0] res,
    output reg r_o
    );
    
    wire [8:0] exp;

    
    reg [24:0] divisible;
    reg [24:0] divider;
    reg [7:0] divs_exp;
    reg [7:0] divd_exp;
    reg divd_fb;
    reg divs_fb;
    reg [2:0] state = 0;
    
    reg [4:0] iter = 0;
    
    reg [23:0] mant_res = 0;
    reg [24:0] reminder = 0;
    reg [4:0] carry = 0;
    
    initial
    begin
        r_o = 0;
        state = 0;
        divisible = 0;
        divider = 0;
        divs_exp = 0;
        divd_exp = 0;
        divd_fb = 0;
        divs_fb = 0;
        iter = 0;
        mant_res = 0;
        reminder = 0;
        carry = 0;
    end
    
    always@(posedge clk)
    begin
        case(state)
            3'b000:
            begin
                divisible <= 0;
                divider <= 0;
                divs_exp <= 0;
                divd_exp <= 0;
                divd_fb <= 0;
                divs_fb <= 0;
                iter <= 0;
                mant_res <= 0;
                reminder <= 0;
                carry = 0;
                state <= 3'b001;
            end
            3'b001: if(r_i)
            begin
                divisible <= {1'b1, n[22:0]};
                divider <= {1'b1, x[22:0]};
                divs_exp <= n[30:23];
                divd_exp <= x[30:23];
                divd_fb <= n[31];
                divs_fb <= x[31];
                state <= 4'b010;
            end
            3'b010:
            begin
                mant_res <= divisible/divider;
                reminder <= (divisible%divider) << 1; 
                state <= 3'b011;
            end
            3'b011:
            begin
                if(!mant_res[23])
                begin
                    if(reminder < divider)
                    begin
                        mant_res <= mant_res << 1;
                        reminder <= reminder << 1;
                    end
                    else
                    begin
                        mant_res = (mant_res << 1) + reminder/divider;
                        reminder = (reminder - divider) << 1;
                    end
                end
                if(iter < 22)
                    iter <= iter + 1;
                else
                    state <= 3'b100;
            end
            3'b100:
            begin
                for(iter = 0; iter <= 23; iter = iter + 1)
                begin
                    if(mant_res[iter])
                        carry = iter;
                end
                mant_res = mant_res << (23 - carry);
                state <= 3'b101;
            end
            3'b101:
                state <= 3'b000;
        endcase
    end
    
    always@(posedge clk)
    begin
        if(state == 4'b0101)
            r_o = 1;
        else
            r_o = 0;
    end    
    
    assign exp = {1'b0,divs_exp}+7'b1111111-{1'b0,divd_exp};
    assign res = {divs_fb^divd_fb, exp[7:0]-23+carry, mant_res[22:0]};
    
endmodule
