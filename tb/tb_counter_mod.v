`timescale 1ns/1ps

module tb_counter_mod();
    // Inputs
    reg clk;
    reg rst_n;
    reg en;

    parameter MOD = 24;
    localparam WIDTH = $clog2(MOD);

    // Outputs
    wire [WIDTH - 1:0] sec;
    wire m_en;

    // Instantiate the Unit Under Test (UUT)
    counter_mod #(.MOD(MOD)) dut (
        .clk(clk),
        .rst_n(rst_n),
        .en(en),
        .sec(sec),
        .m_en(m_en)
    );

    // Clock generation: 50 MHz (20ns period)
    always begin
        #10 clk = ~clk;
    end


    // Test sequence
    initial begin
        // Initialize inputs
        clk = 0;
        rst_n = 0;
        en = 0;

        @(negedge clk); rst_n = 1;

        repeat(100) @(negedge clk); en = 1;

        repeat(100) @(negedge clk);
        
        
        $finish;
    end

    // Monitor outputs
    initial begin
        $monitor("Time = %0t ns | rst_n = %b | en = %b | sec = %d | m_en = %b", 
                 $time, rst_n, en, sec, m_en);
    end


endmodule