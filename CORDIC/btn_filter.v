`timescale 1ns / 1ps

module btn_filter #(CNTR_WIDTH = 8)(
input clk,
input ce,
input btn_in,
output reg btn_out,
output reg btn_ceo
);

reg BTN_D, BTN_S1;
reg [CNTR_WIDTH-1:0] FLTR_CNT;
reg BTN_S2;

initial begin
    BTN_D <= 1'b0;
    BTN_S1 <= 1'b0;
end

always@(posedge clk)
begin
    BTN_D <= btn_in;
    BTN_S1 <= BTN_D;
end

always@(posedge clk)
    // if(rst)FLTR_CNT <= {CNTR_WIDTH{1'b0}};
    if(~(BTN_S1 ^ BTN_S2)) FLTR_CNT <= {CNTR_WIDTH{1'b0}};
    else if(ce) FLTR_CNT <= FLTR_CNT + 1'b1;

always @(posedge clk) begin
    // if(rst)btn_ceo <= 1'b0;
    if(ce & (&FLTR_CNT)) BTN_S2 <= BTN_S1;
end

always @(posedge clk) begin
    // if(rst) btn_ceo <= 1'b0;
    btn_ceo <= ce & (&FLTR_CNT) & BTN_S1;
end

assign BTN_OUT = btn_ceo;

endmodule