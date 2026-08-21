module clkdiv #(
    parameter CLK_FREQ_HZ = 50_000_000
)(
    input wire clk,
    input wire rst_n,
    output reg tick_1Hz,    // Tính hiệu en 1 chu kỳ để cấp cho các FF
    output reg clk_2Hz      // Xung 50% chu kỳ 1s nháy led
);
    localparam CNT_MAX = CLK_FREQ_HZ / 2;   // Đếm nửa chu kỳ
    localparam CNT_WIDTH = $clog2(CNT_MAX);

    reg [CNT_WIDTH - 1:0] cnt;
    
    always @(posedge clk or negedge rst_n) begin
        if(~rst_n)begin
            cnt <= {CNT_WIDTH{1'b0}};
            tick_1Hz <= 1'b0;
            clk_2Hz <= 1'b0;
        end
        else if(cnt == CNT_MAX - 1) begin
            cnt <= {CNT_WIDTH{1'b0}};
            clk_2Hz <= ~clk_2Hz;
            tick_1Hz <= clk_2Hz;
        end
        else begin
            cnt <= cnt + 1;
            clk_2Hz <= clk_2Hz;
            tick_1Hz <= 0;
        end
        
    end

endmodule