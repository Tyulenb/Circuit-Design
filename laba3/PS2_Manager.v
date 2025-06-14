module PS2_Manager (
    input clk,
    input PS2_dat,
    input PS2_clk,
    
    output reg R_O,
    output [4:0] out,
    output [2:0] flags
);
// ��������� �������� ��������� ������� ���������� ������ ������
parameter WAIT_ONE = 0;
// ��������� �������� ������ ������� ���������� ������ ������
parameter WAIT_ZERO = 1;
reg state;
// ������ ������ ����� ������ ������ PS2
wire PS2_R_O, PS2_ERROR; 
wire [7:0] PS2_out;
// ������� ����� ������� �������
reg release_flag;

initial begin
    state = 0; R_O = 0;
    release_flag = 0;
end

always@(posedge clk)
begin
    case(state)
        WAIT_ONE: begin
            if (PS2_R_O) begin
                if (!PS2_ERROR) begin
                    if (PS2_out == 8'hF0)
                        release_flag <= 1;
                    else if (release_flag)
                    begin
                        R_O <= 1;
                        release_flag <= 0;
                    end  
                end
                state <= WAIT_ZERO;     
            end
        end
        WAIT_ZERO: begin
            R_O <= 0; 
            if (!PS2_R_O) 
                state <= WAIT_ONE;  
        end       
   endcase  
end
// ���� ������ ������
PS2 ps2(
    .clk(clk),
    .PS2_clk(PS2_clk), .PS2_dat(PS2_dat),
    .out(PS2_out), .R_O(PS2_R_O),
    .ERROR(PS2_ERROR)
);
// ���������� ������
PS2_DC dc(.keycode(PS2_out), .out(out), .flags(flags));
endmodule
