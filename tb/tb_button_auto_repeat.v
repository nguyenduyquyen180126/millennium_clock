`timescale 1ns/1ps

module tb_button_auto_repeat();

    reg clk;
    reg rst_n;
    reg btn_clean;
    wire pulse_out;

    // Instantiate DUT with custom parameters for fast simulation:
    // CLK_FREQ = 1000 Hz, meaning 1 cycle = 1 ms.
    // HOLD_DELAY_MS = 50 ms (50 clock cycles required to enter hold/repeat mode)
    // REPEAT_RATE_MS = 10 ms (10 clock cycles between repeat pulses)
    button_auto_repeat #(
        .CLK_FREQ(1000),
        .HOLD_DELAY_MS(50),
        .REPEAT_RATE_MS(10)
    ) dut (
        .clk(clk),
        .rst_n(rst_n),
        .btn_clean(btn_clean),
        .pulse_out(pulse_out)
    );

    // 10ns clock period
    initial begin
        clk = 0;
        forever #5 clk = ~clk;
    end

    // Monitor pulses and signals
    initial begin
        $monitor("Time: %0t ns | rst_n: %b | btn: %b | pulse: %b | state: hold_cnt=%0d, is_holding=%b", 
                 $time, rst_n, btn_clean, pulse_out, dut.rep_cnt, dut.is_holding);
    end

    initial begin
        // Initialize inputs
        rst_n = 0;
        btn_clean = 0;
        #20;
        
        // Release reset
        rst_n = 1;
        #20;

        $display("\n--- Test Case 1: Short Press (No Auto-Repeat) ---");
        // Press button for 15 cycles (less than 50)
        @(posedge clk);
        btn_clean = 1;
        repeat (15) @(posedge clk);
        btn_clean = 0;
        repeat (10) @(posedge clk);

        $display("\n--- Test Case 2: Long Press (Enter Auto-Repeat) ---");
        // Press button for 100 cycles
        @(posedge clk);
        btn_clean = 1;
        repeat (100) @(posedge clk);
        btn_clean = 0;
        repeat (15) @(posedge clk);

        $display("\n--- Test Case 3: Reset during hold/repeat ---");
        // Press button and reset in the middle
        @(posedge clk);
        btn_clean = 1;
        repeat (30) @(posedge clk);
        $display("Asserting reset...");
        rst_n = 0;
        repeat (5) @(posedge clk);
        rst_n = 1;
        repeat (20) @(posedge clk);
        btn_clean = 0;
        repeat (10) @(posedge clk);

        $display("\n--- Simulation finished ---");
        $finish;
    end

endmodule
