module display(
    input clk_2Hz,
    input [1:0] adj_target,
    input adj_en,
    input mode,
    input [5:0] hour,
    input [4:0] day,
    input [5:0] min,
    input [3:0] month,
    input [5:0] sec,
    input [13:0] year,
    output [13:0] led_hh_dd,
    output [13:0] led_mimi_momo,
    output [27:0] led_ss_yyyy
);
    wire blink_hh_dd, blink_mimi_momo, blink_ss_yyyy;
    display_ctrl u_dis_ctrl(
        .clk_2Hz(clk_2Hz), 
        .adj_target(adj_target),
        .adj_en(adj_en),
        .blink_hh_dd(blink_hh_dd),
        .blink_mimi_momo(blink_mimi_momo),
        .blink_ss_yyyy(blink_ss_yyyy)
    );

    wire [5:0] hh_dd_src;
    wire [5:0] mimi_momo_src;
    wire [13:0] ss_yyyy_src;
    assign hh_dd_src = (mode) ? {1'b0, day} : hour;
    assign mimi_momo_src = (mode) ? {2'b0, month} : min;
    assign ss_yyyy_src = (mode) ? year : {8'b0, sec[5:0]};

    wire [7:0] hh_dd_bcd, mimi_momo_bcd;
    wire [15:0] ss_yyyy_bcd;
    bin2bcd_6bits u_hh_dd_bin2bcd(.binary(hh_dd_src), .bcd(hh_dd_bcd));
    bin2bcd_6bits u_mimi_momo_bin2bcd(.binary(mimi_momo_src), .bcd(mimi_momo_bcd));
    bin2bcd_14bits u_ss_yyyy_bin2bcd(.bin(ss_yyyy_src), .bcd(ss_yyyy_bcd));

    // led_hh_dd (2 x 7-segments = 14 bits)
    // hh_dd_bcd[7:4] -> Tens digit
    // hh_dd_bcd[3:0] -> Units digit
    seven_seg_decoder u_hh_dd_tens(
        .blink(blink_hh_dd),
        .hex_code(hh_dd_bcd[7:4]),
        .seg_data(led_hh_dd[13:7])
    );
    seven_seg_decoder u_hh_dd_units(
        .blink(blink_hh_dd),
        .hex_code(hh_dd_bcd[3:0]),
        .seg_data(led_hh_dd[6:0])
    );

    // led_mimi_momo (2 x 7-segments = 14 bits)
    // mimi_momo_bcd[7:4] -> Tens digit
    // mimi_momo_bcd[3:0] -> Units digit
    seven_seg_decoder u_mimi_momo_tens(
        .blink(blink_mimi_momo),
        .hex_code(mimi_momo_bcd[7:4]),
        .seg_data(led_mimi_momo[13:7])
    );
    seven_seg_decoder u_mimi_momo_units(
        .blink(blink_mimi_momo),
        .hex_code(mimi_momo_bcd[3:0]),
        .seg_data(led_mimi_momo[6:0])
    );

    // led_ss_yyyy (4 x 7-segments = 28 bits)
    // ss_yyyy_bcd[15:12] -> Thousands digit
    // ss_yyyy_bcd[11:8]  -> Hundreds digit
    // ss_yyyy_bcd[7:4]   -> Tens digit
    // ss_yyyy_bcd[3:0]   -> Units digit
    seven_seg_decoder u_ss_yyyy_thousands(
        .blink(blink_ss_yyyy),
        .hex_code(ss_yyyy_bcd[15:12]),
        .seg_data(led_ss_yyyy[27:21])
    );
    seven_seg_decoder u_ss_yyyy_hundreds(
        .blink(blink_ss_yyyy),
        .hex_code(ss_yyyy_bcd[11:8]),
        .seg_data(led_ss_yyyy[20:14])
    );
    seven_seg_decoder u_ss_yyyy_tens(
        .blink(blink_ss_yyyy),
        .hex_code(ss_yyyy_bcd[7:4]),
        .seg_data(led_ss_yyyy[13:7])
    );
    seven_seg_decoder u_ss_yyyy_units(
        .blink(blink_ss_yyyy),
        .hex_code(ss_yyyy_bcd[3:0]),
        .seg_data(led_ss_yyyy[6:0])
    );

endmodule