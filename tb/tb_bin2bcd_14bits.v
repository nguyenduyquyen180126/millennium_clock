`timescale 1ns/1ps

module tb_bin2bcd_14bits;
    reg [13:0] bin;
    wire [15:0] bcd;
    integer i;
    integer errors = 0;

    bin2bcd_14bits dut (
        .bin(bin),
        .bcd(bcd)
    );
    
    function [15:0] to_bcd(input [13:0] val);
        begin
            to_bcd[3:0]   = val % 10;
            to_bcd[7:4]   = (val / 10) % 10;
            to_bcd[11:8]  = (val / 100) % 10;
            to_bcd[15:12] = (val / 1000) % 10;
        end
    endfunction

    task check_bcd(input [13:0] in_val, input [15:0] actual_bcd, input [15:0] expected_bcd);
        begin
            if (actual_bcd !== expected_bcd) begin
                $display("[FAIL] Mismatch at %0d: got BCD = %h, expected = %h", in_val, actual_bcd, expected_bcd);
                errors = errors + 1;
            end
        end
    endtask

    initial begin
        $display("Starting bin2bcd_14bits testbench...");

        for (i = 0; i < 10000; i = i + 1) begin
            bin = i;
            #1;
            check_bcd(i, bcd, to_bcd(i));
        end
        
        if (errors === 0) begin
            $display("ALL TESTS PASSED");
        end else begin
            $display("FAIL %0d TESTS", errors);
        end

        $finish;
    end

endmodule