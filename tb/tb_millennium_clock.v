`timescale 1us/1ns

module tb_millennium_clock;
    reg clk;
    reg rst_n;
    reg up_btn;
    reg down_btn;
    reg [1:0] adj_target;
    reg adj_en;
    reg mode;
    
    wire [13:0] led_hh_dd;
    wire [13:0] led_mimi_momo;
    wire [27:0] led_ss_yyyy;

    // Instantiate millennium_clock with overridden parameters for fast simulation:
    // CLK_FREQ = 1000 Hz (1 kHz)
    // DEBOUNCE_TIME_MS = 5 ms (means 5 clock cycles of stability required)
    millennium_clock #(
        .CLK_FREQ(1000),
        .DEBOUNCE_TIME_MS(5)
    ) dut (
        .clk(clk),
        .rst_n(rst_n),
        .up_btn(up_btn),
        .down_btn(down_btn),
        .adj_target(adj_target),
        .adj_en(adj_en),
        .mode(mode),
        .led_hh_dd(led_hh_dd),
        .led_mimi_momo(led_mimi_momo),
        .led_ss_yyyy(led_ss_yyyy)
    );

    // 1 kHz clock generator (period = 1000 us)
    initial begin
        clk = 0;
        forever #500 clk = ~clk;
    end

    // 7-segment decoder function for debugging
    function [3:0] seg2number(input [6:0] seg);
        case(seg)
            7'b1000000: seg2number = 4'h0;
            7'b1111001: seg2number = 4'h1;
            7'b0100100: seg2number = 4'h2;
            7'b0110000: seg2number = 4'h3;
            7'b0011001: seg2number = 4'h4;
            7'b0010010: seg2number = 4'h5;
            7'b0000010: seg2number = 4'h6;
            7'b1111000: seg2number = 4'h7;
            7'b0000000: seg2number = 4'h8;
            7'b0010000: seg2number = 4'h9;
            default:    seg2number = 4'hF; // Blank / Unknown
        endcase
    endfunction

    // Task to render the current 7-segment outputs in readable hex digits
    task display_outputs();
        $display("[%0t us] Display [HH/DD]: %x%x | [MM/MO]: %x%x | [SS/YYYY]: %x%x%x%x", 
                 $time,
                 seg2number(led_hh_dd[13:7]), seg2number(led_hh_dd[6:0]),
                 seg2number(led_mimi_momo[13:7]), seg2number(led_mimi_momo[6:0]),
                 seg2number(led_ss_yyyy[27:21]), seg2number(led_ss_yyyy[20:14]), 
                 seg2number(led_ss_yyyy[13:7]), seg2number(led_ss_yyyy[6:0]));
    endtask

    initial begin
        $display("=================================================");
        $display("Starting Simulation for millennium_clock...");
        $display("=================================================");

        // Initialize inputs
        rst_n = 1'b1;
        up_btn = 1'b0;
        down_btn = 1'b0;
        adj_target = 2'b01;
        adj_en = 1'b0;
        mode = 1'b1; // Start in Date mode (to view Year)
        
        // Assert Reset
        #100;
        rst_n = 1'b0;
        #2000; // hold reset for 2 clock periods
        rst_n = 1'b1;
        $display("[%0t us] Reset released.", $time);
        
        #100;
        display_outputs();

        // -------------------------------------------------------------
        // TEST CASE 1: Automatic counting (tick_1Hz)
        // -------------------------------------------------------------
        $display("\n--- Test Case 1: Automatic Counting ---");
        // Wait for 3 seconds of simulation time
        // Since CLK_FREQ = 1000, 1 second is 1000 clock cycles = 1,000,000 us
        #1000000;
        display_outputs(); // Year should be 2025
        #1000000;
        display_outputs(); // Year should be 2026
        #1000000;
        display_outputs(); // Year should be 2027

        // -------------------------------------------------------------
        // TEST CASE 2: Manual Up Adjustment with Noise (Bouncing)
        // -------------------------------------------------------------
        $display("\n--- Test Case 2: Manual UP Adjustment (with Bouncing) ---");
        adj_en = 1'b1; // Enter adjust mode (pauses automatic counting)
        #1000;

        // Press UP button with noise (bouncing)
        $display("[%0t us] Pressing UP button (with bounces)...", $time);
        up_btn = 1'b1; #2000; // Press for 2 cycles (2ms) - should be ignored (less than 5ms debounce)
        up_btn = 1'b0; #1000; // Release for 1 cycle (1ms)
        up_btn = 1'b1; #8000; // Press and hold for 8 cycles (8ms) - should be registered as 1 valid press
        up_btn = 1'b0; #5000; // Release

        #2000;
        display_outputs(); // Year should have incremented once: 2028
        
        // -------------------------------------------------------------
        // TEST CASE 3: Manual DOWN Adjustment with Noise (Bouncing)
        // -------------------------------------------------------------
        $display("\n--- Test Case 3: Manual DOWN Adjustment (with Bouncing) ---");
        
        // Press DOWN button with noise (bouncing)
        $display("[%0t us] Pressing DOWN button (with bounces)...", $time);
        down_btn = 1'b1; #1000; // Press for 1 cycle (1ms) - ignored
        down_btn = 1'b0; #2000; // Release
        down_btn = 1'b1; #7000; // Press and hold for 7 cycles (7ms) - registered as 1 valid press
        down_btn = 1'b0; #5000; // Release

        #2000;
        display_outputs(); // Year should have decremented once: 2027

        // -------------------------------------------------------------
        // TEST CASE 4: Switch Display Mode to Time Mode
        // -------------------------------------------------------------
        $display("\n--- Test Case 4: Toggle display mode to Time Mode ---");
        mode = 1'b0; // Switch to Time Mode
        #1000;
        display_outputs(); // Time display should be shown: Hour: 16, Min: 43, Sec: 12
        
        #10000;
        $display("=================================================");
        $display("Simulation Finished Successfully!");
        $display("=================================================");
        $finish;
    end

endmodule
