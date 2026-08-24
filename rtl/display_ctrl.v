module display_ctrl(
    input wire clk_2Hz,
    input wire [1:0] adj_target,
    input adj_en,
    input mode,
    output blink_hh_dd,
    output blink_mimi_momo,
    output blink_ss_yyyy,
    output off_yy__
);
    assign blink_ss_yyyy = clk_2Hz & adj_en & (adj_target == 2'b01);
    assign off_yy__ = (clk_2Hz & adj_en & (adj_target == 2'b01)) | (~mode);
    assign blink_mimi_momo = clk_2Hz & adj_en & (adj_target == 2'b10);
    assign blink_hh_dd = clk_2Hz & adj_en & (adj_target == 2'b11);
endmodule