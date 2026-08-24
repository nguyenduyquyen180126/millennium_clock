`timescale 1ns/1ps

module tb_counter_chung3;
    reg clk, rst_n;
    reg inc_auto, inc_manual, dec_manual;
    wire [5:0] value;
    wire carry_out;
    counter_mod #(.MAX_CHECK(60)) dut(
        .clk(clk),
        .rst_n(rst_n),
        .inc_auto(inc_auto),
        .inc_manual(inc_manual),
        .dec_manual(dec_manual),
        .value(value),
        .carry_out(carry_out)
    );
    always #5 clk = ~clk;
    initial begin
        clk = 0;
        rst_n = 0;
        inc_auto = 0;
        inc_manual = 0;
        dec_manual = 0;
        #20 rst_n = 1;
        inc_auto =1;

        repeat(5) begin
            @(posedge clk);
            #1;
            $display("Time: %0t, value: %d, carry_out: %b", $time, value, carry_out);
        end

        inc_auto =0;
        inc_manual =1;
        @(posedge clk);
        #1;
        $display("Time_INCREASE: %0t, value: %d, carry_out: %b", $time, value, carry_out);
        inc_manual =0;
        dec_manual =1;
        @(posedge clk);
        #1;
        $display("Time_DECREASE: %0t, value: %d, carry_out: %b", $time, value, carry_out);
        dec_manual =0;  
        #20;
        $finish;
    end
endmodule