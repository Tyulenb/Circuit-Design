`timescale 1ns / 1ps


module mydel(
    input [31:0] n, x,
    input clk,
    output [31:0] res
    );
    
    wire [8:0] exp;
    wire [23:0] mant1 = {1'b1, n[22:0]};
    wire [23:0] mant2 = {1'b1, x[22:0]};
    
    reg [24:0] divisible;
    reg [24:0] divider;
    reg [3:0] state = 0;
    assign exp = {1'b0,n[30:23]}+7'b1111111-{1'b0,x[30:23]};
    
    reg [4:0] iter = 0;
    
    reg [23:0] mant_res = 0;
    reg [24:0] reminder = 0;
    reg [4:0] carry = 0;
    
    always@(posedge clk)
    begin
        case(state)
            4'b0000:
            begin
                divisible = mant1;
                state <= 4'b0001;
            end
            4'b0001:
            begin
                divider = mant2;
                state <= 4'b0010;
            end
            4'b0010:
            begin
                mant_res <= divisible/divider;
                reminder <= (divisible%divider) << 1; 
                state <= 4'b0011;
            end
            4'b0011:
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
                    state <= 4'b0100;
            end
            4'b0100:
            begin
                for(iter = 0; iter <= 23; iter = iter + 1)
                begin
                    if(mant_res[iter])
                        carry = iter;
                end
                mant_res = mant_res << (23 - carry);
                state <= 4'b0101;
            end
        endcase
    end
    assign exp = {1'b0,n[30:23]}+7'b1111111-{1'b0,x[30:23]};
    assign res = {n[31]^x[31], exp[7:0]-23+carry, mant_res[22:0]};
    
endmodule

            /*
            begin
                for(iter = 0; iter <= 23; iter = iter + 1)
                begin
                    if(!mant_res[23])
                    begin
                        if(reminder < divider)
                        begin
                            mant_res = mant_res << 1;
                            reminder = reminder << 1;
                        end
                        else
                        begin
                            mant_res = (mant_res << 1) + 1'b1;
                            reminder = reminder - divider;
                        end
                    end
                    else
                        state <= 4'b0101;
                end
            end
            */