module clock_block(
    input clk,
    input up_btn,
    input down_btn,
    input [1:0] adj_target,
    input adj_en,
    input mode,
    input rst_n,
    input tick_1Hz,
    output [5:0] value_second,
    output [5:0] value_minute,
    output [4:0] value_hour,
    output [4:0] value_day,
    output [3:0] value_month,
    output [13:0] value_year
);
    wire inc_second_manual, dec_second_manual;
    wire inc_minute_manual, dec_minute_manual;
    wire inc_hour_manual, dec_hour_manual;
    wire inc_day_manual, dec_day_manual;
    wire inc_month_manual, dec_month_manual;
    wire inc_year_manual, dec_year_manual;
    
    wire inc_second_auto, inc_minute_auto, inc_hour_auto;
    wire inc_day_auto, inc_month_auto, inc_year_auto;

    wire sec_carry_unused;
    wire min_carry_unused;
    wire hour_carry_unused;
    wire day_carry_unused;
    wire month_carry_unused;
    wire leap;
    wire [4:0] dim;

    wire run_auto = (~adj_en) & tick_1Hz;

    assign inc_second_auto = run_auto;
    assign inc_minute_auto = run_auto && (value_second == 6'd59);
    assign inc_hour_auto   = run_auto && (value_second == 6'd59) && (value_minute == 6'd59);
    assign inc_day_auto    = run_auto && (value_second == 6'd59) && (value_minute == 6'd59) && (value_hour == 5'd23);
    assign inc_month_auto  = run_auto && (value_second == 6'd59) && (value_minute == 6'd59) && (value_hour == 5'd23) && (value_day == dim);
    assign inc_year_auto   = run_auto && (value_second == 6'd59) && (value_minute == 6'd59) && (value_hour == 5'd23) && (value_day == dim) && (value_month == 4'd12);

    // Decoder cấu hình thủ công cho Giờ/Phút/Giây (mode = 0 hoặc 1 tùy thiết kế)
    decoder #(.target(2'b01)) u_decoder_second(
        .adj_en(adj_en),
        .mode(mode),
        .up_btn(up_btn),
        .down_btn(down_btn),
        .adj_target(adj_target),
        .inc_manual(inc_second_manual),
        .dec_manual(dec_second_manual)
    );

    decoder #(.target(2'b10)) u_decoder_minute(
        .adj_en(adj_en),
        .mode(mode),
        .up_btn(up_btn),
        .down_btn(down_btn),
        .adj_target(adj_target),
        .inc_manual(inc_minute_manual),
        .dec_manual(dec_minute_manual)
    );

    decoder #(.target(2'b11)) u_decoder_hour(
        .adj_en(adj_en),
        .mode(mode),
        .up_btn(up_btn),
        .down_btn(down_btn),
        .adj_target(adj_target),
        .inc_manual(inc_hour_manual),
        .dec_manual(dec_hour_manual)
    );

    // Decoder cấu hình thủ công cho Ngày/Tháng/Năm (~mode)
    decoder #(.target(2'b11)) u_decoder_day(
        .adj_en(adj_en),
        .mode(~mode),
        .up_btn(up_btn),
        .down_btn(down_btn),
        .adj_target(adj_target),
        .inc_manual(inc_day_manual),
        .dec_manual(dec_day_manual)
    );

    decoder #(.target(2'b10)) u_decoder_month(
        .adj_en(adj_en),
        .mode(~mode),
        .up_btn(up_btn),
        .down_btn(down_btn),
        .adj_target(adj_target),
        .inc_manual(inc_month_manual),
        .dec_manual(dec_month_manual)
    );

    decoder #(.target(2'b01)) u_decoder_year(
        .adj_en(adj_en),
        .mode(~mode),
        .up_btn(up_btn),
        .down_btn(down_btn),
        .adj_target(adj_target),
        .inc_manual(inc_year_manual),
        .dec_manual(dec_year_manual)
    );

    // Nối trực tiếp ngõ ra counter vào các port output
    counter_chung3 #(.MAX_CHECK(60)) u_sec_counter (
        .clk(clk),
        .rst_n(rst_n),
        .inc_auto(inc_second_auto),
        .inc_manual(inc_second_manual),
        .dec_manual(dec_second_manual),
        .value(value_second),
        .carry_out(sec_carry_unused)
    );

    counter_chung3 #(.MAX_CHECK(60)) u_min_counter (
        .clk(clk),
        .rst_n(rst_n),
        .inc_auto(inc_minute_auto),
        .inc_manual(inc_minute_manual),
        .dec_manual(dec_minute_manual),
        .value(value_minute),
        .carry_out(min_carry_unused)
    );

    counter_chung3 #(.MAX_CHECK(24)) u_hour_counter (
        .clk(clk),
        .rst_n(rst_n),
        .inc_auto(inc_hour_auto),
        .inc_manual(inc_hour_manual),
        .dec_manual(dec_hour_manual),
        .value(value_hour),
        .carry_out(hour_carry_unused)
    );

    counter_nam u_year_counter (
        .clk(clk),
        .rst_n(rst_n),
        .inc_auto(inc_year_auto),
        .inc_manual(inc_year_manual),
        .dec_manual(dec_year_manual),
        .value(value_year),
        .leap(leap)
    );

    counter_thang u_month_counter (
        .clk(clk),
        .rst_n(rst_n),
        .inc_auto(inc_month_auto),
        .inc_manual(inc_month_manual),
        .dec_manual(dec_month_manual),
        .value(value_month),
        .carry_out(month_carry_unused)
    );

    counter_dim u_dim (
        .value_month(value_month),
        .leap(leap),
        .dim(dim)
    );

    counter_ngay u_day_counter (
        .clk(clk),
        .rst_n(rst_n),
        .inc_auto(inc_day_auto),
        .inc_manual(inc_day_manual),
        .dec_manual(dec_day_manual),
        .dim(dim),
        .value(value_day),
        .carry_out(day_carry_unused)
    );

endmodule