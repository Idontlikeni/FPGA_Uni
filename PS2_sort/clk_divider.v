`timescale 1ns / 1ps
module clk_divider#(div = 2) (
    input clk,
    output reg clk_div
);
    reg l;
    wire [8:0] out;
    count #(.step(1), .mod(div/2)) cntr(
        .clk(clk),
        .RE(1'b0),
        .CE(1'b1),
        .dir(1'b0),
        .out(out)
    );
    initial clk_div = 0;
    always@(posedge clk)begin
        if (out ==0 && l==1)
        clk_div = ~clk_div;
        l<=1;
    end
endmodule
