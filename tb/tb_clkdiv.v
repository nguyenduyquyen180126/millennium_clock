`timescale 10us/10ns
module tb_clkdiv();
    reg clk, rst_n;
    wire en_out;

    clkdiv dut(.clk(clk), .rst_n(rst_n), .en_out);

    initial begin
        clk = 0;
        forever #0.001 clk = ~clk;
    end

    initial begin
        rst_n = 0;
        $monitor("Time: %0t | en_out = %0b", $time, en_out);
        

        #0.5; rst_n = 1;
        repeat(3000000) @(posedge clk);
    
        $finish;
    end
endmodule