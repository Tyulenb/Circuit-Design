`timescale 1ns / 1ps

module testbench();

reg clk, btn;
reg [3:0] SW;
wire [7:0] AN;
wire [6:0] SEG;

initial
begin
    clk = 0;
    btn = 0;
    SW = 4'b0111;
end

always #10 clk = ~clk;
always #2000 btn = ~btn;

reg [1:0] counter = 0;
always @(posedge btn)
begin
    case(counter)
        2'b00: SW <= 4'b0111;
        2'b01: SW <= 4'b1000;
        2'b10: SW <= 4'b0001;
        2'b11: SW <= 4'b0101;
    endcase
    counter <= counter + 2'b1;
end

main main1(
    .clk(clk),
    .btn_c(btn),
    .SW(SW),
    .AN(AN),
    .SEG(SEG)
);

endmodule
