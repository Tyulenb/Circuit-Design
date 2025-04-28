`timescale 1ns / 1ps

module fsm(
    input [15:0] dataIn,
    input R_I,
    input reset,
    input clk,
    output reg r_o,
    output reg [1:0] err,
    output [31:0] dataOut,
    output [3:0] state_out
    );
    
    
    //main
    reg [3:0] state;
    reg [31:0] reg_x;
    reg [31:0] reg_n;
    reg [31:0] counter;
    reg [31:0] step1;
    reg [31:0] step2;

    //fraction_check
    reg fr_i;
    reg fr_flag;
    wire fr_o;
    wire fr_res;
    
    //increment
    reg incr_i;
    reg incr_flag;
    wire incr_o;
    wire [31:0] inc_res;
    
    //sum
    reg sm_ri;
    reg sm_flag;
    wire sm_ro;
    wire [31:0] sm_res;
    
    //del
    reg dl_ri;
    reg dl_flag;
    wire dl_ro;
    wire [31:0] dl_res;
    
    //pow
    reg pw_ri;
    reg pw_flag;
    wire pw_ro;
    wire pw_err;
    wire [31:0] pw_res;
    
    initial
    begin
        err = 0;
        state = 0;
        reg_x = 0;
        reg_n = 0;
        counter = 0;
        r_o = 0;
        step1 = 0;
        step2 = 0;
        
        fr_i = 0;
        fr_flag = 1;
        incr_i = 0;
        incr_flag = 1;
        sm_ri = 0;
        sm_flag = 1;
        dl_ri = 0;
        dl_flag = 1;
        pw_ri = 0;
        pw_flag = 1;
    end
    
    always@(posedge clk)
    begin
        if(reset)
        begin
            state <= 0;
        end
        else
        begin
            case(state)
                4'b0000:
                begin
                    reg_x <= 0;
                    reg_n <= 0;
                    counter <= 0;
                    err <= 0;
                    state <= 4'b0001;
                    fr_i <= 0;
                    fr_flag <= 1;
                    incr_i <= 0;
                    incr_flag <= 1;
                    sm_ri <= 0;
                    sm_flag <= 1;
                    dl_ri <= 0;
                    dl_flag <= 1;
                    pw_ri <= 0;
                    pw_flag <= 1;
                end
                4'b0001: if(R_I)
                begin
                    reg_x[31:16] <= dataIn;
                    state <= 4'b0010;
                end
                4'b0010: if(R_I)
                begin
                    reg_x[15:0] = dataIn;
                    if (reg_x == 0)
                    begin 
                        err <= 2'b11;
                        state <= 4'b1110;
                    end
                    else
                        state <= 4'b0011;    
                end
                4'b0011: if(R_I)
                begin
                    reg_n[31:16] <= dataIn;
                    state <= 4'b0100;
                end
                4'b0100: if(R_I)
                begin
                    reg_n[15:0] <= dataIn;
                    state <= 4'b1100;
                end
                4'b1100: //fraction check
                begin
                    if(fr_o)
                    begin
                        if(fr_res)
                        begin
                            err <= 2'b10;
                            reg_x <= 0;
                            fr_flag <= 1;
                            state <= 4'b1110;
                        end
                        else
                        begin
                            fr_flag <= 1;
                            state <= 4'b1101;
                        end
                    end
                    else
                    begin
                        if(fr_flag)
                        begin
                            fr_i <= 1;
                            fr_flag <= 0;
                        end
                        else
                            fr_i <= 0;
                   end
                end
                4'b1101:
                begin
                    state <= 4'b0101;
                end
                4'b0101: //counter
                begin
                    if(incr_o)
                    begin
                        counter = inc_res;
                        if (counter[30:23]>reg_n[30:23] ? 1 : (counter[30:23]==reg_n[30:23] ? counter[22:0]>=reg_n[22:0] : 0))
                        begin
                            state <= 4'b0000;
                            incr_flag <= 1;
                        end
                        else
                        begin
                            incr_flag <= 1;
                            state <= 4'b0110;
                        end
                    end
                    else
                    begin
                        if(incr_flag)
                        begin
                            incr_i <= 1;
                            incr_flag <= 0;
                        end
                        else
                            incr_i <= 0;
                    end    
                end
                4'b0110: //power of 2
                begin
                    //$display(rega);
                    if(pw_ro)
                    begin
                        if (pw_err)
                        begin
                            err <= 2'b01;
                            reg_x <= 0;
                            state <= 4'b1110;
                            pw_flag <= 1;
                        end
                        else
                        begin
                            pw_flag <= 1;
                            step1 <= pw_res;
                            state <= 4'b0111;
                        end
                    end
                    else
                    begin
                        if(pw_flag)
                        begin
                            pw_ri <= 1;
                            pw_flag <= 0;
                        end
                        else
                            pw_ri <= 0;
                    end
                        
                end
                4'b0111: //step2
                begin
                    if(dl_ro)
                    begin
                        dl_flag <= 1;
                        step2 <= dl_res;
                        state <= 4'b1000;
                    end
                    else
                    begin
                        if(dl_flag)
                        begin
                            dl_ri <= 1;
                            dl_flag <= 0;
                        end
                        else
                            dl_ri <= 0;
                   end
                end
                4'b1000: //step3
                begin
                    //result     
                    if(sm_ro)
                    begin
                        sm_flag <= 1;
                        reg_x <= sm_res;
                        state <= 4'b1110;
                    end
                    else
                    begin
                        if(sm_flag)
                        begin
                            sm_ri = 1;
                            sm_flag = 0;
                        end
                        else
                            sm_ri = 0;
                    end
                    
                end
                4'b1110: //r_o condition
                begin
                    if(err==0)
                        state <= 4'b0101;
                    else
                        state <= 4'b0000;
                end
            endcase 
        end
    end
    
    always@(posedge clk)
    begin
        case(state)
            4'b0000: r_o <= 0;
            4'b0101: r_o <= 0;
            4'b1110: r_o <= 1;
            4'b1101: r_o <= 1;
        endcase
    end
    
    assign dataOut = reg_x;
    assign state_out = state;
    
    checkfr_fsm FR(
        .clk(clk),
        .r_i(fr_i),
        .num_in(reg_n),
        .res(fr_res),
        .r_o(fr_o)
    );
    
    sum_fsm INCR(
        .clk(clk),
        .r_i(incr_i),
        .r_o(incr_o),
        .a(counter),
        .b(32'b00111111100000000000000000000000),
        .res(inc_res)
    );
    
    sum_fsm SM(
        .clk(clk),
        .r_i(sm_ri),
        .r_o(sm_ro),
        .a(step1),
        .b(step2),
        .res(sm_res)
    );
    
    pow2_fsm PW(
        .clk(clk),
        .r_i(pw_ri),
        .r_o(pw_ro),
        .x(reg_x),
        .err(pw_err),
        .res(pw_res)
    );
    
    del_fsm DL(
        .clk(clk),
        .r_i(dl_ri),
        .r_o(dl_ro),
        .n(reg_n),
        .x(reg_x),
        .res(dl_res)
    );
    
endmodule