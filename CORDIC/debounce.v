`timescale 1ns / 1ps
module debounce #(mode = 2)(
    input in_signal,
    input clock_enable,
    input clk,
    output out_signal,
    output out_signal_enable,
    output wire [1:0] q_count
);

    wire out_sync;
    wire out_xnor;
    wire out_first_and;
    wire out_second_and;
    wire out_third_and;
    synchro syn(
        .in_signal(in_signal),
        .clk(clk),
        .q(out_sync)
    );
    
    counter cs(
        .clk(clk),
        .RE(out_sync~^out_signal),
        .dir(0),
        .CE(clock_enable),
        .out(q_count)
    );
    
    dtrigger dt1(
        .C(clk),
        .D(out_sync),
        .en(out_second_and),
        .q(out_signal)
    );
    dtrigger dt2(
        .C(clk),
        .D(out_third_and),
        .en(1'b1),
        .q(out_signal_enable)
    );
    
    assign out_first_and = &q_count;
    assign out_second_and = out_first_and & clock_enable;
    assign out_third_and = out_second_and & out_sync;
    
endmodule

`timescale 1ns / 1ps
module synchro(
    input in_signal,
    input clk,
    output q,
    output notq
);
    reg new_signal = 1'bx;
    reg last_signal = 1'bx;
    wire lq;
    dtrigger tr1(
        .C(clk),
        .D(new_signal),
        .en(1'b1),
        .q(lq)
    );
    dtrigger tr2(
        .C(clk),
        .D(last_signal),
        .en(1'b1),
        .q(q)
    );
    always @(posedge clk) begin
        new_signal=in_signal;
        last_signal=lq;
    end
endmodule

`timescale 1ns / 1ps
module dtrigger(
    input wire C,
    input wire D,
    input wire en,
    output reg q
);
    initial begin
        q<=0;
    end
    
    always @(posedge C) begin
        if(en) begin
            q <= D;
        end
    end
endmodule