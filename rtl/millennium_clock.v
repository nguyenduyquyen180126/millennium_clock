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
        .button_in(up_btn),
        .button_out(up)
    );

    debouncer #(
        .CLK_FREQ(CLK_FREQ),
        .DEBOUNCE_TIME_MS(DEBOUNCE_TIME_MS)
    ) u_down_debounce (
        .clk(clk),
        .rst_n(rst_n),
        .button_in(down_btn),
        .button_out(down)
    );

    wire up_pulse;
    wire down_pulse;
    button_auto_repeat #(
        .CLK_FREQ(CLK_FREQ),
        .HOLD_DELAY_MS(500),
        .REPEAT_RATE_MS(200)
    ) u_up_auto_repeat (
        .clk(clk),
        .rst_n(rst_n),
        .btn_clean(up),
        .pulse_out(up_pulse)
    );

    button_auto_repeat #(
        .CLK_FREQ(CLK_FREQ),
        .HOLD_DELAY_MS(500),
        .REPEAT_RATE_MS(200)
    ) u_down_auto_repeat (
        .clk(clk),
        .rst_n(rst_n),
        .btn_clean(down),
        .pulse_out(down_pulse)
    );

    // Tạm bỏ
    // // Create one-clock pulses for manual adjustment events.
    // reg up_q;
    // reg down_q;
    // wire up_pulse;
    // wire down_pulse;

    // always @(posedge clk or negedge rst_n) begin
    //     if (!rst_n) begin
    //         up_q <= 1'b0;
    //         down_q <= 1'b0;
    //     end else begin
    //         up_q <= up;
    //         down_q <= down;
    //     end
    // end

    // assign up_pulse = up & ~up_q;
    // assign down_pulse = down & ~down_q;

    wire [4:0] hour_raw;
    wire [5:0] hour;
    wire [4:0] day;
    wire [5:0] min;
    wire [3:0] month;
    wire [5:0] sec;
    wire [13:0] year;

    assign hour = {1'b0, hour_raw};

    clock_block u_clock_block(
        .clk(clk),
        .up_btn(up_pulse),
        .down_btn(down_pulse),
        .adj_target(adj_target),
        .adj_en(adj_en),
        .mode(mode),
        .rst_n(rst_n),
        .tick_1Hz(tick_1Hz),
        .value_second(sec),
        .value_minute(min),
        .value_hour(hour_raw),
        .value_day(day),
        .value_month(month),
        .value_year(year)
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