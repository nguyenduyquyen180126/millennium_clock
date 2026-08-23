module bin2bcd_14bits(
    input [13:0] bin,
    output [15:0] bcd
);
    wire [13:0] w0, w1, w2;
    wire [14:0] w3, w4, w5;
    wire [15:0] w6, w7, w8;
    wire [16:0] w9;

    // Tang 1
    add3 u0(.in(bin[13:10]), .out(w0[13:10]));
    assign w0[9:0] = bin[9:0];

    // Tang 2
    add3 u1(.in(w0[12:9]), .out(w1[12:9]));
    assign w1[13] = w0[13];
    assign w1[8:0] = w0[8:0];

    // Tang 3
    add3 u2(.in(w1[11:8]), .out(w2[11:8]));
    assign w2[13:12] = w1[13:12];
    assign w2[7:0] = w1[7:0];

    // Tang 4
    add3 u3(.in({1'b0, w2[13:11]}), .out(w3[14:11]));
    add3 u4(.in(w2[10:7]), .out(w3[10:7]));
    assign w3[6:0] = w2[6:0];

    // Tang 5
    add3 u5(.in(w3[13:10]), .out(w4[13:10]));
    add3 u6(.in(w3[9:6]), .out(w4[9:6]));
    assign w4[14] = w3[14];
    assign w4[5:0] = w3[5:0];

    // Tang 6
    add3 u7(.in(w4[12:9]), .out(w5[12:9]));
    add3 u8(.in(w4[8:5]), .out(w5[8:5]));
    assign w5[14:13] = w4[14:13];
    assign w5[4:0] = w4[4:0];

    // Tang 7
    add3 u9(.in({1'b0, w5[14:12]}), .out(w6[15:12]));
    add3 u10(.in(w5[11:8]), .out(w6[11:8]));
    add3 u11(.in(w5[7:4]), .out(w6[7:4]));
    assign w6[3:0] = w5[3:0];

    // Tang 8
    add3 u12(.in(w6[14:11]), .out(w7[14:11]));
    add3 u13(.in(w6[10:7]), .out(w7[10:7]));
    add3 u14(.in(w6[6:3]), .out(w7[6:3]));
    assign w7[15] = w6[15];
    assign w7[2:0] = w6[2:0];

    // Tang 9
    add3 u15(.in(w7[13:10]), .out(w8[13:10]));
    add3 u16(.in(w7[9:6]), .out(w8[9:6]));
    add3 u17(.in(w7[5:2]), .out(w8[5:2]));
    assign w8[15:14] = w7[15:14];
    assign w8[1:0] = w7[1:0];

    // Tang 10
    add3 u18(.in({1'b0, w8[15:13]}), .out(w9[16:13]));
    add3 u19(.in(w8[12:9]), .out(w9[12:9]));
    add3 u20(.in(w8[8:5]), .out(w9[8:5]));
    add3 u21(.in(w8[4:1]), .out(w9[4:1]));
    assign w9[0] = w8[0];

    assign bcd = w9[15:0];

endmodule