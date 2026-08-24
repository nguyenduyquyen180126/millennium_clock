`timescale 1ns/1ps

module tb_counter_ddmmyy;
    reg clk, rst_n, inc_auto, dec_manual;
    wire [4:0] day_value;
    wire [3:0] month_value;
    wire [13:0] year_value;
    wire day_carry;
    wire month_carry;
    wire leap;
    wire [4:0] dim;
    wire inc_month_auto;
    wire inc_year_auto;

    always #5 clk = ~clk;

    reg inc_day_manual;
    reg inc_month_manual;
    reg inc_year_manual;

    assign inc_month_auto = inc_auto && (day_value == dim);
    assign inc_year_auto = inc_auto && (day_value == dim) && (month_value == 4'd12);

    task check_date;
        input [4:0] exp_day;
        input [3:0] exp_month;
        input [13:0] exp_year;
        begin
            #1;
            if (day_value !== exp_day || month_value !== exp_month || year_value !== exp_year) begin
                $display("FAIL t=%0t expected %02d/%02d/%04d got %02d/%02d/%04d",
                         $time, exp_day, exp_month, exp_year, day_value, month_value, year_value);
                $finish;
            end
        end
    endtask

    counter_nam year_counter(
        .clk(clk),
        .rst_n(rst_n),
        .inc_auto(inc_year_auto),
        .inc_manual(inc_year_manual),
        .dec_manual(dec_manual),
        .value(year_value),
        .leap(leap)
    );

    counter_ngay day_counter(
        .clk(clk),
        .rst_n(rst_n),
        .inc_auto(inc_auto),
        .inc_manual(inc_day_manual),
        .dec_manual(dec_manual),
        .dim(dim),
        .value(day_value),
        .carry_out(day_carry)
    );

    counter_thang month_counter(
        .clk(clk),
        .rst_n(rst_n),
        .inc_auto(inc_month_auto),
        .inc_manual(inc_month_manual),
        .dec_manual(dec_manual),
        .value(month_value),
        .carry_out(month_carry)
    );

    counter_dim dim_counter(
        .value_month(month_value),
        .leap(leap),
        .dim(dim)
    );

    initial begin
        $monitor("T=%0t | clk=%b rst_n=%b | %02d/%02d/%04d | auto=%b dM=%b mM=%b yM=%b dec=%b | dim=%0d leap=%b | dCarry=%b mCarry=%b",
        $time, clk, rst_n, day_value, month_value, year_value,
        inc_auto, inc_day_manual, inc_month_manual, inc_year_manual, dec_manual,
        dim, leap, day_carry, month_carry);

        $dumpfile("counter_ddmmyy.vcd");
        $dumpvars(0, tb_counter_ddmmyy);

        clk = 1'b0;
        rst_n = 1'b0;
        inc_auto = 1'b0;
        inc_day_manual = 1'b0;
        inc_month_manual = 1'b0;
        inc_year_manual = 1'b0;
        dec_manual = 1'b0;

        #20 rst_n = 1'b1;

        // Setup from reset date 01/01/2024 to 27/02/2028.
        inc_year_manual = 1'b1;
        repeat (4) @(posedge clk);
        #1;
        inc_year_manual = 1'b0;

        inc_month_manual = 1'b1;
        repeat (1) @(posedge clk);
        #1;
        inc_month_manual = 1'b0;

        inc_day_manual = 1'b1;
        repeat (26) @(posedge clk);
        #1;
        inc_day_manual = 1'b0;

        check_date(5'd27, 4'd2, 14'd2028);
        if (dim !== 5'd29 || leap !== 1'b1) begin
            $display("FAIL t=%0t expected leap-year February dim=29, got dim=%0d leap=%b", $time, dim, leap);
            $finish;
        end

        // Run automatic calendar counting through leap-day and month rollovers.
        inc_auto = 1'b1;

        @(posedge clk); check_date(5'd28, 4'd2, 14'd2028);
        @(posedge clk); check_date(5'd29, 4'd2, 14'd2028);
        @(posedge clk); check_date(5'd1,  4'd3, 14'd2028);

        repeat (30) @(posedge clk);
        check_date(5'd31, 4'd3, 14'd2028);

        @(posedge clk);
        check_date(5'd1,  4'd4, 14'd2028);

        inc_auto = 1'b0;
        $display("PASS: reached 01/04/2028 correctly from 27/02/2028");
        $finish;
    end





endmodule