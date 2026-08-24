module decoder #(parameter target =2'b00)(
    input adj_en,
    input mode,
    input up_btn,
    input down_btn,
    input [1:0] adj_target,
    output reg inc_manual,
    output reg dec_manual
);
    always @(*) begin
        if(adj_en && mode ==1'b0 && adj_target == target && up_btn) begin
            inc_manual = 1'b1;
            dec_manual = 1'b0;
        end else if(adj_en && mode == 1'b0 && adj_target == target && down_btn) begin
            inc_manual = 1'b0;
            dec_manual = 1'b1;
        end else begin
            inc_manual = 1'b0;
            dec_manual = 1'b0;
        end 
    end
endmodule