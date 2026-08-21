`timescale 1ns/1ps
module tb_clkdiv();
    reg clk, rst_n;
    wire clk_2Hz;
    wire tick_1Hz;

    clkdiv #(100) dut(
        .clk(clk),
        .rst_n(rst_n),
        .clk_2Hz(clk_2Hz),
        .tick_1Hz(tick_1Hz)
    );

    initial begin
        clk = 0;
        forever #1 clk = ~clk;
    end

    initial begin
        $monitor("Time: %0t: clk_2Hz=%b, tick_1Hz=%b", $time, clk_2Hz, tick_1Hz);
        rst_n = 0; #100; rst_n = 1;
        repeat(500) @(posedge clk);
        $finish;
    end
endmodule