module button_auto_repeat #(
    parameter CLK_FREQ = 50_000_000,
    parameter HOLD_DELAY_MS = 1000, // Nhấn giữ 1s để bắt đầu lặp
    parameter REPEAT_RATE_MS = 200  // Tốc độ lặp: 0.2s một lần
)(
    input  wire clk,
    input  wire rst_n,
    input  wire btn_clean,    // Đầu vào: Tín hiệu từ module Debounce
    output reg  pulse_out     // Đầu ra: Xung nhọn 1 chu kỳ clock
);

    localparam HOLD_MAX = (CLK_FREQ / 1000) * HOLD_DELAY_MS;
    localparam REP_MAX  = (CLK_FREQ / 1000) * REPEAT_RATE_MS;
    
    // Tìm kích thước thanh ghi đủ lớn để chứa biến đếm HOLD_MAX
    localparam CNT_WIDTH = $clog2(HOLD_MAX + 1);

    reg [CNT_WIDTH-1:0] rep_cnt;
    reg btn_clean_prev; 
    reg is_holding;     

    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            pulse_out <= 1'b0;
            rep_cnt <= 0;
            btn_clean_prev <= 1'b0;
            is_holding <= 1'b0;
        end else begin
            // Trễ 1 nhịp để dò sườn lên
            btn_clean_prev <= btn_clean;
            
            // Xung kim: Mặc định luôn kéo về 0
            pulse_out <= 1'b0; 

            if (btn_clean) begin
                if (btn_clean_prev == 1'b0) begin
                    // 1. Nhấp nhả: Bắn 1 xung ngay lập tức khi vừa nhấn
                    pulse_out <= 1'b1;
                    rep_cnt <= 0;
                    is_holding <= 1'b0;
                end else begin
                    // 2. Nhấn giữ: Tăng biến đếm
                    rep_cnt <= rep_cnt + 1;
                    
                    if (!is_holding) begin
                        // Đợi qua mốc HOLD_DELAY
                        if (rep_cnt >= HOLD_MAX - 1) begin
                            pulse_out <= 1'b1;
                            rep_cnt <= 0;
                            is_holding <= 1'b1;
                        end
                    end else begin
                        // Đã vào chế độ lặp: Đợi qua mốc REPEAT_RATE
                        if (rep_cnt >= REP_MAX - 1) begin
                            pulse_out <= 1'b1;
                            rep_cnt <= 0;
                        end
                    end
                end
            end else begin
                // Nhả phím: Xóa sạch trạng thái
                rep_cnt <= 0;
                is_holding <= 1'b0;
            end
        end
    end

endmodule