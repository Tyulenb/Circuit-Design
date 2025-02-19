`timescale 1ns / 1ps

module clk_div(
    input clk,
    output clk_div
    );
    
    reg [4:0] counter = 0;
    reg clk_div_reg = 0;
    always @(posedge clk)
    begin
        counter <= counter + 1;
        if (counter == 0)
        begin 
            clk_div_reg = ~clk_div_reg;
            counter <= 0;
        end
    end
    assign clk_div = clk_div_reg;
endmodule
