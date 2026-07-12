`timescale 1ns / 1ps

module PS2_DC(
    input [7:0] keycode,
    output reg [3:0] out,
    output reg [3:0] flags
);

reg [7:0] NUMBERS [0:15];
parameter [7:0] ENTER_CODE = 8'h5A;
parameter [7:0] BACKSPACE_CODE = 8'h66;
parameter [7:0] RESET_CODE = 8'h2D;                                   
parameter NUMBER_F = 0, ENTER_F = 1, BACKSPACE_F = 2, RESET_F = 3;

initial begin 
    NUMBERS[0] = 8'h45; 
    NUMBERS[1] = 8'h16;
    NUMBERS[2] = 8'h1E;
    NUMBERS[3] = 8'h26;
    NUMBERS[4] = 8'h25;
    NUMBERS[5] = 8'h2E;
    NUMBERS[6] = 8'h36;
    NUMBERS[7] = 8'h3D;
    NUMBERS[8] = 8'h3E;
    NUMBERS[9] = 8'h46;
    NUMBERS[10] = 8'h1C;
    NUMBERS[11] = 8'h32;
    NUMBERS[12] = 8'h21;
    NUMBERS[13] = 8'h23;
    NUMBERS[14] = 8'h24;
    NUMBERS[15] = 8'h2B;

    out = 0;
    flags = 0;
end

always@(keycode)
begin  
     case(keycode)
            // ײטפנû
            NUMBERS[0] : out = 4'h0; 
            NUMBERS[1] : out = 4'h1; 
            NUMBERS[2] : out = 4'h2;
            NUMBERS[3] : out = 4'h3;
            NUMBERS[4] : out = 4'h4;
            NUMBERS[5] : out = 4'h5;
            NUMBERS[6] : out = 4'h6;
            NUMBERS[7] : out = 4'h7;
            NUMBERS[8] : out = 4'h8;
            NUMBERS[9] : out = 4'h9; 
            NUMBERS[10]: out = 4'hA; 
            NUMBERS[11]: out = 4'hB; 
            NUMBERS[12]: out = 4'hC; 
            NUMBERS[13]: out = 4'hD; 
            NUMBERS[14]: out = 4'hE; 
            NUMBERS[15]: out = 4'hF;
            
            // Êכאגטרא "Enter"
            ENTER_CODE: out = 0;
            BACKSPACE_CODE: out = 0;
            RESET_CODE: out = 0;
            default: out = 0;
     endcase
end
    
always@(keycode)
begin  
    case(keycode)
        NUMBERS[0],  NUMBERS[1],  NUMBERS[2],  NUMBERS[3],  
        NUMBERS[4],  NUMBERS[5],  NUMBERS[6],  NUMBERS[7],
        NUMBERS[8],  NUMBERS[9],  NUMBERS[10], NUMBERS[11],
        NUMBERS[12], NUMBERS[13], NUMBERS[14], NUMBERS[15]:
            flags <= 1 << NUMBER_F;
        ENTER_CODE:
            flags <= 1 << ENTER_F;
        BACKSPACE_CODE:
            flags <= 1 << BACKSPACE_F;
        RESET_CODE:
            flags <= 1 << RESET_F;
        default:
            flags <= 0;
    endcase
end         
    
endmodule
