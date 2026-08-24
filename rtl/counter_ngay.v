module counter_ngay(
    input clk,
    input rst_n,
    input inc_auto,
    input inc_manual,
    input dec_manual,
    input [4:0] dim,
    output reg [4:0] value,
    output reg carry_out
);
    reg [4:0] dim_old;
    always @(posedge clk or negedge rst_n) begin
        if(~rst_n) begin
            value <= 5'd1;
            carry_out <= 1'b0;
            dim_old <= 5'd0;
        end else begin
            carry_out <= 1'b0;
            if (dim != dim_old && value > dim) begin
                value <= dim;
                dim_old <= dim;
            end else if(inc_auto) begin
                if(value == dim) begin
                    value <= 5'd1;
                    carry_out <= 1'b1;
                end else begin
                    value <= value + 1'b1;
                end
                dim_old <= dim;
            end else if(inc_manual) begin
                if(value == dim) begin
                    value <= 5'd1;
                end else begin
                    value <= value + 1'b1;
                end
                dim_old <= dim;
            end else if(dec_manual) begin
                if(value == 5'd1) begin
                    value <= dim;
                end else begin
                    value <= value - 1'b1;
                end
                dim_old <= dim;
            end else begin
                value <= value;
                dim_old <= dim;
            end 
        end
    end
endmodule