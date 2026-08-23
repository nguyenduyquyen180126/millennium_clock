`timescale 1ns/1ps

module tb_display;
    reg clk_2Hz;
    reg [1:0] adj_target;
    reg adj_en;
    reg mode;
    reg [5:0] hour;
    reg [4:0] day;
    reg [5:0] min;
    reg [3:0] month;
    reg [5:0] sec;
    reg [13:0] year;
    wire [13:0] led_hh_dd;
    wire [13:0] led_mimi_momo;
    wire [27:0] led_ss_yyyy;

    display dut(
        .clk_2Hz(clk_2Hz),
        .adj_target(adj_target),
        .adj_en(adj_en),
        .mode(mode),
        .hour(hour),
        .day(day),
        .min(min),
        .month(month),
        .sec(sec),
        .year(year),
        .led_hh_dd(led_hh_dd),
        .led_mimi_momo(led_mimi_momo),
        .led_ss_yyyy(led_ss_yyyy)
    );

    
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
            7'b1111111: seg2number = 4'hB; // Blank
        endcase
    endfunction

    
    task render_display();
        $display("DISPLAY: %0x%0x %0x%0x %0x%0x%0x%0x", 
                seg2number(led_hh_dd[13:7]), seg2number(led_hh_dd[6:0]), 
                seg2number(led_mimi_momo[13:7]), seg2number(led_mimi_momo[6:0]), 
                seg2number(led_ss_yyyy[27:21]), seg2number(led_ss_yyyy[20:14]), seg2number(led_ss_yyyy[13:7]), seg2number(led_ss_yyyy[6:0]));
    endtask


    integer i;
    initial begin
        $display("Starting tb_display testbench...");
        
        // Initialize inputs
        $display("--- Test Case 1: Time after reset ---");
        clk_2Hz = 0;
        adj_target = 0;
        adj_en = 0;
        mode = 0;
        hour = 0;
        day = 0;
        min = 0;
        month = 0;
        sec = 0;
        year = 14'd2024;
        #10;
        render_display();

        $display("--- Test Case 2: Date after reset ---");
        mode = 1;
        #10;
        render_display();

        
        $display("--- Test Case 3: Time mode ---");
        mode = 0;
        hour = 6'd11;
        min = 6'd25;
        sec = 6'd41;
        #10;
        render_display();

        
        $display("--- Test Case 4: Date mode ---");
        mode = 1;
        day = 5'd23;
        month = 4'd8;
        year = 14'd2026;
        #10;
        render_display();

        $display("--- Test Case 5: Adjust mode date ---");
        adj_en = 1;
        adj_target = 2'b11;
        
        clk_2Hz = 1;
        #10;
        render_display();
        
        clk_2Hz = 0;
        #10;
        render_display();

        $display("--- Test Case 4: Adjust mode time ---");
        mode = 0; 
        adj_target = 2'b01;
        
        clk_2Hz = 1;
        #10;
        render_display();
        
        clk_2Hz = 0;
        #10;
        render_display();

        $display("--- Full Minute test ---");
        for(i = 0; i < 62; i = i + 1)begin
            sec = i;
            #10;
            render_display();
        end

        $display("--- Full Hour test ---");
        for(i = 0; i < 62; i = i + 1)begin
            min = i;
            #10;
            render_display();
        end

        $display("All display tests finished!");
        $finish;
    end

endmodule