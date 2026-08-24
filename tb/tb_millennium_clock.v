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

        $display("=================================================");
        $display("Simulation Finished Successfully!");
        $display("=================================================");
        $finish;
    end

endmodule
