`timescale 1ns / 1ps
module main(
    input [15:0] SWITCHES,
    input speed_up, speed_down, button_reset_in, clk,
    output [7:0] AN,
    output [6:0] SEG,
    // output reg [31:0] NUMBER,
    output r_out
);

reg [31:0] NUMBER;
reg[7:0] AN_MASK = 8'b11111111;
wire spd_up_en;
wire spd_down_en;
wire spd_up_signal;
wire spd_down_signal;
wire reset_signal_en;
wire reset_signal;

debounce #(128) dbnc_spd_up(
.clk(clk),
.in_signal(speed_up),
.clock_enable(1'b1),
.out_signal(spd_up_signal),
.out_signal_enable(spd_up_en));

debounce #(128) dbnc_spd_down(
.clk(clk),
.in_signal(speed_down),
.clock_enable(1'b1),
.out_signal(spd_down_signal),
.out_signal_enable(spd_down_en));

debounce #(128) dbnc_reset(
.clk(clk),
.in_signal(button_reset_in),
.clock_enable(1'b1),
.out_signal(reset_signal),
.out_signal_enable(reset_signal_en));

clk_divider #(1024) div(
    .clk(clk),
    .clk_div(clk_div)
);
    
SevenSegmentLED led(
    .AN_MASK(AN_MASK),
    .NUMBER(NUMBER),
    .clk(clk_div),
    .RESET(reset_signal),
    .AN(AN),
    .SEG(SEG)
);

PWM_FSM #(.SIZE(16)) pwm_r (
    .clk(clk),
    .reset(reset_signal),
    .clk_en(1'b1),
    .pwm_in(speed), // signed -> unsigned.
    .pwm_out(r_out)
);

reg [15:0] speed;

initial begin
    NUMBER <= 0;
    AN_MASK <= 8'b00000000;
    speed <= 16'b1000000000000000;
end

always@(posedge clk)
begin
    if (reset_signal)
    begin
        speed <= 16'b1000000000000000;
    end
    else 
        if(spd_up_en)begin
            speed <= speed + SWITCHES;
        end
        else if (spd_down_en)begin
            speed <= speed - SWITCHES;
        end 
end

always@(posedge clk)
begin
    NUMBER <= speed;
end

//genvar i;
//generate
//    for(i = 1; i < 5; i = i + 1)begin
//        always@(posedge clk)
//        begin
//            NUMBER[((i+1)*4-1)-:4] <= speed[((i+1)*4-1)-:4];
//        end
//    end
//endgenerate

endmodule