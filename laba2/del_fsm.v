`timescale 1ns / 1ps

module del_fsm(
    input [31:0] n, x,
    input clk, r_i,
    output [31:0] res,
    output reg r_o
    );
    

    
    reg [24:0] divisible;
    reg [24:0] divider;
    reg [7:0] divs_exp;
    reg [7:0] divd_exp;
    reg divd_fb;
    reg divs_fb;
    reg [4:0] state = 0;
    
    reg [4:0] iter = 0;
    
    reg [23:0] mant_res = 0;
    reg [24:0] reminder = 0;
    reg [4:0] carry = 0;
    reg [4:0] carry_sh = 0;
    reg [8:0] exp;
    reg [31:0] res_reg = 0;
    
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
        carry_sh = 0;
        exp = 0;
        res_reg = 0;
    end
    
    always@(posedge clk)
    begin
        case(state)
            5'b00000:
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
                carry <= 0;
                res_reg <= 0;
                state <= 5'b00001;
            end
            5'b00001: if(r_i)
            begin
                divisible <= {1'b1, n[22:0]};
                divider <= {1'b1, x[22:0]};
                divs_exp <= n[30:23];
                divd_exp <= x[30:23];
                divd_fb <= n[31];
                divs_fb <= x[31];
                state <= 5'b00010;
            end
            5'b00010:
            begin
                if(divisible >= divider)
                begin
                    divisible <= divisible-divider;
                    mant_res <= mant_res +1'b1;
                    state <= 5'b00010;
                end
                else
                begin
                    reminder <= divisible;
                    state <= 5'b00011;
                end
            end
            5'b00011:
            begin
                reminder <= reminder << 1;
                state <= 5'b00100;
            end
            5'b00100:
            begin
                if(!mant_res[23])
                    state <= 5'b00101;
                else
                    state <= 5'b01010; //normalizing step
            end
            5'b00101:
            begin
                if(reminder < divider)
                begin
                    mant_res <= mant_res << 1;
                    reminder <= reminder << 1;
                    state <= 5'b01001;
                end
                else
                    state <= 5'b00110;
            end
            5'b00110:
            begin
                mant_res <= (mant_res << 1) + 1'b1;
                state <= 5'b00111;
            end
            5'b00111:
            begin
                reminder <= reminder - divider;
                state <= 5'b01000;
            end
            5'b01000:
            begin
                reminder <= reminder << 1;
                state <= 5'b01001;
            end
            5'b01001:
            begin
                if(iter < 22)
                begin
                    iter <= iter + 1;
                    state <= 5'b00100;
                end
                else
                begin
                    state <= 5'b01010;
                    iter <= 0;
                end
            end
            5'b01010: //normalizing
            begin
                if(iter <= 23)
                    state <= 5'b01011;
                else
                    state <= 5'b01100;
            end
            5'b01011:
            begin
                if(mant_res[iter])
                begin
                    carry <= iter;
                    state <= 5'b01101;
                end
                else
                    state <= 5'b01101;
            end
            5'b01101:
            begin
                iter <= iter + 1;
                state <= 5'b01010;
            end
            5'b01100:
            begin
                carry_sh <= 23 - carry;
                state <= 5'b01110;
            end
            5'b01110:
            begin
                mant_res <= mant_res << carry_sh;
                state <= 5'b01111;
            end
            5'b01111:
            begin
                exp <= {1'b0,divs_exp}+7'b1111111-{1'b0,divd_exp};
                state <= 5'b10000;
            end
            5'b10000:
            begin
                res_reg <= {divs_fb^divd_fb, exp[7:0]-23+carry, mant_res[22:0]};
                state <= 5'b10001;
            end
            5'b10001:
            begin
                state <= 5'b00000;
            end
            default:
                state <= 5'b00000;
        endcase
    end
    
    always@(posedge clk)
    begin
        if(state == 5'b10001)
            r_o = 1;
        else
            r_o = 0;
    end    
    
    assign res = res_reg;
    
endmodule
