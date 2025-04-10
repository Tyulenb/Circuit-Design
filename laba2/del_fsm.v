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
    reg [3:0] state = 0;
    
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
            4'b0000:
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
                state <= 4'b0001;
            end
            4'b0001: if(r_i)
            begin
                divisible <= {1'b1, n[22:0]};
                divider <= {1'b1, x[22:0]};
                divs_exp <= n[30:23];
                divd_exp <= x[30:23];
                divd_fb <= n[31];
                divs_fb <= x[31];
                state <= 4'b0010;
            end
            4'b0010:
            begin
                mant_res <= divisible/divider;
                state <= 4'b0011;
            end
            4'b0011:
            begin
                reminder <= (divisible%divider); 
                state <= 4'b0100;
            end
            4'b0100:
            begin
                reminder <= reminder << 1;
                state <= 4'b0101;
            end
            4'b0101:
            begin
                if(!mant_res[23])
                    state <= 4'b0110;
                else
                    state <= 4'b1010; //normalizing step
            end
            4'b0110:
            begin
                if(reminder < divider)
                begin
                    mant_res <= mant_res << 1;
                    reminder <= reminder << 1;
                    state <= 4'b1001;
                end
                else
                    state <= 4'b0111;
            end
            4'b0111:
            begin
                mant_res <= (mant_res << 1) + reminder/divider;
                state <= 4'b1000;
            end
            4'b1000:
            begin
                reminder <= (reminder - divider) << 1;
                state <= 4'b1001;
            end
            4'b1001:
            begin
                if(iter < 22)
                begin
                    iter <= iter + 1;
                    state <= 4'b0101;
                end
                else
                begin
                    state <= 4'b1010;
                    iter <= 0;
                end
            end
            4'b1010: //normalizing
            begin
                if(iter <= 23)
                    state <= 4'b1011;
                else
                    state <= 4'b1100;
            end
            4'b1011:
            begin
                if(mant_res[iter])
                begin
                    carry <= iter;
                    state <= 4'b1101;
                end
                else
                    state <= 4'b1101;
            end
            4'b1101:
            begin
                iter <= iter + 1;
                state <= 4'b1010;
            end
            4'b1100:
            begin
                mant_res <= mant_res << (23 - carry);
                state <= 4'b1110;
            end
            
            4'b1110:
            begin
                state <= 4'b0000;
            end
            default:
                state <= 4'b0000;
        endcase
    end
    
    always@(posedge clk)
    begin
        if(state == 4'b1110)
            r_o = 1;
        else
            r_o = 0;
    end    
    
    assign exp = {1'b0,divs_exp}+7'b1111111-{1'b0,divd_exp};
    assign res = {divs_fb^divd_fb, exp[7:0]-23+carry, mant_res[22:0]};
    
endmodule
