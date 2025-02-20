`timescale 1ns / 1ps

module testbench();

reg clk, btn;
reg [3:0] SW;
wire [7:0] AN;
wire [6:0] SEG;

reg CLOCK_ENABLE = 0;
reg btn_prev;
reg [31:0] shift_register;

wire btn_out;
wire btn_out_en;

initial
begin
    clk = 0;
    btn = 0;
    SW = 4'b0111;
    $srandom(232323);
    btn_prev = 0;
    shift_register = 0;
end

always #10 clk = ~clk;
always #2000
begin 
    btn_prev = btn;
    repeat($urandom_range(50,5))
    begin
        btn = $random;
        #2;
    end
    btn = ~btn_prev;
end
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

always @(posedge clk)
    CLOCK_ENABLE <= ~CLOCK_ENABLE;

always@(posedge clk)
begin
    if(btn_out_en)
        begin
            shift_register <= {shift_register[27:0], SW};
       end
end

FILTER #(.size(4)) btn_c_filter (
    .CLK(clk),
    .CLOCK_ENABLE(CLOCK_ENABLE),
    .IN_SIGNAL(btn),
    .OUT_SIGNAL(btn_out),
    .OUT_SIGNAL_ENABLE(btn_out_en)
);


endmodule
