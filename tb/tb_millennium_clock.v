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

    // 1 kHz clock generator (period = 1000 us = 1 ms)
    initial begin
        clk = 0;
        forever #500 clk = ~clk;
    end

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
            default:    seg2number = 4'hB; 
        endcase
    endfunction

    integer pass_cnt = 0;
    integer fail_cnt = 0;

    task check_display(input [7:0] exp_hh_dd, input [7:0] exp_mm_mo, input [15:0] exp_ss_yyyy);
        reg [7:0]  act_hh_dd;
        reg [7:0]  act_mm_mo;
        reg [15:0] act_ss_yyyy;
        begin
            act_hh_dd = {seg2number(led_hh_dd[13:7]), seg2number(led_hh_dd[6:0])};
            act_mm_mo = {seg2number(led_mimi_momo[13:7]), seg2number(led_mimi_momo[6:0])};
            act_ss_yyyy = {seg2number(led_ss_yyyy[27:21]), seg2number(led_ss_yyyy[20:14]), 
                           seg2number(led_ss_yyyy[13:7]), seg2number(led_ss_yyyy[6:0])};

            if (act_hh_dd == exp_hh_dd && act_mm_mo == exp_mm_mo && act_ss_yyyy == exp_ss_yyyy) begin
                $display("[PASS] Display [HH/DD]: %02x | [MM/MO]: %02x | [SS/YYYY]: %04x", act_hh_dd, act_mm_mo, act_ss_yyyy);
                pass_cnt = pass_cnt + 1;
            end else begin
                $display("[FAIL] Display [HH/DD]: %02x | [MM/MO]: %02x | [SS/YYYY]: %04x (Expected: %02x:%02x:%04x)", act_hh_dd, act_mm_mo, act_ss_yyyy, exp_hh_dd, exp_mm_mo, exp_ss_yyyy);
                fail_cnt = fail_cnt + 1;
            end
        end
    endtask

    task press_up_btn();
        begin
            $display("[%0t us] Pressing UP button...", $time);
            up_btn = 1'b1;
            #8000;              // Chờ 8us
            up_btn = 1'b0;
            #8000; 
        end
    endtask

    task press_down_btn();
        begin
            $display("[%0t us] Pressing DOWN button...", $time);
            down_btn = 1'b1;
            #8000;              // Chờ 8us
            down_btn = 1'b0;
            #8000; 
        end
    endtask

    task force_time_date(
        input [5:0] sec,
        input [5:0] min,
        input [4:0] hour,
        input [4:0] day,
        input [3:0] month,
        input [13:0] year
    );
        begin
            $display("[%0t us] FORCING TIME/DATE to: %02d:%02d:%02d, %02d/%02d/%04d", $time, hour, min, sec, day, month, year);
            force dut.u_clock_block.u_sec_counter.u_counter_mod.value = sec;
            force dut.u_clock_block.u_min_counter.u_counter_mod.value = min;
            force dut.u_clock_block.u_hour_counter.u_counter_mod.value = hour;
            force dut.u_clock_block.u_day_counter.value = day;
            force dut.u_clock_block.u_month_counter.value = month;
            force dut.u_clock_block.u_year_counter.value = year;
            
            force dut.u_clock_block.u_year_counter.y_mod4 = year % 4;
            force dut.u_clock_block.u_year_counter.y_mod100 = year % 100;
            force dut.u_clock_block.u_year_counter.y_mod400 = year % 400;
            
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
            #1; 
        end
    endtask

    initial begin
        $display("======================================================================");
        $display("Starting Millennium Clock Simulation (Sequential Testcases 1 to 26)");
        $display("======================================================================");

        // --- STT 1: Reset Giờ:Phút:Giây ---
        $display("\n--- [STT 1] Reset Gio:Phut:Giay ---");
        rst_n = 1'b0;
        up_btn = 1'b0;
        down_btn = 1'b0;
        adj_target = 2'b00;
        mode = 1'b0; // Time Mode
        adj_en = 1'b0;
        #1; 
        rst_n = 1'b1;
        #1;
        check_display(8'h00, 8'h00, 16'hbb00);

        // --- STT 2: Reset Ngày:Tháng:Năm ---
        $display("\n--- [STT 2] Reset Ngay:Thang:Nam ---");
        mode = 1'b1; // Date Mode
        #1;
        check_display(8'h01, 8'h01, 16'h2024); 
        mode = 1'b0; // Time Mode
        #1;

        // --- STT 3: Tăng Giây thủ công ---
        $display("\n--- [STT 3] Tang Giay thu cong (59 -> 00) ---");
        force_time_date(6'd59, 6'd0, 5'd0, 5'd1, 4'd1, 14'd2024);
        adj_target = 2'b01; // Second
        adj_en = 1'b1;
        press_up_btn();
        check_display(8'h00, 8'h00, 16'hbb00);
        adj_en = 1'b0;
        #1;

        // --- STT 4: Giảm Giây thủ công ---
        $display("\n--- [STT 4] Giam Giay thu cong (00 -> 59) ---");
        force_time_date(6'd0, 6'd0, 5'd0, 5'd1, 4'd1, 14'd2024);
        adj_target = 2'b01; // Second
        adj_en = 1'b1;
        press_down_btn();
        check_display(8'h00, 8'h00, 16'hbb59);
        adj_en = 1'b0;
        #1;


        // --- STT 5: Tăng Phút thủ công ---
        $display("\n--- [STT 5] Tang Phut thu cong (59 -> 00) ---");
        force_time_date(6'd0, 6'd59, 5'd0, 5'd1, 4'd1, 14'd2024);
        adj_target = 2'b10; // Minute
        adj_en = 1'b1;
        press_up_btn();
        check_display(8'h00, 8'h00, 16'hbb00);
        adj_en = 1'b0;
        #1;


        // --- STT 6: Giảm Phút thủ công ---
        $display("\n--- [STT 6] Giam Phut thu cong (00 -> 59) ---");
        force_time_date(6'd0, 6'd0, 5'd0, 5'd1, 4'd1, 14'd2024);
        adj_target = 2'b10; // Minute
        adj_en = 1'b1;
        press_down_btn();
        check_display(8'h00, 8'h59, 16'hbb00);
        adj_en = 1'b0;
        #1;


        // --- STT 7: Tăng Giờ thủ công ---
        $display("\n--- [STT 7] Tang Gio thu cong (23 -> 00) ---");
        force_time_date(6'd0, 6'd0, 5'd23, 5'd1, 4'd1, 14'd2024);
        adj_target = 2'b11; // Hour
        adj_en = 1'b1;
        press_up_btn();
        check_display(8'h00, 8'h00, 16'hbb00);
        adj_en = 1'b0;
        #1;


        // --- STT 8: Giảm Giờ thủ công ---
        $display("\n--- [STT 8] Giam Gio thu cong (00 -> 23) ---");
        force_time_date(6'd0, 6'd0, 5'd0, 5'd1, 4'd1, 14'd2024);
        adj_target = 2'b11; // Hour
        adj_en = 1'b1;
        press_down_btn();
        check_display(8'h23, 8'h00, 16'hbb00);
        adj_en = 1'b0;
        #1;


        // --- STT 9: Tăng Ngày thủ công ---
        $display("\n--- [STT 9] Tang Ngay thu cong (31 -> 01) ---");
        force_time_date(6'd0, 6'd0, 5'd0, 5'd31, 4'd1, 14'd2024);
        mode = 1'b1; // Date Mode
        adj_target = 2'b11; // Day
        adj_en = 1'b1;
        press_up_btn();
        check_display(8'h01, 8'h01, 16'h2024);
        adj_en = 1'b0;
        #1;


        // --- STT 10: Giảm Ngày thủ công ---
        $display("\n--- [STT 10] Giam Ngay thu cong (01 -> 31) ---");
        force_time_date(6'd0, 6'd0, 5'd0, 5'd1, 4'd1, 14'd2024);
        adj_target = 2'b11; // Day
        adj_en = 1'b1;
        press_down_btn();
        check_display(8'h31, 8'h01, 16'h2024);
        adj_en = 1'b0;
        #1;


        // --- STT 11: Tăng Tháng thủ công ---
        $display("\n--- [STT 11] Tang Thang thu cong (12 -> 01) ---");
        force_time_date(6'd0, 6'd0, 5'd0, 5'd1, 4'd12, 14'd2024);
        adj_target = 2'b10; // Month
        adj_en = 1'b1;
        press_up_btn();
        check_display(8'h01, 8'h01, 16'h2024);
        adj_en = 1'b0;
        #1;


        // --- STT 12: Giảm Tháng thủ công ---
        $display("\n--- [STT 12] Giam Thang thu cong (01 -> 12) ---");
        force_time_date(6'd0, 6'd0, 5'd0, 5'd1, 4'd1, 14'd2024);
        adj_target = 2'b10; // Month
        adj_en = 1'b1;
        press_down_btn();
        check_display(8'h01, 8'h12, 16'h2024);
        adj_en = 1'b0;
        #1;


        // --- STT 13: Tăng Năm thủ công ---
        $display("\n--- [STT 13] Tang Nam thu cong (9999 -> 0000) ---");
        force_time_date(6'd0, 6'd0, 5'd0, 5'd1, 4'd1, 14'd9999);
        adj_target = 2'b01; // Year
        adj_en = 1'b1;
        press_up_btn();
        check_display(8'h01, 8'h01, 16'h0000);
        adj_en = 1'b0;
        #1;


        // --- STT 14: Giảm Năm thủ công ---
        $display("\n--- [STT 14] Giam Nam thu cong (0000 -> 9999) ---");
        force_time_date(6'd0, 6'd0, 5'd0, 5'd1, 4'd1, 14'd0);
        adj_target = 2'b01; // Year
        adj_en = 1'b1;
        press_down_btn();
        check_display(8'h01, 8'h01, 16'h9999);
        adj_en = 1'b0;
        #1;


        // --- STT 15: Ấn giữ nút TĂNG (Auto-Repeat UP: Giây 00 -> 04) ---
        $display("\n--- [STT 15] An giu nut TANG tu dong (Auto-Repeat UP: 00 -> 04) ---");
        force_time_date(6'd0, 6'd0, 5'd0, 5'd1, 4'd1, 14'd2024);
        mode = 1'b0;        // Time Mode
        adj_target = 2'b01; // Chỉnh Giây
        adj_en = 1'b1;
        
        $display("[%0t us] Nhan giu nut UP trong 950ms...", $time);
        up_btn = 1'b1;
        #1000000; // 5ms + 500ms + 200ms + 200ms < 1000000
        
        up_btn = 1'b0;
        #8000;
        adj_en = 1'b0; // Tắt chế độ chỉnh để ngưng nhấp nháy LED
        #1;
        check_display(8'h00, 8'h00, 16'hbb04);
        #1;


        // --- STT 16: Ấn giữ nút GIẢM (Auto-Repeat DOWN: Phút 10 -> 06) ---
        $display("\n--- [STT 16] An giu nut GIAM tu dong (Auto-Repeat DOWN: 10 -> 06) ---");
        force_time_date(6'd0, 6'd10, 5'd0, 5'd1, 4'd1, 14'd2024);
        mode = 1'b0;        // Time Mode
        adj_target = 2'b10; // Chỉnh Phút
        adj_en = 1'b1;

        $display("[%0t us] Nhan giu nut DOWN trong 950ms...", $time);
        down_btn = 1'b1;
        #1000000;

        down_btn = 1'b0;
        #8000;
        adj_en = 1'b0; // Tắt chế độ chỉnh để ngưng nhấp nháy LED
        #1;
        check_display(8'h00, 8'h06, 16'hbb00);
        #1;


        // --- STT 17: Tự gọt ngày khi tăng tháng (Leap) ---
        $display("\n--- [STT 17] Tu got ngay khi tang thang (Leap: 31/01/2024 -> 29/02/2024) ---");
        force_time_date(6'd0, 6'd0, 5'd12, 5'd31, 4'd1, 14'd2024);
        mode = 1'b1;        // Date Mode
        adj_target = 2'b10; // Month
        adj_en = 1'b1;
        press_up_btn();
        check_display(8'h29, 8'h02, 16'h2024);
        adj_en = 1'b0;
        #1;


        // --- STT 18: Tự gọt ngày khi giảm năm (Non-Leap) ---
        $display("\n--- [STT 18] Tu got ngay khi giam nam (Non-Leap: 29/02/2024 -> 28/02/2023) ---");
        force_time_date(6'd0, 6'd0, 5'd12, 5'd29, 4'd2, 14'd2024);
        mode = 1'b1;        // Date Mode
        adj_target = 2'b01; // Year
        adj_en = 1'b1;
        press_down_btn();
        check_display(8'h28, 8'h02, 16'h2023); 
        adj_en = 1'b0;
        #1;


        // --- STT 19: Kiểm tra năm nhuận 2024 ---
        $display("\n--- [STT 19] Kiem tra nam nhuan 2024 (28/02/2024 23:59:59 -> 1s -> 29/02/2024) ---");
        force_time_date(6'd59, 6'd59, 5'd23, 5'd28, 4'd2, 14'd2024);
        mode = 1'b1; // Date Mode
        #1000000; // Wait 1s
        check_display(8'h29, 8'h02, 16'h2024); 
        #1;


        // --- STT 20: Kiểm tra năm nhuận thế kỷ 2000 ---
        $display("\n--- [STT 20] Kiem tra nam nhuan the ky 2000 (28/02/2000 23:59:59 -> 1s -> 29/02/2000) ---");
        force_time_date(6'd59, 6'd59, 5'd23, 5'd28, 4'd2, 14'd2000);
        #1000000; // Wait 1s
        check_display(8'h29, 8'h02, 16'h2000);
        #1;


        // --- STT 21: Kiểm tra năm không nhuận thế kỷ 2100 ---
        $display("\n--- [STT 21] Kiem tra nam khong nhuan the ky 2100 (28/02/2100 23:59:59 -> 1s -> 01/03/2100) ---");
        force_time_date(6'd59, 6'd59, 5'd23, 5'd28, 4'd2, 14'd2100);
        #1000000; // Wait 1s
        check_display(8'h01, 8'h03, 16'h2100); 
        #1;


        // --- STT 22: Tự động chuyển giao phút ---
        $display("\n--- [STT 22] Tu dong chuyen giao phut ---");
        force_time_date(6'd59, 6'd0, 5'd12, 5'd1, 4'd1, 14'd2024);
        mode = 1'b0; // Time Mode
        #1000000; // Wait 1s simulated time (1000 cycles)
        check_display(8'h12, 8'h01, 16'hbb00); 
        #1;


        // --- STT 23: Tự động chuyển giao giờ ---
        $display("\n--- [STT 23] Tu dong chuyen giao gio ---");
        force_time_date(6'd59, 6'd59, 5'd0, 5'd1, 4'd1, 14'd2024);
        #1000000;
        check_display(8'h01, 8'h00, 16'hbb00);
        #1;


        // --- STT 24: Tự động chuyển giao ngày (Năm nhuận) ---
        $display("\n--- [STT 24] Tu dong chuyen giao ngay (Feb Leap Year) ---");
        force_time_date(6'd59, 6'd59, 5'd23, 5'd29, 4'd02, 14'd2024);
        mode = 1'b1; // Date Mode
        #1000000;
        check_display(8'h01, 8'h03, 16'h2024);
        #1;


        // --- STT 25: Tự động chuyển giao năm ---
        $display("\n--- [STT 25] Tu dong chuyen giao nam ---");
        force_time_date(6'd59, 6'd59, 5'd23, 5'd31, 4'd12, 14'd2024);
        #1000000;
        check_display(8'h01, 8'h01, 16'h2025); 
        #1;


        // --- STT 26: Tự động chuyển giao thiên niên kỷ ---
        $display("\n--- [STT 26] Tu dong chuyen giao thien nien ky ---");
        force_time_date(6'd59, 6'd59, 5'd23, 5'd31, 4'd12, 14'd9999);
        #1000000;
        check_display(8'h01, 8'h01, 16'h0000);
        #1;


        $display("\n======================================================================");
        $display("Simulation Summary: %0d PASSED, %0d FAILED", pass_cnt, fail_cnt);
        if (fail_cnt == 0)
            $display("ALL 26 TESTCASES PASSED PERFECTLY!");
        else
            $display("TEST FAILED WITH %0d ERRORS!", fail_cnt);
        $display("======================================================================");

        $finish;
    end

endmodule
