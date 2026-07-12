`timescale 1ns / 1ps
module main(
    input [3:0] SWITCHES,
    input button_in, clk, button_reset_in,
    output [7:0] AN,
    output [6:0] SEG
//    output reg [31:0] NUMBER,
//    output wire button_en,
//    output wire button_reset_en,
//    output reg error_output
);
    wire button_signal, button_signal_en, reset_signal_en, reset_signal;
    reg error_output;
    reg[7:0] AN_MASK = 8'b11111111;
    reg [3:0] dataIn;
    wire [15:0] dataOut;
    reg [3:0] n; // размер массива
    reg flag;
    reg error_flag;
    wire R_O;
    reg R_I;
    reg [31:0] NUMBER;
    initial begin
        NUMBER <= 0;
        dataIn <= 0;
        flag <= 1'b1;
        R_I <= 0;
        error_flag <= 0;
    end
    filtercon #(128) dbnc(
        .clk(clk),
        .in_signal(button_in),
        .clock_enable(1'b1),
        .out_signal(button_signal),
        .out_signal_enable(button_signal_en)
    );
    
    filtercon #(128) dbnc_reset(
        .clk(clk),
        .in_signal(button_reset_in),
        .clock_enable(1'b1),
        .out_signal(reset_signal),
        .out_signal_enable(reset_signal_en)
    );
    
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
    
    fsm #(4, 4)fsm1 (
        .n(n),
        .clk(clk),
        .reset(reset_signal),
        .R_I(R_I), // todo button_signal_en
        .dataIn(dataIn),
        .dataOut(dataOut),
        .R_O(R_O) // todo
    );
    integer i;
    always@(posedge clk)
    begin
        if (reset_signal)
        begin
            NUMBER <= 0;
            AN_MASK <= 8'b11111111;
            flag <= 1'b1;
            error_flag <= 0;
            error_output <= 0;
        end
        else if(!error_flag)
            if (button_signal_en)
                begin
                    if(flag)begin
                        flag <= 0;
                        n <= SWITCHES;
                        if(SWITCHES > 8)begin
                            error_output <= 1'b1;
                            error_flag <= 1'b1;
                        end
                    end
                    else begin
                        if(!R_O)begin
                            R_I <= 1'b1;
                            dataIn <= SWITCHES;
                            NUMBER <= {NUMBER[27:0], SWITCHES}; 
                            AN_MASK <= {AN_MASK[6:0], 1'b0};
                        end                   
                    end
                end
            else begin
                if(R_O)begin
                    NUMBER <= 0;
                    NUMBER <= dataOut;
                    AN_MASK <= 8'b11111111;
                    //for(i = 0; i < n; i = i + 1)
                    AN_MASK = AN_MASK << n;
                end
                R_I <= 0;
            end
    end
    
endmodule