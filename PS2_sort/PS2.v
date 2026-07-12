module PS2(
    input clk,
    input PS2_clk,
    input PS2_dat,
    output [7:0] out,
    output reg R_O,
    output reg ERROR
);
 
parameter WAIT_START_BIT = 0, 
          IDLE = 1, 
          WRITE = 2, 
          PARITY_BIT = 3, 
          STOP_BIT = 4;
reg [2:0] state;
 
reg [3:0] cnt;
reg [7:0] PS2_buf;
reg [1:0] PS2_clk_sync, PS2_dat_sync;

assign out = PS2_buf;

initial
begin
    cnt = 0;
    R_O = 0;
    ERROR = 0;
    state = WAIT_START_BIT;
    PS2_buf = 0;
    PS2_clk_sync = 2'b11;
    PS2_dat_sync = 2'b11;
end


always@(posedge clk)
begin
    PS2_clk_sync <= {PS2_clk_sync[0], PS2_clk};
    PS2_dat_sync <= {PS2_dat_sync[0], PS2_dat};
end

 
// Блок управления буфером для записи пакета    
always@(negedge PS2_clk_sync[1])
begin
    case(state)
        
        // Ожидание стартового бита
        WAIT_START_BIT:
        begin
            R_O <= 0; 
            ERROR <= 0;
            state <= ~PS2_dat_sync[1] ? WRITE : IDLE;
        end
        
        // Ожидание конца пакета
        IDLE:
            if (cnt == 4'd10)
            begin
                ERROR <= 1;
                R_O <= 1;
                state <= WAIT_START_BIT;         
            end 
                
        // Обработка битов данных
        WRITE: begin
            if (cnt == 4'd8)
                state <= PARITY_BIT;
            PS2_buf <= {PS2_dat_sync[1], PS2_buf[7:1]};
        end
        
        // Обработка бита чётности 
        PARITY_BIT: begin  
            if ((~^PS2_buf) == PS2_dat_sync[1])
                state <= STOP_BIT;
            else 
                state <= IDLE; 
        end
        
        // Обработка стоп-бита  
        STOP_BIT: begin
            if (!PS2_dat_sync[1])
                ERROR <= 1;  
            R_O <= 1;
            state <= WAIT_START_BIT;  
        end             
    endcase   
end

always@(negedge PS2_clk_sync[1])
begin
    cnt <= cnt + 1;
    if (cnt == 4'd10)
        cnt <= 0;    
end

endmodule
