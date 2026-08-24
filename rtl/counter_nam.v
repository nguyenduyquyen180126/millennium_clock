module counter_nam (
    input  clk,
    input  rst_n,
    input  inc_auto,
    input  inc_manual,
    input  dec_manual,
    output reg [13:0] value,
    output reg leap
);

    reg [1:0]  y_mod4;
    reg [6:0]  y_mod100;
    reg [8:0]  y_mod400;
    always @(*) begin
        if ((y_mod4 == 2'd0 && y_mod100 != 7'd0) || y_mod400 == 9'd0) begin
            leap = 1'b1;
        end else begin
            leap = 1'b0;
        end
    end

    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            value    <= 14'd2024;
            y_mod4   <= 2'd0;
            y_mod100 <= 7'd24;
            y_mod400 <= 9'd24;
        end else if (inc_auto) begin
            if (value == 14'd9999) begin
                value    <= 14'd0;
                y_mod4   <= 2'd0;
                y_mod100 <= 7'd0;
                y_mod400 <= 9'd0;
            end else begin
                if (y_mod4 == 2'd3) begin
                    y_mod4 <= 2'd0;
                end else begin
                    y_mod4 <= y_mod4 + 1'b1;
                end

                if (y_mod100 == 7'd99) begin
                    y_mod100 <= 7'd0;
                end else begin
                    y_mod100 <= y_mod100 + 1'b1;
                end

                if (y_mod400 == 9'd399) begin
                    y_mod400 <= 9'd0;
                end else begin
                    y_mod400 <= y_mod400 + 1'b1;
                end

                value <= value + 1'b1;
            end
        end else if (inc_manual) begin
            if (value == 14'd9999) begin
                value    <= 14'd0;
                y_mod4   <= 2'd0;
                y_mod100 <= 7'd0;
                y_mod400 <= 9'd0;
            end else begin
                if (y_mod4 == 2'd3) begin
                    y_mod4 <= 2'd0;
                end else begin
                    y_mod4 <= y_mod4 + 1'b1;
                end

                if (y_mod100 == 7'd99) begin
                    y_mod100 <= 7'd0;
                end else begin
                    y_mod100 <= y_mod100 + 1'b1;
                end

                if (y_mod400 == 9'd399) begin
                    y_mod400 <= 9'd0;
                end else begin
                    y_mod400 <= y_mod400 + 1'b1;
                end

                value <= value + 1'b1;
            end
        end else if (dec_manual) begin
            if (value == 14'd0) begin
                value    <= 14'd9999;
                y_mod4   <= 2'd3;
                y_mod100 <= 7'd99;
                y_mod400 <= 9'd399;
            end else begin
                if (y_mod4 == 2'd0) begin
                    y_mod4 <= 2'd3;
                end else begin
                    y_mod4 <= y_mod4 - 1'b1;
                end

                if (y_mod100 == 7'd0) begin
                    y_mod100 <= 7'd99;
                end else begin
                    y_mod100 <= y_mod100 - 1'b1;
                end

                if (y_mod400 == 9'd0) begin
                    y_mod400 <= 9'd399;
                end else begin
                    y_mod400 <= y_mod400 - 1'b1;
                end

                value <= value - 1'b1;
            end
        end else begin
            value    <= value;
            y_mod4   <= y_mod4;
            y_mod100 <= y_mod100;
            y_mod400 <= y_mod400;
        end
    end

endmodule