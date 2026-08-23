`timescale 1ns/1ps

module tb_bin2bcd_14bits;
    reg [13:0] bin;
    wire [15:0] bcd;

    // Instantiate UUT
    bin2bcd_14bits uut (
        .bin(bin),
        .bcd(bcd)
    );

    integer i;
    reg [15:0] temp_bcd;
    
    // Function to calculate expected BCD behaviorally
    function [15:0] to_bcd(input [13:0] val);
        integer temp;
        begin
            temp = val;
            to_bcd[3:0]   = temp % 10;
            temp = temp / 10;
            to_bcd[7:4]   = temp % 10;
            temp = temp / 10;
            to_bcd[11:8]  = temp % 10;
            temp = temp / 10;
            to_bcd[15:12] = temp % 10;
        end
    endfunction

    initial begin
        $display("Starting bin2bcd_14bits testbench...");
        
        // Test a few specific numbers
        bin = 14'd0;
        #10;
        if (bcd !== 16'h0) $display("Error for 0: bcd = %h", bcd);

        bin = 14'd25;
        #10;
        if (bcd !== 16'h0025) $display("Error for 25: bcd = %h", bcd);

        bin = 14'd9999;
        #10;
        if (bcd !== 16'h9999) $display("Error for 9999: bcd = %h", bcd);


        // Exhaustive test
        for (i = 0; i < 10000; i = i + 1) begin
            bin = i;
            #1;
            temp_bcd = to_bcd(i);
            if (bcd !== temp_bcd) begin
                $display("Mismatch at %d: got %h, expected %h", i, bcd, temp_bcd);
                $finish;
            end
        end
        
        $display("All tests passed successfully!");
        $finish;
    end
endmodule
