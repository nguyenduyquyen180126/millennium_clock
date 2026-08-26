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
            default:    seg2number = 4'hB; // Blank / Unknown
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

    // Task to simulate button press (active high in TB)
    task press_up_btn();
        begin
            $display("[%0t us] Pressing UP button...", $time);
            up_btn = 1'b1;
            #8000; // Hold for 8ms (longer than 5ms debounce)
            up_btn = 1'b0;
            #20000; // Wait 20ms to allow synchronization & debouncer stabilization
        end
    endtask

    task press_down_btn();
        begin
            $display("[%0t us] Pressing DOWN button...", $time);
            down_btn = 1'b1;
            #8000; // Hold for 8ms
            down_btn = 1'b0;
            #20000; // Wait 20ms
        end
    endtask

    // Task to check blinking behaviour
    task check_blinking(input [1:0] target);
        begin
            $display("[%0t us] Checking blinking for adj_target = %b...", $time, target);
            // Wait until clk_2Hz is 1 (blinking active phase)
            wait(dut.clk_2Hz == 1'b1);
            #100;
            $display("[%0t us] --- Blink phase (LED Blanking) ---", $time);
            display_outputs();
            
            // Wait until clk_2Hz is 0 (blinking inactive phase)
            wait(dut.clk_2Hz == 1'b0);
            #100;
            $display("[%0t us] --- Normal phase (LED Showing Value) ---", $time);
            display_outputs();
        end
    endtask

    // Task to force internal counter values for testing calendar edge cases
    task force_time_date(
        input [5:0] sec,
        input [5:0] min,
        input [4:0] hour,
        input [4:0] day,
        input [3:0] month,
        input [13:0] year
    );
        begin
            $display("[%0t us] FORCING TIME/DATE to: %02d:%02d:%02d, %02d/%02d/%04d",
                     $time, hour, min, sec, day, month, year);
            force dut.u_clock_block.u_sec_counter.u_counter_mod.value = sec;
            force dut.u_clock_block.u_min_counter.u_counter_mod.value = min;
            force dut.u_clock_block.u_hour_counter.u_counter_mod.value = hour;
            force dut.u_clock_block.u_day_counter.value = day;
            force dut.u_clock_block.u_month_counter.value = month;
            force dut.u_clock_block.u_year_counter.value = year;
            // Also force y_mod values for correct leap year logic calculations
            force dut.u_clock_block.u_year_counter.y_mod4 = year % 4;
            force dut.u_clock_block.u_year_counter.y_mod100 = year % 100;
            force dut.u_clock_block.u_year_counter.y_mod400 = year % 400;
            
            @(posedge clk);
            #1;
            release dut.u_clock_block.u_sec_counter.u_counter_mod.value;
            release dut.u_clock_block.u_min_counter.u_counter_mod.value;
            release dut.u_clock_block.u_hour_counter.u_counter_mod.value;
            release dut.u_clock_block.u_day_counter.value;
            release dut.u_clock_block.u_month_counter.value;
            release dut.u_clock_block.u_year_counter.value;
            release dut.u_clock_block.u_year_counter.y_mod4;
            release dut.u_clock_block.u_year_counter.y_mod100;
            release dut.u_clock_block.u_year_counter.y_mod400;
            #1000; // Let signals settle
        end
    endtask

    initial begin
        $display("=================================================");
        $display("Starting Simulation for millennium_clock...");
        $display("=================================================");

        // --- TEST CASE 1: Reset luc dau ---
        $display("\n--- Test Case 1: Reset luc dau ---");
        rst_n = 1'b1;
        up_btn = 1'b0;
        down_btn = 1'b0;
        adj_target = 2'b00;
        adj_en = 1'b0;
        mode = 1'b0;
        
        #1000;
        rst_n = 1'b0;
        #5000; // hold reset for 5ms
        rst_n = 1'b1;
        $display("[%0t us] Reset released.", $time);
        #1000;
        display_outputs();

        // --- TEST CASE 2: Che do time ---
        $display("\n--- Test Case 2: Che do Time ---");
        mode = 1'b0; // Time Mode
        #2000;
        display_outputs();

        // --- TEST CASE 3: Chay 1 phut ---
        $display("\n--- Test Case 3: Chay 1 phut ---");
        repeat (60) begin
            #1000000; // 10s
            display_outputs();
        end

        // --- TEST CASE 4: Dieu chinh tang giam giay, gio, phut & kiem tra nhay LED ---
        $display("\n--- Test Case 4: Dieu chinh giay, phut, gio & Kiem tra nhay LED ---");
        
        // 4a. Giây (adj_target = 2'b01)
        $display("\n[Giay - Target 01]");
        adj_target = 2'b01;
        adj_en = 1'b1;
        #1000;
        check_blinking(2'b01);
        press_up_btn();
        display_outputs();
        press_down_btn();
        display_outputs();
        adj_en = 1'b0;
        #2000;

        // 4b. Phút (adj_target = 2'b10)
        $display("\n[Phut - Target 10]");
        adj_target = 2'b10;
        adj_en = 1'b1;
        #1000;
        check_blinking(2'b10);
        press_up_btn();
        display_outputs();
        press_down_btn();
        display_outputs();
        adj_en = 1'b0;
        #2000;

        // 4c. Giờ (adj_target = 2'b11)
        $display("\n[Gio - Target 11]");
        adj_target = 2'b11;
        adj_en = 1'b1;
        #1000;
        check_blinking(2'b11);
        press_up_btn();
        display_outputs();
        press_down_btn();
        display_outputs();
        adj_en = 1'b0;
        #2000;

        // --- TEST CASE 5: Che do Date ---
        $display("\n--- Test Case 5: Che do Date ---");
        mode = 1'b1; // Date Mode
        #2000;
        display_outputs();

        // --- TEST CASE 6: Dieu chinh ngay, thang, nam ---
        $display("\n--- Test Case 6: Dieu chinh ngay, thang, nam ---");
        adj_en = 1'b1;

        // 6a. Ngày (adj_target = 2'b11)
        $display("\n[Ngay - Target 11]");
        adj_target = 2'b11;
        #1000;
        press_up_btn();
        display_outputs();
        press_down_btn();
        display_outputs();

        // 6b. Thang (adj_target = 2'b10)
        $display("\n[Thang - Target 10]");
        adj_target = 2'b10;
        #1000;
        press_up_btn();
        display_outputs();
        press_down_btn();
        display_outputs();

        // 6c. Nam (adj_target = 2'b01)
        $display("\n[Nam - Target 01]");
        adj_target = 2'b01;
        #1000;
        press_up_btn();
        display_outputs();
        press_down_btn();
        display_outputs();

        adj_en = 1'b0;
        #2000;

        // --- TEST CASE 7: Leap Year Rollover ---
        $display("\n--- Test Case 7: Leap Year Rollover ---");
        
        // 7a. Normal Leap Year (2024) -> Should have Feb 29
        $display("\n[7a. Normal Leap Year: Feb 2024]");
        force_time_date(6'd59, 6'd59, 5'd23, 5'd28, 4'd2, 14'd2024);
        #1000000; // Wait 1s
        $display("After 1s (should be 29/02/2024):");
        display_outputs();
        
        // Force to 29/02/2024 23:59:59 to test rollover to 01/03/2024
        force_time_date(6'd59, 6'd59, 5'd23, 5'd29, 4'd2, 14'd2024);
        #1000000; // Wait 1s
        $display("After 2s (should be 01/03/2024):");
        display_outputs();
        
        // 7b. Non-Leap Year (2100) -> Should NOT have Feb 29
        $display("\n[7b. Non-Leap Year: Feb 2100]");
        force_time_date(6'd59, 6'd59, 5'd23, 5'd28, 4'd2, 14'd2100);
        #1000000; // Wait 1s
        $display("After 1s (should be 01/03/2100):");
        display_outputs();

        // 7c. Century Leap Year (2000) -> Should have Feb 29
        $display("\n[7c. Century Leap Year: Feb 2000]");
        force_time_date(6'd59, 6'd59, 5'd23, 5'd28, 4'd2, 14'd2000);
        #1000000; // Wait 1s
        $display("After 1s (should be 29/02/2000):");
        display_outputs();
        
        // Force to 29/02/2000 23:59:59 to test rollover to 01/03/2000
        force_time_date(6'd59, 6'd59, 5'd23, 5'd29, 4'd2, 14'd2000);
        #1000000; // Wait 1s
        $display("After 2s (should be 01/03/2000):");
        display_outputs();

        // --- TEST CASE 8: Month End Rollover ---
        $display("\n--- Test Case 8: Month End Rollover (April 30 -> May 1) ---");
        force_time_date(6'd59, 6'd59, 5'd23, 5'd30, 4'd4, 14'd2024);
        #1000000; // Wait 1s
        display_outputs();

        // --- TEST CASE 9: Year End & Millennium Rollover ---
        $display("\n--- Test Case 9: Year End & Millennium Rollover ---");
        
        // 9a. Normal Year End (31/12/2024 -> 01/01/2025)
        $display("\n[9a. Normal Year End]");
        force_time_date(6'd59, 6'd59, 5'd23, 5'd31, 4'd12, 14'd2024);
        #1000000; // Wait 1s
        display_outputs();

        // 9b. Millennium End (31/12/9999 -> 01/01/0000)
        $display("\n[9b. Millennium End]");
        force_time_date(6'd59, 6'd59, 5'd23, 5'd31, 4'd12, 14'd9999);
        #1000000; // Wait 1s
        display_outputs();

        // --- TEST CASE 10: Manual Year Decrement Underflow (0000 -> 9999) ---
        $display("\n--- Test Case 10: Manual Year Decrement Underflow (0000 -> 9999) ---");
        force_time_date(6'd0, 6'd0, 5'd0, 5'd1, 4'd1, 14'd0);
        mode = 1'b1;       // Date mode
        adj_en = 1'b1;     // Enable adjust
        adj_target = 2'b01; // Target = Year
        #1000;
        press_down_btn();  // Decrement Year
        display_outputs();
        adj_en = 1'b0;
        mode = 1'b0;
        #2000;

        // --- TEST CASE 11: Day Clipping when Month Changes (Co ngắn ngày) ---
        $display("\n--- Test Case 11: Day Clipping (31/01 -> month change to Feb -> 29/02/2024) ---");
        // We set to 31/01/2024 (Leap year)
        force_time_date(6'd0, 6'd0, 5'd12, 5'd31, 4'd1, 14'd2024);
        mode = 1'b1;       // Date mode
        adj_en = 1'b1;     // Enable adjust
        adj_target = 2'b10; // Target = Month
        #1000;
        press_up_btn();    // Month 1 -> 2
        display_outputs(); // Should show 29/02/2024
        
        $display("\n[Change year to 2023 (Non-Leap) -> Day clips from 29 to 28]");
        adj_target = 2'b01; // Target = Year
        #1000;
        press_down_btn();  // Year 2024 -> 2023
        display_outputs(); // Should clip to 28/02/2023
        
        adj_en = 1'b0;
        mode = 1'b0;
        #2000;

        $display("=================================================");
        $display("Simulation Finished Successfully!");
        $display("=================================================");
        $finish;
    end

endmodule
