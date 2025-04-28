`timescale 1ns / 1ns


module testbench();
parameter ENTER_CODE = 8'h5A;
parameter STOP_CODE = 8'hF0;

parameter clk_period = 10;
parameter PS2_clk_period = 40;
parameter code_space_period = 60;
    
reg clk, PS2_clk, PS2_dat;
reg [7:0] key_code;
reg [3:0] i;
wire [7:0] AN;
wire [6:0] SEG;
wire [1:0] err;

always #(clk_period) clk <= ~clk;
initial
begin
    PS2_clk <= 1;
    PS2_dat <= 1;
    key_code <= 0;
    i = 0;
    
    clk <= 0;

    @(posedge clk);
    @(posedge clk);

    #(2*clk_period) key_code = HEX_CD(5'h04);
    PS2_press_and_release_key(key_code);
    #(2*clk_period) key_code = HEX_CD(5'h00);
    PS2_press_and_release_key(key_code);
    #(2*clk_period) key_code = HEX_CD(5'h0A);
    PS2_press_and_release_key(key_code);
    #(2*clk_period) key_code = HEX_CD(5'h00);
    PS2_press_and_release_key(key_code);
    
    #(2*clk_period) key_code = ENTER_CODE;
    PS2_press_and_release_key(key_code);
    
    #(2*clk_period) key_code = HEX_CD(5'h00);
    PS2_press_and_release_key(key_code);
    #(2*clk_period) key_code = HEX_CD(5'h00);
    PS2_press_and_release_key(key_code);
    #(2*clk_period) key_code = HEX_CD(5'h00);
    PS2_press_and_release_key(key_code);
    #(2*clk_period) key_code = HEX_CD(5'h00);
    PS2_press_and_release_key(key_code);
    
    #(2*clk_period) key_code = ENTER_CODE;
    PS2_press_and_release_key(key_code);
    
    #(2*clk_period) key_code = HEX_CD(5'h04);
    PS2_press_and_release_key(key_code);
    #(2*clk_period) key_code = HEX_CD(5'h00);
    PS2_press_and_release_key(key_code);
    #(2*clk_period) key_code = HEX_CD(5'h0A);
    PS2_press_and_release_key(key_code);
    #(2*clk_period) key_code = HEX_CD(5'h00);
    PS2_press_and_release_key(key_code);
    
    #(2*clk_period) key_code = ENTER_CODE;
    PS2_press_and_release_key(key_code);
    
    #(2*clk_period) key_code = HEX_CD(5'h00);
    PS2_press_and_release_key(key_code);
    #(2*clk_period) key_code = HEX_CD(5'h00);
    PS2_press_and_release_key(key_code);
    #(2*clk_period) key_code = HEX_CD(5'h00);
    PS2_press_and_release_key(key_code);
    #(2*clk_period) key_code = HEX_CD(5'h00);
    PS2_press_and_release_key(key_code);
    
    #(2*clk_period) key_code = ENTER_CODE;
    PS2_press_and_release_key(key_code);
    
    #(2*clk_period)
    #25000; //calculating
    #(2*clk_period) key_code = HEX_CD(5'h10);
    PS2_press_and_release_key(key_code);
    #(2*clk_period) key_code = HEX_CD(5'h10);
    PS2_press_and_release_key(key_code);
    #(2*clk_period) key_code = HEX_CD(5'h10);
    PS2_press_and_release_key(key_code);
    #(2*clk_period) key_code = HEX_CD(5'h10);
    PS2_press_and_release_key(key_code);
    #(2*clk_period) key_code = HEX_CD(5'h10);
    PS2_press_and_release_key(key_code);
    
    
    
    #(2*clk_period) key_code = HEX_CD(5'h11);
    PS2_press_and_release_key(key_code);
    
    
    #(2*clk_period) key_code = HEX_CD(5'h04);
    PS2_press_and_release_key(key_code);
    #(2*clk_period) key_code = HEX_CD(5'h00);
    PS2_press_and_release_key(key_code);
    #(2*clk_period) key_code = HEX_CD(5'h0A);
    PS2_press_and_release_key(key_code);
    #(2*clk_period) key_code = HEX_CD(5'h00);
    PS2_press_and_release_key(key_code);
    
    #(2*clk_period) key_code = ENTER_CODE;
    PS2_press_and_release_key(key_code);
    
    #(2*clk_period) key_code = HEX_CD(5'h00);
    PS2_press_and_release_key(key_code);
    #(2*clk_period) key_code = HEX_CD(5'h00);
    PS2_press_and_release_key(key_code);
    #(2*clk_period) key_code = HEX_CD(5'h00);
    PS2_press_and_release_key(key_code);
    #(2*clk_period) key_code = HEX_CD(5'h00);
    PS2_press_and_release_key(key_code);
    
    #(2*clk_period) key_code = ENTER_CODE;
    PS2_press_and_release_key(key_code);
    
    #(2*clk_period) key_code = HEX_CD(5'h04);
    PS2_press_and_release_key(key_code);
    #(2*clk_period) key_code = HEX_CD(5'h00);
    PS2_press_and_release_key(key_code);
    #(2*clk_period) key_code = HEX_CD(5'h0E);
    PS2_press_and_release_key(key_code);
    #(2*clk_period) key_code = HEX_CD(5'h00);
    PS2_press_and_release_key(key_code);
    
    #(2*clk_period) key_code = ENTER_CODE;
    PS2_press_and_release_key(key_code);
    
    #(2*clk_period) key_code = HEX_CD(5'h00);
    PS2_press_and_release_key(key_code);
    #(2*clk_period) key_code = HEX_CD(5'h00);
    PS2_press_and_release_key(key_code);
    #(2*clk_period) key_code = HEX_CD(5'h00);
    PS2_press_and_release_key(key_code);
    #(2*clk_period) key_code = HEX_CD(5'h00);
    PS2_press_and_release_key(key_code);
    
    #(2*clk_period) key_code = ENTER_CODE;
    PS2_press_and_release_key(key_code);
    
    #(2*clk_period)
    #25000; //calculating
    #(2*clk_period) key_code = HEX_CD(5'h10);
    PS2_press_and_release_key(key_code);
    #(2*clk_period) key_code = HEX_CD(5'h10);
    PS2_press_and_release_key(key_code);
    #(2*clk_period) key_code = HEX_CD(5'h10);
    PS2_press_and_release_key(key_code);
    #(2*clk_period) key_code = HEX_CD(5'h10);
    PS2_press_and_release_key(key_code);
    #(2*clk_period) key_code = HEX_CD(5'h10);
    PS2_press_and_release_key(key_code);
    
    $finish;
end

main MAIN(
    .clk(clk),
    .PS2_dat(PS2_dat),
    .PS2_clk(PS2_clk),
    .err_out(err),
    .AN(AN),
    .SEG(SEG)
);



// Генерация пакета данных
task automatic PS2_code_input(
    input [7:0] code
);
    begin
        PS2_dat <= 0;  
        for (i = 0; i < 8; i = i + 1)
        begin
            @(posedge PS2_clk)
            PS2_dat <= code[i];
        end
        @(posedge PS2_clk)
        PS2_dat <= ~^(code);
        
        @(posedge PS2_clk)
        PS2_dat <= 1;    
    end
endtask

// Нажатие и отжатие клавиши
task automatic PS2_press_and_release_key(
    input [7:0] code
);
    begin
        fork
            PS2_gen_byte_clk();    
            PS2_code_input(code); 
        join    
        #code_space_period;   
        fork
            PS2_gen_byte_clk();    
            PS2_code_input(STOP_CODE); 
        join   
        #code_space_period;
        fork
            PS2_gen_byte_clk();    
            PS2_code_input(code); 
        join
    end
endtask

// Генерация синхросигнала для передачи пакета
task automatic PS2_gen_byte_clk;
    begin
        #(clk_period);
        repeat(22)
        begin 
            PS2_clk <= ~PS2_clk;
            #(PS2_clk_period);
        end
        PS2_clk <= 1;
    end
endtask


function [7:0] HEX_CD;
    input [4:0] number_in;
    begin
        case(number_in)
            5'h00: HEX_CD = 8'h45;
            5'h01: HEX_CD = 8'h16;
            5'h02: HEX_CD = 8'h1E;
            5'h03: HEX_CD = 8'h26;
            5'h04: HEX_CD = 8'h25;
            5'h05: HEX_CD = 8'h2E;
            5'h06: HEX_CD = 8'h36;
            5'h07: HEX_CD = 8'h3D;
            5'h08: HEX_CD = 8'h3E;
            5'h09: HEX_CD = 8'h46;
            5'h0A: HEX_CD = 8'h1C;
            5'h0B: HEX_CD = 8'h32;
            5'h0C: HEX_CD = 8'h21;
            5'h0D: HEX_CD = 8'h23;
            5'h0E: HEX_CD = 8'h24;
            5'h0F: HEX_CD = 8'h2B;
            5'h10: HEX_CD = 8'h31;
            5'h11: HEX_CD = 8'h2D;
         default: HEX_CD = 0;
      endcase
    end  
endfunction


endmodule
