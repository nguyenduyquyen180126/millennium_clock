module counter_dim(
    input [3:0] value_month,
    input leap,
    output reg [4:0] dim
);
    always @(value_month or leap) begin
        case (value_month)
            4'd1, 4'd3, 4'd5, 4'd7, 4'd8, 4'd10, 4'd12: dim = 5'd31;
            4'd4, 4'd6, 4'd9, 4'd11: dim = 5'd30;
            4'd2: dim = leap ? 5'd29 : 5'd28;
            default: dim = 5'd0;
        endcase
    end
endmodule
