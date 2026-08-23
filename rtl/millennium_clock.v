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

    wire [5:0] hour;
    wire [4:0] day;
    wire [5:0] min;
    wire [3:0] month;
    wire [5:0] sec;
    wire [13:0] year;
    test_counter u_test_counter(
        .clk(clk),
        .tick_1Hz(tick_1Hz),
        .rst_n(rst_n),
        .up(up),
        .down(down),
        .adj_target(adj_target),
        .adj_en(adj_en),
        .mode(mode),
        .sec(sec),
        .min(min),
        .hour(hour),
        .day(day),
        .month(month),
        .year(year)
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