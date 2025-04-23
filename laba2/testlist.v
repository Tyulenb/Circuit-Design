`timescale 1ns / 1ps

module testlist();

reg clk, R_I, reset;
reg [15:0] dataIn;
wire [31:0] dataOut;
wire [1:0] err;
wire r_o;
reg [31:0] sequence [9:0];
reg [1:0] err_out;
reg [3:0] iter;
reg [3:0] num_of_elem_in;

initial 
begin
    clk = 0;
    reset = 0;
    R_I = 0;
    dataIn = 0;
    err_out = 0;
    num_of_elem_in = 0;
    for (iter = 0; iter <= 9; iter = iter+1)
    begin
        sequence[iter] = 0;
    end
end
    
always #5 clk = ~clk;
    
fsm fsm1(
    .clk(clk),
    .reset(reset),
    .R_I(R_I),
    .dataIn(dataIn),
    .dataOut(dataOut),
    .r_o(r_o),
    .err(err)
);

task reset_fsm;
    begin
        R_I = 0;
        dataIn = 0;
        err_out = 0;
        num_of_elem_in = 0;
        for (iter = 0; iter <= 9; iter = iter+1)
        begin
            sequence[iter] = 0;
        end
        @(posedge clk) reset <= 1;
        @(posedge clk) reset <= 0;
        repeat(2)
            @(posedge clk);
    end
endtask


task first_test;
    output reg test_result;
    begin
        reset_fsm();
        R_I = 1;
        dataIn = 16'b0100000010100000;
        @(posedge clk);
        dataIn = 16'b0000000000000000;
        @(posedge clk);
        dataIn = 16'b0100000010100000;
        @(posedge clk);
        dataIn = 16'b0000000000000000;
        @(posedge clk);
        
        while(num_of_elem_in < 3'b101)
        begin
            @(posedge clk);
            if(r_o)
            begin
                if(err==0)
                begin
                    sequence[num_of_elem_in] = dataOut;
                    num_of_elem_in = num_of_elem_in + 1'b1;
                end
                else
                    err_out = err;
            end
        end
        test_result = (sequence[0]==32'h40A00000 && sequence[1]==32'h41D00000 && sequence[2]==32'h44290C4E
                          && sequence[3]==32'h48DF427F && sequence[4]==32'h5242B4EA && err_out == 0);
        $display("Ожидаемый результат: err = 0, sequence[0] = 32'h40a00000, sequence[1] = 32'h41d00000, sequence[2] = 32'h44290e4e, sequence[3] = 32'h48df427f, sequence[4] = 32'h5242b4ea");
        $display("Фактический результат: err = 32'h%8h, sequence[0] = 32'h%8h, sequence[1] = 32'h%8h, sequence[2] = 32'h%8h, sequence[3] = 32'h%8h, sequence[4] = 32'h%8h", err, sequence[0], sequence[1], sequence[2], sequence[3], sequence[4]);
    end
endtask

task second_test;
    output reg test_result;
    begin
        reset_fsm();
        R_I = 1;
        dataIn = 16'b0100000011100000;
        @(posedge clk);
        dataIn = 16'b0000000000000000;
        @(posedge clk);
        dataIn = 16'b0100000011100000;
        @(posedge clk);
        dataIn = 16'b0000000000000000;
        @(posedge clk);
        
        while(num_of_elem_in < 3'b111 && !err_out)
        begin
            @(posedge clk);
            if(r_o)
            begin
                if(err==0)
                begin
                    sequence[num_of_elem_in] = dataOut;
                    num_of_elem_in = num_of_elem_in + 1'b1;
                end
                else
                    err_out = err;
            end
        end
        test_result = (sequence[0]==32'h40E00000 && sequence[1]==32'h42480000 && sequence[2]==32'h451C423D
                          && sequence[3]==32'h4ABEC196 && sequence[4]==32'h560E23ED && sequence[5]==32'h6C9DD7BF && err_out == 2'b01);
        $display("Ожидаемый результат: err = 01, sequence[0] = 32'h40e00000, sequence[1] = 32'h42480000, sequence[2] = 32'h451c423d, sequence[3] = 32'h4abec196, sequence[4] = 32'h560e23ed, sequence[5] = 32'h6c9dd7bf");
        $display("Фактический результат: err = %2b, sequence[0] = 32'h%8h, sequence[1] = 32'h%8h, sequence[2] = 32'h%8h, sequence[3] = 32'h%8h, sequence[4] = 32'h%8h, sequence[5] = 32'h%8h", err, sequence[0], sequence[1], sequence[2], sequence[3], sequence[4], sequence[5]);
    end
endtask

task third_test;
    output reg test_result;
    begin
        reset_fsm();
        R_I = 1;
        dataIn = 16'b0000000000000000;
        @(posedge clk);
        dataIn = 16'b0000000000000000;
        @(posedge clk);
        
        while(num_of_elem_in < 3'b111 && !err_out)
        begin
            @(posedge clk);
            if(r_o)
            begin
                if(err==0)
                begin
                    sequence[num_of_elem_in] = dataOut;
                    num_of_elem_in = num_of_elem_in + 1'b1;
                end
                else
                    err_out = err;
            end
        end
        test_result = (sequence[0]==32'h00000000 && err_out == 2'b11);
        $display("Ожидаемый результат: err = 11, sequence[0] = 32'h00000000");
        $display("Фактический результат: err = %2b, sequence[0] = 32'h%8h", err, sequence[0]);
    end
endtask

task fourth_test;
    output reg test_result;
    begin
        reset_fsm();
        R_I = 1;
        dataIn = 16'b0100000010100000;
        @(posedge clk);
        dataIn = 16'b0000000000000000;
        @(posedge clk);
        dataIn = 16'b0100000011100000;
        @(posedge clk);
        dataIn = 16'b0000000000110001;
        @(posedge clk);
        
        while(num_of_elem_in < 3'b111 && !err_out)
        begin
            @(posedge clk);
            if(r_o)
            begin
                if(err==0)
                begin
                    sequence[num_of_elem_in] = dataOut;
                    num_of_elem_in = num_of_elem_in + 1'b1;
                end
                else
                    err_out = err;
            end
        end
        test_result = (sequence[0]==32'h00000000 && err_out == 2'b10);
        $display("Ожидаемый результат: err = 10, sequence[0] = 32'h00000000");
        $display("Фактический результат: err = %2b, sequence[0] = 32'h%8h", err, sequence[0]);
    end
endtask

task fifth_test;
    output reg test_result;
    begin
        reset_fsm();
        R_I = 1;
        dataIn = 16'b0100000010100000;
        @(posedge clk);
        dataIn = 16'b0000000000000000;
        @(posedge clk);
        dataIn = 16'b0000000000000000;
        @(posedge clk);
        dataIn = 16'b0000000000000000;
        @(posedge clk);
        
        while(num_of_elem_in < 3'b111 && !err_out)
        begin
            @(posedge clk);
            if(r_o)
            begin
                if(err==0)
                begin
                    sequence[num_of_elem_in] = dataOut;
                    num_of_elem_in = num_of_elem_in + 1'b1;
                end
                else
                    err_out = err;
            end
        end
        test_result = (sequence[0]==32'h00000000 && err_out == 2'b10);
        $display("Ожидаемый результат: err = 10, sequence[0] = 32'h00000000");
        $display("Фактический результат: err = %2b, sequence[0] = 32'h%8h", err, sequence[0]);
    end
endtask

task sixth_test;
    output reg test_result;
    begin
        reset_fsm();
        R_I = 1;
        dataIn = 16'b0100000010100000;
        @(posedge clk);
        dataIn = 16'b0000000000000000;
        @(posedge clk);
        dataIn = 16'b1100000000000000;
        @(posedge clk);
        dataIn = 16'b0000000000000000;
        @(posedge clk);
        
        while(num_of_elem_in < 3'b111 && !err_out)
        begin
            @(posedge clk);
            if(r_o)
            begin
                if(err==0)
                begin
                    sequence[num_of_elem_in] = dataOut;
                    num_of_elem_in = num_of_elem_in + 1'b1;
                end
                else
                    err_out = err;
            end
        end
        test_result = (sequence[0]==32'h00000000 && err_out == 2'b10);
        $display("Ожидаемый результат: err = 10, sequence[0] = 32'h00000000");
        $display("Фактический результат: err = %2b, sequence[0] = 32'h%8h", err, sequence[0]);
    end
endtask
task seventh_test;
    output reg test_result;
    begin
        reset_fsm();
        R_I = 1;
        dataIn = 16'b1011111110000000;
        @(posedge clk);
        dataIn = 16'b0000000000000000;
        @(posedge clk);
        dataIn = 16'b0100000100100000;
        @(posedge clk);
        dataIn = 16'b0000000000000000;
        @(posedge clk);
        
        while(!err_out)
        begin
            @(posedge clk);
            if(r_o)
            begin
                if(err==0)
                begin
                    sequence[num_of_elem_in] = dataOut;
                    num_of_elem_in = num_of_elem_in + 1'b1;
                end
                else
                    err_out = err;
            end
        end
        test_result = (sequence[0]==32'hbf800000 && sequence[1]==32'hc1100000 && sequence[2]==32'h429fc71d
                          && sequence[3]==32'h45c772e1 && sequence[4]==32'h4c1b63cd && sequence[5]==32'h58bca402 && sequence[6]==32'h720b014c && err_out == 2'b01);
        $display("Ожидаемый результат: err = 01, sequence[0] = 32'hbf800000, sequence[1] = 32'hc1100000, sequence[2] = 32'h429fc71d, sequence[3] = 32'h45c772e1, sequence[4] = 32'h4c1b63cd, sequence[5] = 32'h58bca402, sequence[6] = 32'h720b014c");
        $display("Фактический результат: err = %2b, sequence[0] = 32'h%8h, sequence[1] = 32'h%8h, sequence[2] = 32'h%8h, sequence[3] = 32'h%8h, sequence[4] = 32'h%8h, sequence[5] = 32'h%8h, sequence[6] = 32'h%8h", err, sequence[0], sequence[1], sequence[2], sequence[3], sequence[4], sequence[5], sequence[6]);
    end
endtask


task test_1;
    reg test_result;
begin
    $display("\n[%0t]: Тест 1. X = 5; N = 5", $time);
    first_test(test_result);
    test_info(1, test_result);
end
endtask
task test_2;
    reg test_result;
begin
    $display("\n[%0t]: Тест 2. X = 7; N = 7", $time);
    second_test(test_result);
    test_info(2, test_result);
end
endtask
task test_3;
    reg test_result;
begin
    $display("\n[%0t]: Тест 3. X = 0; N = 7", $time);
    third_test(test_result);
    test_info(3, test_result);
end
endtask
task test_4;
    reg test_result;
begin
    $display("\n[%0t]: Тест 4. X = 5; N = 7.0000234", $time);
    fourth_test(test_result);
    test_info(4, test_result);
end
endtask
task test_5;
    reg test_result;
begin
    $display("\n[%0t]: Тест 5. X = 5; N = 0", $time);
    fifth_test(test_result);
    test_info(5, test_result);
end
endtask
task test_6;
    reg test_result;
begin
    $display("\n[%0t]: Тест 6. X = 5; N = -2", $time);
    sixth_test(test_result);
    test_info(6, test_result);
end
endtask
task test_7;
    reg test_result;
begin
    $display("\n[%0t]: Тест 7. X = -1; N = 10", $time);
    seventh_test(test_result);
    test_info(7, test_result);
end
endtask



localparam TEST_COUNT = 7; 
reg [0:TEST_COUNT-1] test_register; 
initial test_register = {TEST_COUNT{1'b0}}; 
initial 
begin
     test_1();
     test_2();
     test_3();
     test_4();
     test_5();
     test_6();
     test_7();
     test_show_stats();
end 
 
task test_info; 
    input integer test_number; 
    input test_result; 
begin 
    test_register[test_number-1] = test_result; 
    if (test_result) 
        $display("[%0t]: Тест %0d пройден.", $time, test_number); 
    else 
        $display("[%0t]: Тест %0d НЕ пройден.", $time, test_number);   
end 
endtask 

task test_show_stats; 
integer i, test_counter; 
begin 
    $display("\nРезультаты тестирования:"); 
    test_counter = 0; 
    for (i = 0; i < TEST_COUNT; i = i + 1) 
    begin 
        if (test_register[i]) 
            $display("Тест %2d пройден.", i+1); 
        else 
            $display("Тест %2d НЕ пройден.", i+1);     
        test_counter = test_counter + (test_register[i] ? 1 : 0); 
    end 
    $display("Пройдено тестов: %0d/%0d", test_counter, TEST_COUNT);   
end 
endtask 


endmodule
