`timescale 1ns / 1ps

module clk_div #(size = 2)(
    input clk,
    output clk_div
    );
    
    reg [$clog2(size)-1:0] counter = 0;
    reg clk_div_reg = 0;
    always @(posedge clk)
    begin
        counter <= counter + 1;
        if (counter == size-1)
        begin 
            clk_div_reg = ~clk_div_reg;
            counter <= 0;
        end
    end
    assign clk_div = clk_div_reg;
 
 endmodule