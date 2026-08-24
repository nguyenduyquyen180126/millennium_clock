`timescale 1ns/1ps

module tb_counter_nam;
    reg clk, rst_n, inc_auto, inc_manual, dec_manual;
    wire [13:0] value;
    wire leap;

    counter_nam dut(
        .clk(clk),
        .rst_n(rst_n),
        .inc_auto(inc_auto),
        .inc_manual(inc_manual),
        .dec_manual(dec_manual),
        .value(value),
        .leap(leap)
    );
    always #5 clk = ~clk;

    initial begin
        $monitor("T=%0t | clk=%b rst_n=%b | auto=%b inc=%b dec=%b | year=%0d | leap=%b",
                 $time, clk, rst_n, inc_auto, inc_manual, dec_manual, value, leap);
    end

    initial begin
        clk = 0;
        rst_n = 0;
        inc_auto = 0;
        inc_manual = 0;
        dec_manual = 0;
        #20 rst_n = 1;
        inc_auto = 1;

        repeat(5) begin
            @(posedge clk);
            #1;
            $display("Time: %0t, value: %d, leap: %b", $time, value, leap);
        end
        inc_auto = 0;
        inc_manual = 1;
        @(posedge clk);
        #1; 
        $display("Time_INCREASE: %0t, value: %d, leap: %b", $time, value, leap);
        inc_manual = 0;
        dec_manual = 1;
        @(posedge clk);
        #1;
        $display("Time_DECREASE: %0t, value: %d, leap: %b", $time, value, leap);
        dec_manual = 0;
        #20;
        $finish;
    end

endmodule