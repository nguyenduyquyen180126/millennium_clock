module top(
    input wire CLOCK_50,        // 50 MHz Clock input
    input wire [3:0] KEY,       // Pushbuttons (Active-low on DE2-115)
    input wire [17:0] SW,       // Slide switches (Active-high)
    
    // 8 7-Segment Displays on DE2-115 (Active-low segments)
    output wire [6:0] HEX0,     // Seconds / Year Units (SS/YYYY)
    output wire [6:0] HEX1,     // Seconds / Year Tens (SS/YYYY)
    output wire [6:0] HEX2,     // Year Hundreds (SS/YYYY)
    output wire [6:0] HEX3,     // Year Thousands (SS/YYYY)
    output wire [6:0] HEX4,     // Minutes / Month Units (MM/MO)
    output wire [6:0] HEX5,     // Minutes / Month Tens (MM/MO)
    output wire [6:0] HEX6,     // Hours / Day Units (HH/DD)
    output wire [6:0] HEX7      // Hours / Day Tens (HH/DD)
);

    // 1. Clock and Reset
    wire clk = CLOCK_50;

    // 2. Pushbuttons (Active-low on board)
    // Invert KEY[1] and KEY[2] to make them active-high (1 when pressed)
    // for the debouncers in the core logic.
    wire up_btn_active_high   = ~KEY[2];
    wire down_btn_active_high = ~KEY[3];

    // 3. Switch Mappings
    // SW[1:0] -> adj_target (01: Sec/Year, 10: Min/Month, 11: Hour/Day)
    // SW[2]   -> adj_en (Adjustment Enable)
    // SW[3]   -> mode (0: Time display, 1: Date display)
    wire [1:0] adj_target = SW[17:16];
    wire adj_en = SW[1];
    wire mode = SW[2];
    wire rst_n = SW[0];

    // Intermediate display connections from core
    wire [13:0] led_hh_dd;
    wire [13:0] led_mimi_momo;
    wire [27:0] led_ss_yyyy;

    // 4. Instantiate the Core Millennium Clock
    millennium_clock #(
        .CLK_FREQ(50_000_000),      // 50 MHz board clock
        .DEBOUNCE_TIME_MS(20)       // 20 ms debounce time
    ) u_core_clock (
        .clk(clk),
        .rst_n(rst_n),
        .up_btn(up_btn_active_high),
        .down_btn(down_btn_active_high),
        .adj_target(adj_target),
        .adj_en(adj_en),
        .mode(mode),
        .led_hh_dd(led_hh_dd),
        .led_mimi_momo(led_mimi_momo),
        .led_ss_yyyy(led_ss_yyyy)
    );

    // 5. Connect core display buses to physical HEX ports
    // HEX0-HEX3: Seconds / Year (led_ss_yyyy has 28 bits)
    assign HEX0 = led_ss_yyyy[6:0];
    assign HEX1 = led_ss_yyyy[13:7];
    assign HEX2 = led_ss_yyyy[20:14];
    assign HEX3 = led_ss_yyyy[27:21];

    // HEX4-HEX5: Minutes / Month (led_mimi_momo has 14 bits)
    assign HEX4 = led_mimi_momo[6:0];
    assign HEX5 = led_mimi_momo[13:7];

    // HEX6-HEX7: Hours / Day (led_hh_dd has 14 bits)
    assign HEX6 = led_hh_dd[6:0];
    assign HEX7 = led_hh_dd[13:7];

endmodule
