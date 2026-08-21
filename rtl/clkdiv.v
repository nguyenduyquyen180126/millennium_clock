module clkdiv #(parameter DIV = 50000000)(
    input clk, rst_n,   // clk 50 MHz
    output reg tick_1Hz,
    
);

    reg [31:0] cnt;
    always @(posedge clk or negedge rst_n)begin
        if(~rst_n)begin
            cnt <= 32'b0;
            en_out <= 1'b0;
        end
        else if(cnt == DIV - 1)begin
            en_out <= 1'b1;
            cnt <= 1'b0;
        end
        else begin
            cnt <= cnt + 1;
            en_out <= 1'b0;
        end
    end
endmodule