`timescale 1ns / 1ps

module main(
    input clk,
    input PS2_dat,
    input PS2_clk,
    output reg [1:0] err_out,
    output [7:0] AN,
    output [6:0] SEG
    );
    
    
reg CLOCK_ENABLE = 0;

always @(posedge clk)
    CLOCK_ENABLE <= ~CLOCK_ENABLE;
    
reg [3:0] num_of_elem_in;
reg [3:0] num_of_elem_out;
reg [3:0] iter;
reg [31:0] sequence [9:0];
reg nxt, rst, in;

wire r_o;
wire [31:0] data_out;
wire [1:0] err;
wire [3:0] state_out;
reg [15:0] data_in;

fsm FSM(
    .dataIn(data_in),
    .R_I(in),
    .reset(rst),
    .clk(clk),
    .r_o(r_o),
    .err(err),
    .dataOut(data_out),
    .state_out(state_out)
);

wire ps2_ro;
wire [4:0] ps2_out;
wire [2:0] ps2_flags;
PS2_Manager ps2_man(
    .clk(clk),
    .PS2_dat(PS2_dat),
    .PS2_clk(PS2_clk),
    .R_O(ps2_ro),
    .out(ps2_out),
    .flags(ps2_flags)
);

always@(posedge clk)
begin
    if(ps2_ro)
    begin
        if(ps2_flags == 3'b010)
            begin
                in <= 1'b1;
                $display("%4h", data_in);
                $display("ENTER");
            end 
        else if(ps2_flags == 3'b100)
            begin
                if(ps2_out == 5'b10000)
                    begin
                        nxt <= 1'b1;
                    end
                else if(ps2_out == 5'b10001)
                    begin
                        rst <= 1'b1;
                    end
            end
        else
            begin
                data_in <= {data_in[11:0], ps2_out[3:0]};
            end
    end
    if(in) in <= 0;
    if(nxt) nxt <= 0;
    if(rst) rst <= 0;
end

always@(posedge clk)
begin
    if(nxt)
    begin
        $display("%8h, %8h, %8h, %8h, %8h, %8h, %8h", sequence[0], sequence[1], sequence[2], sequence[3], sequence[4], sequence[5], sequence[6]);
        if(sequence[num_of_elem_out] == 0)
            num_of_elem_out <= 0;
        else
            num_of_elem_out <= num_of_elem_out+1'b1;
    end
    
    if(r_o)
    begin
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
    
    if(rst)
    begin
        err_out <= 0;
        num_of_elem_in <= 0;
        num_of_elem_out <= 0;
        for (iter = 0; iter <= 9; iter = iter+1)
        begin
            sequence[iter] = 0;
        end
    end
    
end

initial 
begin
    err_out = 0;
    num_of_elem_in = 0;
    num_of_elem_out = 0;
    data_in = 0;
    in = 0;
    rst = 0;
    nxt = 0;
    for (iter = 0; iter <= 9; iter = iter+1)
    begin
        sequence[iter] = 0;
    end
end    

wire clk_div_out;
clk_div #(.size(2)) clk_div1 (
    .clk(clk),
    .clk_div(clk_div_out)
);
        
SevenSegmentLED seg(
    .clk(clk_div_out),
    .RESET(rst),
    .NUMBER(sequence[num_of_elem_out]),
    .AN_MASK(8'b00000000),
    .AN(AN),
    .SEG(SEG)
); 

endmodule