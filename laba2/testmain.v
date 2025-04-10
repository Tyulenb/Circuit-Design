`timescale 1ns / 1ps


module testmain();

reg clk, btn_in, btn_nxt, btn_rst;
reg [15:0] data_in;
wire [7:0] AN;
wire [6:0] SEG;
wire [1:0] err;

initial
begin
    clk = 0;
    btn_in = 0;
    btn_nxt = 0;
    btn_rst = 0;
    data_in = 0;
    $srandom(232323); 
    //input
    #100;
    data_in = 16'b0100000010100000; //16'b0100000110001000;
    btn_in = 1;
    #200;
    btn_in = 0;
    #100;
    data_in = 16'b0000000000000000;
    btn_in = 1;
    #200;
    btn_in = 0;
    #100;
    data_in = 16'b0100000011100000; //16'b0100000010000000;
    btn_in = 1;
    #200;
    btn_in = 0;
    #100;
    data_in = 16'b0000000000000000;
    btn_in = 1;
    #200;
    btn_in = 0;
    #10000; //calculating
    //output
    btn_nxt = 1;
    #1000;
    btn_nxt = 0;
    #1000;
    btn_nxt = 1;
    #1000;
    btn_nxt = 0;
    #1000;
    btn_nxt = 1;
    #1000;
    btn_nxt = 0;
    #1000;
    btn_nxt = 1;
    #1000;
    btn_nxt = 0;
    #1000;
    btn_nxt = 1;
    #1000;
    btn_nxt = 0;
    #1000;
    btn_nxt = 1;
    #1000;
    btn_nxt = 0;
    #1000;
    btn_nxt = 1;
    #1000;
    btn_nxt = 0;
    #1000;
    
    //reseting
    #1000;
    btn_rst = 1;
    #1000;
    btn_rst = 0;
    #1000;
    data_in = 16'b0100000010100000;
    btn_in = 1;
    #1000;
    btn_in = 0;
    #1000;
    data_in = 16'b0000000000000000;
    btn_in = 1;
    #1000;
    btn_in = 0;
    #1000;
    data_in = 16'b0100000011100000;
    btn_in = 1;
    #1000;
    btn_in = 0;
    #1000;
    data_in = 16'b0000000000000000;
    btn_in = 1;
    #1000;
    btn_in = 0;
    #10000; //calculating
    //output
    btn_nxt = 1;
    #1000;
    btn_nxt = 0;
    #1000;
    btn_nxt = 1;
    #1000;
    btn_nxt = 0;
    #1000;
    btn_nxt = 1;
    #1000;
    btn_nxt = 0;
    #1000;
    btn_nxt = 1;
    #1000;
    btn_nxt = 0;
    #1000;
    btn_nxt = 1;
    #1000;
    btn_nxt = 0;
    #1000;
    btn_nxt = 1;
    #1000;
    btn_nxt = 0;
    #1000;
    btn_nxt = 1;
    #1000;
    btn_nxt = 0;
    #1000;
    $finish;
end

always #10 clk = ~clk;

main MAIN(
    .clk(clk),
    .data_in(data_in),
    .btn_in(btn_in),
    .btn_nxt(btn_nxt),
    .btn_rst(btn_rst),
    .err_out(err),
    .AN(AN),
    .SEG(SEG)
);

wire btn_in_out, btn_in_out_enable;

FILTER #(.size(2)) btn_in_filter (
    .CLK(clk),
    .CLOCK_ENABLE(1'b1),
    .IN_SIGNAL(btn_in),
    .OUT_SIGNAL(btn_in_out),
    .OUT_SIGNAL_ENABLE(btn_in_out_enable)
);
    
wire btn_nxt_out, btn_nxt_out_enable;

FILTER #(.size(2)) btn_nxt_filter (
    .CLK(clk),
    .CLOCK_ENABLE(1'b1),
    .IN_SIGNAL(btn_nxt),
    .OUT_SIGNAL(btn_nxt_out),
    .OUT_SIGNAL_ENABLE(btn_nxt_out_enable)
);
    
wire btn_rst_out, btn_rst_out_enable;

FILTER #(.size(2)) btn_rst_filter (
    .CLK(clk),
    .CLOCK_ENABLE(1'b1),
    .IN_SIGNAL(btn_rst),
    .OUT_SIGNAL(btn_rst_out),
    .OUT_SIGNAL_ENABLE(btn_rst_out_enable)
);

endmodule
