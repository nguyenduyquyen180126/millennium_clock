module counter_mod #(
        parameter MOD = 60,
        parameter WIDTH = $clog2(MOD)
    )(
    input clk, rst_n, en,
    output reg [WIDTH - 1:0] sec,
    output m_en
);
    assign m_en = (sec == MOD - 1) & en;

    always @(posedge clk or negedge rst_n) begin
        if(~rst_n) begin
            sec <= {WIDTH{1'b0}};
        end
        else if(en) begin
            if(sec == MOD - 1) begin
                sec <= {WIDTH{1'b0}};
            end
            else begin
                sec <= sec + 1'b1;
            end
        end
        else begin
            sec <= sec;
        end
    end
endmodule