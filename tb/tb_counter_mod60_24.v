`timescale 1ns/1ps

module tb_counter_mod60_24;
    reg clk, rst_n, inc_auto, inc_manual, dec_manual;
    wire [5:0] second_value;
    wire [5:0] minute_value;
    wire [4:0] hour_value;
    wire second_carry;
    wire minute_carry;
    wire hour_carry;

    wire inc_minute_auto;
    wire inc_hour_auto;
    always #5 clk = ~clk;
    reg inc_second_manual;
    reg inc_minute_manual;
    reg inc_hour_manual;

    assign inc_minute_auto = inc_auto && second_value == 6'd59;
    assign inc_hour_auto = inc_auto && (second_value == 6'd59 && minute_value == 6'd59);
    counter_mod #(.MAX_CHECK(60)) second_counter(
        .clk(clk),
        .rst_n(rst_n),
        .inc_auto(inc_auto),
        .inc_manual(inc_second_manual),
        .dec_manual(1'b0),
        .value(second_value),
        .carry_out(second_carry)
    );

    counter_mod #(.MAX_CHECK(60)) minute_counter(
        .clk(clk),
        .rst_n(rst_n),
        .inc_auto(inc_minute_auto),
        .inc_manual(inc_minute_manual),
        .dec_manual(1'b0),
        .value(minute_value),
        .carry_out(minute_carry)
    );

    counter_mod #(.MAX_CHECK(24)) hour_counter(
        .clk(clk),
        .rst_n(rst_n),
        .inc_auto(inc_hour_auto),
        .inc_manual(inc_hour_manual),
        .dec_manual(1'b0),
        .value(hour_value),
        .carry_out(hour_carry)
    );
    initial begin
        $monitor("T=%0t | clk=%b rst_n=%b | %02d:%02d:%02d | inc_auto=%b | sec_carry=%b min_carry=%b hour_carry=%b",
        $time, clk, rst_n,
        hour_value, minute_value, second_value,
        inc_auto, second_carry, minute_carry, hour_carry);
        $dumpfile("counter.vcd");
        $dumpvars(0, tb_counter_mod60_24);
        clk = 1'b0;
        rst_n = 1'b0;
        inc_auto = 1'b0;
        inc_second_manual = 1'b0;
        inc_minute_manual = 1'b0;
        inc_hour_manual = 1'b0;
        dec_manual = 1'b0;
        #20 rst_n = 1'b1;
        inc_second_manual = 1'b1;
        repeat (59) @(posedge clk);
        #1;
        inc_second_manual = 1'b0;
        inc_minute_manual = 1'b1;
        repeat (58) @(posedge clk);
        #1;
        inc_minute_manual = 1'b0;
        #1;
        if (hour_value != 0 || minute_value != 58 || second_value != 59) begin
            $display("Error: Expected time 00:58:59, got %02d:%02d:%02d", hour_value, minute_value, second_value);
        end else begin
            $display("Time after manual increments: %02d:%02d:%02d", hour_value, minute_value, second_value);
        end

        inc_auto = 1'b1;
        @(posedge clk);
        #1;
        $display("CHECK 2: %02d:%02d:%02d",hour_value, minute_value, second_value);
        if (hour_value != 0 || minute_value != 59 || second_value != 0) begin
            $display("Error: Expected time 00:59:00, got %02d:%02d:%02d", hour_value, minute_value, second_value);
        end else begin
            $display("Time after auto increment: %02d:%02d:%02d", hour_value, minute_value, second_value);
        end
        repeat (60) @(posedge clk);
        #1;
        $display("CHECK 3: %02d:%02d:%02d",hour_value, minute_value, second_value);
        if (hour_value != 1 || minute_value != 0 || second_value != 0) begin
            $display("Error: Expected time 01:00:00, got %02d:%02d:%02d", hour_value, minute_value, second_value);
        end else begin
            $display("Time after auto increment: %02d:%02d:%02d", hour_value, minute_value, second_value);
        end
        $display("Test completed.");
        $finish;

    end


endmodule
