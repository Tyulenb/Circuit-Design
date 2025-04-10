`timescale 1ns / 1ps

module testbench();
    reg clk, R_I, reset;
    reg [15:0] dataIn;
    wire [31:0] dataOut;
    wire [1:0] err;
    wire r_o;
    
    initial 
    begin
        clk = 0;
        reset = 0;
        R_I = 0;
        dataIn = 0;
        #20;
        reset = 0;
        dataIn = 16'b0100000010100000;
        R_I = 1;
        #20;
        R_I = 0;
        dataIn = 0;
        #20;
        dataIn = 16'b0000000000000000;
        R_I = 1;
        #20;
        dataIn = 16'b0100000011100000;//16'b0100000011000000;
        R_I = 1;
        #20;
        dataIn = 16'b0000000000000000;
        R_I = 1;
        #30
        R_I = 0;
    end
    
    always #10 clk = ~clk;
    
    fsm fsm1(
        .clk(clk),
        .reset(reset),
        .R_I(R_I),
        .dataIn(dataIn),
        .dataOut(dataOut),
        .r_o(r_o),
        .err(err)
    );
    
    
endmodule
