module counter_thang(
    input clk,
    input rst_n,
    input inc_auto,
    input inc_manual,
    input dec_manual,
    output reg [3:0] value,
    output reg carry_out
);
    always @(posedge clk or negedge rst_n) begin
        if(~rst_n) begin
            value <= 4'd1;
            carry_out <= 1'b0;
        end 
        else if(inc_auto) begin
            if(value == 4'd12) begin
                value <= 4'd1;
                carry_out <= 1'b1;
            end else begin
                value <= value + 1'b1;
                carry_out <= 1'b0;
            end
        end else if(inc_manual) begin
            if(value == 4'd12) begin
                value <= 4'd1;
            end else begin
                value <= value + 1'b1;
            end
        end else if(dec_manual) begin
            if(value == 4'd1) begin
                value <= 4'd12;
            end else begin
                value <= value - 1'b1;
            end
        end else begin
            value <= value;
            carry_out <= 1'b0;
        end
    end
endmodule