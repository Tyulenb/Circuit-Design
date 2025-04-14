`timescale 1ns / 1ps

module testbench();

reg clk, btn;
reg [3:0] SW;
wire [7:0] AN;
wire [6:0] SEG;

reg btn_prev;

reg [31:0] shift_register;
reg [7:0] an_mask;

wire btn_c_out, btn_c_out_enable;

initial
begin
    clk = 0;
    btn = 0;
    SW = 4'b0000;
    $srandom(232323);
    btn_prev = 0;
    shift_register = 0;
    an_mask <= 8'b11111111;
end

always #10 clk = ~clk;

always #10000
begin 
    btn_prev = btn;
    repeat($urandom_range(50,5))
    begin
        btn = $random;
        #2;
    end
    btn = ~btn_prev;
end


reg [4:0] counter = 0;
always @(posedge btn_c_out_enable)
begin
    case(counter)
        4'b0000: SW <= 4'b0000;
        4'b0001: SW <= 4'b0001;
        4'b0010: SW <= 4'b0010;
        4'b0011: SW <= 4'b0011;
        4'b0100: SW <= 4'b0100;
        4'b0101: SW <= 4'b0101;
        4'b0110: SW <= 4'b0110;
        4'b0111: SW <= 4'b0111;
        4'b1000: SW <= 4'b1000;
        4'b1001: SW <= 4'b1001;
        4'b1010: SW <= 4'b1010;
        4'b1011: SW <= 4'b1011;
        4'b1100: SW <= 4'b1100;
        4'b1101: SW <= 4'b1101;
        4'b1110: SW <= 4'b1110;
        4'b1111: SW <= 4'b1111;
    endcase
    counter <= counter + 5'b1;
    if (counter == 5'b10000)
        $finish;
end 

main main1(
    .clk(clk),
    .btn_c(btn),
    .SW(SW),
    .AN(AN),
    .SEG(SEG)
);

reg CLOCK_ENABLE = 0;

always @(posedge clk)
    CLOCK_ENABLE <= ~CLOCK_ENABLE;

FILTER #(.size(4)) btn_c_filter (
    .CLK(clk),
    .CLOCK_ENABLE(CLOCK_ENABLE),
    .IN_SIGNAL(btn),
    .OUT_SIGNAL(btn_c_out),
    .OUT_SIGNAL_ENABLE(btn_c_out_enable)
);

always@(posedge clk)
begin
    if(btn_c_out_enable)
        begin
            shift_register <= {shift_register[27:0], SW};
            an_mask <= {an_mask[6:0], 1'b0};
       end
end

wire clk_div_out;
clk_div #(.size(16)) clk_div1 (
    .clk(clk),
    .clk_div(clk_div_out)
);

endmodule