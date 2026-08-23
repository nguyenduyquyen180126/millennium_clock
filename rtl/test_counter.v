// Counter to test UI and debounce
module test_counter(
    input clk,
    input tick_1Hz,
    input rst_n,
    input up,
    input down,
    input [1:0] adj_target,
    input adj_en,
    input mode,
    output [5:0] sec,
    output [5:0] min,
    output [5:0] hour,
    output [4:0] day,
    output [3:0] month,
    output reg [13:0] year
);
    // Explicit wire declarations
    wire inc_auto;
    wire inc_manual;
    wire dec_manual;

    // Static display assignments (to test UI, these are fixed)
    assign sec   = 6'd12;
    assign min   = 6'd43;
    assign hour  = 6'd16;
    assign day   = 5'd30;
    assign month = 4'd4;

    // Edge detection for up/down inputs to prevent fast counting
    reg up_q, down_q;
    wire up_pulse   = up & ~up_q;
    wire down_pulse = down & ~down_q;

    always @(posedge clk or negedge rst_n) begin
        if (~rst_n) begin
            up_q   <= 1'b0;
            down_q <= 1'b0;
        end else begin
            up_q   <= up;
            down_q <= down;
        end
    end

    assign inc_auto = (~adj_en) & tick_1Hz;
    assign inc_manual = adj_en & (adj_target == 2'b01) & mode & up_pulse;
    assign dec_manual = adj_en & (adj_target == 2'b01) & mode & down_pulse;

    always @(posedge clk or negedge rst_n) begin
        if(~rst_n) begin
            year <= 14'd2024;
        end
        else begin
            case({inc_auto, inc_manual, dec_manual})
                3'b100: year <= year + 1'b1;
                3'b010: year <= year + 1'b1;
                3'b001: year <= year - 1'b1;
                default: year <= year;
            endcase
        end
    end
endmodule