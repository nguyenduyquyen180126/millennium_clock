`timescale 1ns/1ps

module tb_seven_seg_decoder;
    reg blink;
    reg [3:0] hex_code;
    wire [6:0] seg_data;
    
    integer i;
    integer errors = 0;

    seven_seg_decoder dut (
        .blink(blink),
        .hex_code(hex_code),
        .seg_data(seg_data)
    );

    function [6:0] get_expected(input in_blink, input [3:0] in_hex);
        begin
            if (in_blink) begin
                get_expected = 7'b1111111; 
            end else begin
                case (in_hex)
                    4'h0: get_expected = 7'b1000000;
                    4'h1: get_expected = 7'b1111001;
                    4'h2: get_expected = 7'b0100100;
                    4'h3: get_expected = 7'b0110000;
                    4'h4: get_expected = 7'b0011001;
                    4'h5: get_expected = 7'b0010010;
                    4'h6: get_expected = 7'b0000010;
                    4'h7: get_expected = 7'b1111000;
                    4'h8: get_expected = 7'b0000000;
                    4'h9: get_expected = 7'b0010000;
                    default: get_expected = 7'b1111111; 
                endcase
            end
        end
    endfunction

    task check(input [6:0] actual, input [6:0] expected);
        begin
            if (actual !== expected) begin
                $display("[FAIL] got %b, expected %b", actual, expected);
                errors = errors + 1;
            end
        end
    endtask

    initial begin
        $display("tb_seven_seg_decoder");

        blink = 0;
        for (i = 0; i < 16; i = i + 1) begin
            hex_code = i;
            #1;
            check(seg_data, get_expected(blink, hex_code));
        end

        blink = 1;
        for (i = 0; i < 16; i = i + 1) begin
            hex_code = i;
            #1;
            check(seg_data, get_expected(blink, hex_code));
        end

        if (errors === 0) begin
            $display("ALL TESTS PASSED");
        end else begin
            $display("FAIL %0d TEST", errors);
        end

        $finish;
    end

endmodule