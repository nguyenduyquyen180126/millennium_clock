module add3(
    input [3:0] in,
    output [3:0] out
);
    assign out = (in > 4'd4) ? in + 4'd3 : in;
endmodule