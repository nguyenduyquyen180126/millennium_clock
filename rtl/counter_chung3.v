module counter_mod #(parameter MAX_CHECK= 60,
                    parameter integer WIDTH = $clog2(MAX_CHECK) 
)(
    input clk,
    input rst_n,
    input inc_auto,
    input inc_manual,
    input dec_manual,
    output reg [WIDTH-1:0] value,
    output reg carry_out
);
    always @(posedge clk or negedge rst_n) begin
        if(~rst_n) begin
            value <= {WIDTH{1'b0}};
            carry_out <= 1'b0;
        end 
        else if(inc_auto) begin
            if(value == MAX_CHECK -1) begin
                value <= {WIDTH{1'b0}};
                carry_out <= 1'b1;
            end else begin
                value <= value + 1'b1;
                carry_out <= 1'b0;
            end
        end else if(inc_manual) begin
            if(value == MAX_CHECK -1) begin
                value <= {WIDTH{1'b0}};
            end else begin
                value <= value + 1'b1;
            end
        end else if(dec_manual) begin
            if(value == {WIDTH{1'b0}}) begin
                value <= MAX_CHECK -1;
            end else begin
                value <= value - 1'b1;
            end
        end else begin
            value <= value;
            carry_out <= 1'b0;
        end
    end
endmodule

module counter_chung3 #(parameter MAX_CHECK= 60,
                        parameter integer WIDTH = $clog2(MAX_CHECK)
)(
    input clk,
    input rst_n,
    input inc_auto,
    input inc_manual,
    input dec_manual,
    output [WIDTH-1:0] value,
    output carry_out
);
    counter_mod #(
        .MAX_CHECK(MAX_CHECK),
        .WIDTH(WIDTH)
    ) u_counter_mod (
        .clk(clk),
        .rst_n(rst_n),
        .inc_auto(inc_auto),
        .inc_manual(inc_manual),
        .dec_manual(dec_manual),
        .value(value),
        .carry_out(carry_out)
    );
endmodule