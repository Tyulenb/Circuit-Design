`timescale 1ns / 1ps

module main(
    input clk,
    input [15:0] data_in,
    input btn_in,
    input btn_nxt,
    input btn_rst,
    output reg [1:0] err_out,
    output [7:0] AN,
    output [6:0] SEG
    );
    
reg CLOCK_ENABLE = 0;

always @(posedge clk)
    CLOCK_ENABLE <= ~CLOCK_ENABLE;

wire btn_in_out, btn_in_out_enable;

FILTER #(.size(16)) btn_in_filter (
    .CLK(clk),
    .CLOCK_ENABLE(1'b1),
    .IN_SIGNAL(btn_in),
    .OUT_SIGNAL(btn_in_out),
    .OUT_SIGNAL_ENABLE(btn_in_out_enable)
);
    
wire btn_nxt_out, btn_nxt_out_enable;

FILTER #(.size(16)) btn_nxt_filter (
    .CLK(clk),
    .CLOCK_ENABLE(1'b1),
    .IN_SIGNAL(btn_nxt),
    .OUT_SIGNAL(btn_nxt_out),
    .OUT_SIGNAL_ENABLE(btn_nxt_out_enable)
);
    
wire btn_rst_out, btn_rst_out_enable;

FILTER #(.size(16)) btn_rst_filter (
    .CLK(clk),
    .CLOCK_ENABLE(1'b1),
    .IN_SIGNAL(btn_rst),
    .OUT_SIGNAL(btn_rst_out),
    .OUT_SIGNAL_ENABLE(btn_rst_out_enable)
);
    
reg [3:0] num_of_elem_in;
reg [3:0] num_of_elem_out;
reg [3:0] iter;
reg [31:0] sequence [9:0];

initial 
begin
    err_out = 0;
    num_of_elem_in = 0;
    num_of_elem_out = 0;
    for (iter = 0; iter <= 9; iter = iter+1)
    begin
        sequence[iter] = 0;
    end
end    

wire r_o;
wire [31:0] data_out;
wire err;
fsm FSM(
    .dataIn(data_in),
    .R_I(btn_in_out_enable),
    .reset(btn_rst_out_enable),
    .clk(clk),
    .r_o(r_o),
    .err(err),
    .dataOut(data_out)
);


always@(posedge clk)
begin
    if(btn_nxt_out_enable)
    begin
        //$display(sequence);
        if(sequence[num_of_elem_out] == 0)
            num_of_elem_out <= 0;
        else
            num_of_elem_out <= num_of_elem_out+1'b1;
    end
    
    if(r_o)
    begin
        $display(sequence);
        if(err==0)
        begin
            sequence[num_of_elem_in] <= data_out;
            num_of_elem_in <= num_of_elem_in + 1'b1;
        end
        else
        begin
            err_out <= err;
            num_of_elem_in <= num_of_elem_in;
        end
    end
    
    if(btn_rst_out_enable || btn_in_out_enable)
    begin
        err_out <= 0;
        num_of_elem_in <= 0;
        num_of_elem_out <= 0;
    end
    
end

wire clk_div_out;
clk_div #(.size(8192)) clk_div1 (
    .clk(clk),
    .clk_div(clk_div_out)
);
        
    
SevenSegmentLED seg(
    .clk(clk_div_out),
    .RESET(btn_rst_out_enable),
    .NUMBER(sequence[num_of_elem_out]),
    .AN_MASK(8'b00000000),
    .AN(AN),
    .SEG(SEG)
); 

endmodule
