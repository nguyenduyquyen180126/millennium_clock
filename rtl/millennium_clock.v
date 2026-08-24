module millennium_clock #(
    parameter CLK_FREQ = 50_000_000,
    parameter DEBOUNCE_TIME_MS = 20
)(
    input wire clk,
    input wire rst_n,
    input wire up_btn,
    input wire down_btn,
    input wire [1:0] adj_target,
    input wire adj_en,
    input wire mode,
    output [13:0] led_hh_dd,
    output [13:0] led_mimi_momo,
    output [27:0] led_ss_yyyy
);
    wire clk_2Hz, tick_1Hz;
    clkdiv #(
        .CLK_FREQ_HZ(CLK_FREQ)
    ) u_clkdiv (
        .rst_n(rst_n),
        .clk(clk),
        .clk_2Hz(clk_2Hz),
        .tick_1Hz(tick_1Hz)
    );

    wire up, down;
    debouncer #(
        .CLK_FREQ(CLK_FREQ),
        .DEBOUNCE_TIME_MS(DEBOUNCE_TIME_MS)
    ) u_up_debounce (
        .clk(clk),
        .rst_n(rst_n),
        .button_in(~up_btn),
        .button_out(up)
    );

    debouncer #(
        .CLK_FREQ(CLK_FREQ),
        .DEBOUNCE_TIME_MS(DEBOUNCE_TIME_MS)
    ) u_down_debounce (
        .clk(clk),
        .rst_n(rst_n),
        .button_in(~down_btn),
        .button_out(down)
    );

    wire [4:0] hour_raw;
    wire [5:0] hour;
    wire [4:0] day;
    wire [5:0] min;
    wire [3:0] month;
    wire [5:0] sec;
    wire [13:0] year;

    assign hour = {1'b0, hour_raw};

    wire sec_carry_unused;
    wire min_carry_unused;
    wire hour_carry_unused;
    wire day_carry_unused;
    wire month_carry_unused;
    wire leap;
    wire [4:0] dim;

    // Create one-clock pulses for manual adjustment events.
    reg up_q;
    reg down_q;
    wire up_pulse;
    wire down_pulse;

    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            up_q <= 1'b0;
            down_q <= 1'b0;
        end else begin
            up_q <= up;
            down_q <= down;
        end
    end

    assign up_pulse = up & ~up_q;
    assign down_pulse = down & ~down_q;

    // Run normal counting only when not in adjustment mode.
    wire run_auto = (~adj_en) & tick_1Hz;

    // Cascade auto increment from second -> year using current state before clock edge.
    wire inc_sec_auto = run_auto;
    wire inc_min_auto = run_auto && (sec == 6'd59);
    wire inc_hour_auto = run_auto && (sec == 6'd59) && (min == 6'd59);
    wire inc_day_auto = run_auto && (sec == 6'd59) && (min == 6'd59) && (hour == 6'd23);
    wire inc_month_auto = run_auto && (sec == 6'd59) && (min == 6'd59) && (hour == 6'd23) && (day == dim);
    wire inc_year_auto = run_auto && (sec == 6'd59) && (min == 6'd59) && (hour == 6'd23) && (day == dim) && (month == 4'd12);

    // Manual mapping follows UI spec:
    // adj_target=01 -> SS/YYYY, 10 -> MM/MO, 11 -> HH/DD.
    wire sec_inc_manual = adj_en && (mode == 1'b0) && (adj_target == 2'b01) && up_pulse;
    wire sec_dec_manual = adj_en && (mode == 1'b0) && (adj_target == 2'b01) && down_pulse;
    wire min_inc_manual = adj_en && (mode == 1'b0) && (adj_target == 2'b10) && up_pulse;
    wire min_dec_manual = adj_en && (mode == 1'b0) && (adj_target == 2'b10) && down_pulse;
    wire hour_inc_manual = adj_en && (mode == 1'b0) && (adj_target == 2'b11) && up_pulse;
    wire hour_dec_manual = adj_en && (mode == 1'b0) && (adj_target == 2'b11) && down_pulse;

    wire day_inc_manual = adj_en && (mode == 1'b1) && (adj_target == 2'b11) && up_pulse;
    wire day_dec_manual = adj_en && (mode == 1'b1) && (adj_target == 2'b11) && down_pulse;
    wire month_inc_manual = adj_en && (mode == 1'b1) && (adj_target == 2'b10) && up_pulse;
    wire month_dec_manual = adj_en && (mode == 1'b1) && (adj_target == 2'b10) && down_pulse;
    wire year_inc_manual = adj_en && (mode == 1'b1) && (adj_target == 2'b01) && up_pulse;
    wire year_dec_manual = adj_en && (mode == 1'b1) && (adj_target == 2'b01) && down_pulse;

    counter_mod #(.MAX_CHECK(60)) u_sec_counter (
        .clk(clk),
        .rst_n(rst_n),
        .inc_auto(inc_sec_auto),
        .inc_manual(sec_inc_manual),
        .dec_manual(sec_dec_manual),
        .value(sec),
        .carry_out(sec_carry_unused)
    );

    counter_mod #(.MAX_CHECK(60)) u_min_counter (
        .clk(clk),
        .rst_n(rst_n),
        .inc_auto(inc_min_auto),
        .inc_manual(min_inc_manual),
        .dec_manual(min_dec_manual),
        .value(min),
        .carry_out(min_carry_unused)
    );

    counter_mod #(.MAX_CHECK(24)) u_hour_counter (
        .clk(clk),
        .rst_n(rst_n),
        .inc_auto(inc_hour_auto),
        .inc_manual(hour_inc_manual),
        .dec_manual(hour_dec_manual),
        .value(hour_raw),
        .carry_out(hour_carry_unused)
    );

    counter_nam u_year_counter (
        .clk(clk),
        .rst_n(rst_n),
        .inc_auto(inc_year_auto),
        .inc_manual(year_inc_manual),
        .dec_manual(year_dec_manual),
        .value(year),
        .leap(leap)
    );

    counter_thang u_month_counter (
        .clk(clk),
        .rst_n(rst_n),
        .inc_auto(inc_month_auto),
        .inc_manual(month_inc_manual),
        .dec_manual(month_dec_manual),
        .value(month),
        .carry_out(month_carry_unused)
    );

    counter_dim u_dim (
        .value_month(month),
        .leap(leap),
        .dim(dim)
    );

    counter_ngay u_day_counter (
        .clk(clk),
        .rst_n(rst_n),
        .inc_auto(inc_day_auto),
        .inc_manual(day_inc_manual),
        .dec_manual(day_dec_manual),
        .dim(dim),
        .value(day),
        .carry_out(day_carry_unused)
    );

    
    display u_display(
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
endmodule