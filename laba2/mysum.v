`timescale 1ns / 1ps


module mysum(
    input [31:0] a, b,
    output [31:0] res
    );
    
    wire [31:0] mx;
    wire [31:0] mn;
    
    assign mx = (a[30:23] > b[30:23]) ? a : (((a[30:23] == b[30:23])) ? (a[22:0] > b[22:0] ? a : b) : b ); 
    assign mn = (a == mx) ? b : a;
    
    
    wire [24:0] mant;
    wire [22:0] mant_res;
    wire [8:0] exp;
    
    assign mant = (mx[31]^mn[31]) ? {1'b1, mx[22:0]} - ({1'b1, mn[22:0]} >> (mx[30:23]-mn[30:23])): {1'b1, mx[22:0]}+({1'b1, mn[22:0]} >> (mx[30:23]-mn[30:23]));
    
    reg [4:0] carry;
    reg [4:0] iter;
    always@(mant)
    begin
        for(iter = 0; iter <= 24; iter = iter + 1)
        begin
            if(mant[iter])
                carry = iter;
        end
    end
    assign mant_res = mant[24] ? (mant >> 1) : (mant << (23-carry)); 
    assign exp = mx[30:23]+carry-5'b10111;
    assign res = mx[31] ? {1'b1, exp[7:0], mant_res} : {1'b0, exp[7:0], mant_res};
endmodule
