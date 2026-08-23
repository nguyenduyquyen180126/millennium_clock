module seven_seg_decoder(
    input wire blink,
    input wire [3:0] hex_code,
    output reg [6:0] seg_data
);
    always @(*) begin
        if(blink) begin
            seg_data = 7'b1111111;
        end
        else begin
            case(hex_code)
                4'h0: seg_data = 7'b1000000;
                4'h1: seg_data = 7'b1111001;
                4'h2: seg_data = 7'b0100100;
                4'h3: seg_data = 7'b0110000;
                4'h4: seg_data = 7'b0011001;
                4'h5: seg_data = 7'b0010010;
                4'h6: seg_data = 7'b0000010;
                4'h7: seg_data = 7'b1111000;
                4'h8: seg_data = 7'b0000000;
                4'h9: seg_data = 7'b0010000;
                default: seg_data = 7'b1111111;
            endcase
        end
    end
endmodule