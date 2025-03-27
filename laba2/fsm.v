`timescale 1ns / 1ps

module fsm(
    input [15:0] dataIn,
    input R_I,
    input reset,
    input clk,
    output reg r_o,
    output reg [1:0] err,
    output [31:0] dataOut
    );
    
    reg [3:0] state;
    reg [31:0] reg_a;
    reg [31:0] reg_b;
    reg [31:0] step_1;
    reg [31:0] step_2;
    reg [31:0] counter;
    reg [4:0] iter;
    
    //reg for division
    reg [23:0] mant_res = 0;
    reg [24:0] reminder = 0;
    
    initial
    begin
        state = 0;
        reg_a = 0;
        reg_b = 0;
        step_1 = 0;
        step_2 = 0;
        counter = 0;
        r_o = 0;
        iter = 0;
    end
    
    always@(posedge clk)
    begin
        if(reset)
            state <= 0;
        else
        begin
            case(state)
                4'b0000:
                begin
                    reg_a <= 0;
                    reg_b <= 0;
                    counter <= 0;
                    err <= 0;
                    state <= 4'b0001;
                end
                4'b0001: if(R_I)
                begin
                    reg_a[31:16] <= dataIn;
                    state <= 4'b0010;
                end
                4'b0010: if(R_I)
                begin
                    reg_a[15:0] = dataIn;
                    if (reg_a == 0)
                    begin 
                        err <= 2'b11;
                        state <= 4'b0000;
                    end
                    else
                        state <= 4'b0011;    
                end
                4'b0011: if(R_I)
                begin
                    reg_b[31:16] <= dataIn;
                    state <= 4'b0100;
                end
                4'b0100: if(R_I)
                begin
                    reg_b[15:0] <= dataIn;
                    state <= 4'b1100;
                end
                4'b1100: //fraction check
                begin: fract
                    reg [4:0] lst;
                    lst = 0;
                    for(iter = 0; iter <= 22; iter = iter + 1)
                    begin
                        if (lst == 0 && reg_b[iter])
                            lst = iter;
                    end
                    if((reg_b[30:23] > 7'b1111111) ? (22-(reg_b[30:23]-7'b1111111)) >= lst : 1)
                    begin
                        err <= 2'b01;
                        state <= 4'b0000;
                    end
                    else
                        state <= 4'b0101;
                end
                4'b0101: //counter
                begin
                    if (counter[30:23]>reg_b[30:23] ? 1 : (counter[30:23]==reg_b[30:23] ? counter[22:0]>reg_b[22:0] : 0))
                        state <= 4'b0000;
                    else
                    begin: count //addition 1
                        reg [31:0] mx;
                        reg [31:0] mn;
                        reg [24:0] mant;
                        reg [22:0] mant_res;
                        reg [4:0] carry;
                        reg [31:0] one;
                        
                        one = 32'b00111111100000000000000000000000;
                        mx = (counter[30:23] > one[30:23]) ? one : (((counter[30:23] == one[30:23])) ? (counter[22:0] > one[22:0] ? counter : one) : one ); 
                        mn = (counter == mx) ? one : counter;
                        
                        mant = (mx[31]^mn[31]) ? {1'b1, mx[22:0]} - ({1'b1, mn[22:0]} >> (mx[30:23]-mn[30:23])): {1'b1, mx[22:0]}+({1'b1, mn[22:0]} >> (mx[30:23]-mn[30:23]));
                        
                        for(iter = 0; iter <= 24; iter = iter + 1)
                        begin
                            if(mant[iter])
                                carry = iter;
                        end
                        
                        mant_res = mant[24] ? (mant >> 1) : (mant << (23-carry)); 
                        counter = mx[31] ? {1'b1, mx[30:23]+(carry-5'b10111), mant_res} : {1'b0, mx[30:23]+(carry-5'b10111), mant_res};
                        state <= 4'b0110;
                    end
                end
                4'b0110: //power of 2
                begin: step1
                    reg [8:0] exp;
                    reg [47:0] mant;
                    reg [22:0] mant_res;
                    reg over;
                    mant = {1'b1,reg_a[22:0]}*{1'b1,reg_a[22:0]};
                    mant_res = mant[47] ? mant[46:24] : mant[45:23]; //10.1101 -> 1.01101; 01.1101 -> 1.1101
                    exp = {1'b0,reg_a[30:23]}+{1'b0,reg_a[30:23]}-9'b001111111+mant[47];
                    over = reg_a[30] ? exp < reg_a[30:23] : exp > reg_a[30:23]; // if x[30] is 1 -> decimal -> exp_1 < x[30:23] -> overflow
                    step_1 = over ? 0 : {1'b0, exp[7:0], mant_res};
                    if (over)
                    begin
                        err <= 2'b10;
                        state <= 4'b0000;
                    end    
                    else
                        state <= 4'b0111;
                end
                4'b0111: //step2
                begin
                    //dividing step_2 <= result;
                    mant_res <= {1'b1, reg_b[22:0]}/{1'b1, reg_a[22:0]};
                    reminder <= ({1'b1, reg_b[22:0]}%{1'b1, reg_a[22:0]}) << 1;
                    iter <= 0;
                    state <= 4'b1000;
                end
                4'b1000: //step2
                begin
                    if(!mant_res[23])
                    begin
                        if(reminder < {1'b1, reg_a[22:0]})
                        begin
                            mant_res <= mant_res << 1;
                            reminder <= reminder << 1;
                        end
                        else
                        begin
                            mant_res = (mant_res << 1) + reminder/{1'b1, reg_a[22:0]};
                            reminder = (reminder - {1'b1, reg_a[22:0]}) << 1;
                        end
                    end
                    if(iter < 22)
                        iter <= iter + 1;
                    else
                        state <= 4'b1001;
                end
                4'b1001: //step2
                begin: step2
                    reg [4:0] carry;
                    reg [8:0] exp;
                    for(iter = 0; iter <= 23; iter = iter + 1)
                    begin
                        if(mant_res[iter])
                            carry = iter;
                    end
                    mant_res = mant_res << (23 - carry);
                    exp = {1'b0,reg_b[30:23]}+7'b1111111-{1'b0,reg_a[30:23]};
                    step_2 = {reg_a[31]^reg_b[31], exp[7:0]-23+carry, mant_res[22:0]};
                    state <= 4'b1010;
                end
                4'b1010: //step3
                begin: res
                    //result     
                    reg [31:0] mx;
                    reg [31:0] mn;
                    reg [24:0] mant;
                    reg [22:0] mant_res;
                    reg [4:0] carry;
                    
                    mx = (step_1[30:23] > step_2[30:23]) ? step_1 : (((step_1[30:23] == step_2[30:23])) ? (step_1[22:0] > step_2[22:0] ? step_1 : step_2) : step_2 ); 
                    mn = (step_1 == mx) ? step_2 : step_1;
                    
                    mant = (mx[31]^mn[31]) ? {1'b1, mx[22:0]} - ({1'b1, mn[22:0]} >> (mx[30:23]-mn[30:23])): {1'b1, mx[22:0]}+({1'b1, mn[22:0]} >> (mx[30:23]-mn[30:23]));
                    

                    for(iter = 0; iter <= 24; iter = iter + 1)
                    begin
                        if(mant[iter])
                            carry = iter;
                    end
                    mant_res = mant[24] ? (mant >> 1) : (mant << (23-carry)); 
                    reg_a = mx[31] ? {1'b1, mx[30:23]+(carry-5'b10111), mant_res} : {1'b0, mx[30:23]+(carry-5'b10111), mant_res};
                    state <= 4'b1011;
                    
                end
                4'b1011:
                begin
                    if (err == 0)
                        state <= 4'b0101;
                    else
                        state <= 4'b0000;
                end
            endcase 
        end
    end
    
    always@(posedge clk)
    begin
        case(state)
            4'b0000: r_o <= 0;
            4'b0101: r_o <= 0;
            4'b1010: r_o <= 1;
        endcase
    end
    
    assign dataOut = reg_a;
    
endmodule
