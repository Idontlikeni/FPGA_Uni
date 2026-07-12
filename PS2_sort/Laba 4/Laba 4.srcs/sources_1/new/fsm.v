module fsm#(max_size = 16, bit_size = 16)
(
    input [bit_size-1:0] n,
    input [bit_size-1:0] dataIn, // не забудь поменять здесь на 4 бита если надо
    input R_I,
    input reset,
    input clk, 
    output reg [bit_size * max_size - 1: 0] dataOut,
    output reg R_O
    );
    
localparam S0 = 4'b0000, S1 = 4'b0001, S2 = 4'b0010, S3 = 4'b0011, S4 = 4'b0100, S5 = 4'b0101, S6 = 4'b0110, S7 = 4'b0111, S8 = 4'b1000, S9 = 4'b1001;

// S0 - reset/start
// S1 - DataIn - N
// S2 - DataIn - array[N]
// S3 - Sort
// S4 - Print

// reg [bit_size-1:0] n; //  размер массива, след. вывод данных.
reg [bit_size-1:0] arr [0:max_size-1]; // Массив

reg [bit_size * max_size - 1:0] flattered_arr; // Норм массив блэать.

reg [3:0] state; // состояния

reg [bit_size - 1:0] counter; // счетчик индекса массива

integer i;
integer j;
integer k;
integer g;

reg [bit_size - 1:0] it1;
reg [bit_size - 1:0] it2;

reg [bit_size - 1:0] result [0:max_size - 1]; // массив для хранения временных отсортированных данных.

reg [1:0] z;

reg [bit_size * max_size - 1: 0] packed;

reg loop_flag;

//reg [bit_size - 1:0] l;
//reg [bit_size - 1:0] m;
//reg [bit_size - 1:0] r;

reg [bit_size - 1:0] left;
reg [bit_size - 1:0] mid;
reg [bit_size - 1:0] right;
initial
begin
    loop_flag <= 0;
    state <= S0;
    // n <= 0;
    it1 <= 0;
    it2 <= 0;
    counter <= 0;
    packed <= 0;
    R_O <= 0;
//    l <= 0;
//    m <= 0;
//    r <= 0;
    
    left <= 0;
    mid <= 0;
    right <= 0;
    for(i = 0; i < max_size; i = i + 1)begin
        arr[i] <= 0;
        result[i] <= 0;
    end
end

//function [1:0] merge (input reg [bit_size - 1:0] left, input reg [bit_size - 1:0] mid, input reg [bit_size - 1:0] right);
//    begin
//        $display("left = %0h, mid = %0h, RIGHT = %0h, it1 = %0h, it2 = %0h", left, mid, right, it1, it2);
//        while((left + it1 < mid) && (mid + it2 < right))begin
//            if(arr[left + it1] < arr[mid + it2])begin
//                result[it1 + it2] = arr[left + it1];
//                it1 = it1 + 1;
//            end
//            else begin
//                result[it1 + it2] = arr[mid + it2];
//                it2 = it2 + 1;
//            end
//        end
        
//        while(left + it1 < mid)begin
//            result[it1 + it2] = arr[left + it1];
//            it1 = it1 + 1;
//        end
    
//        while(mid + it2 < right)begin
//            result[it1 + it2] = arr[mid + it2];
//            it2 = it2 + 1;
//        end
        
//        for(g = 0; g < it1 + it2; g = g + 1)begin 
//            arr[left + g] = result[g];
//        end
//    end
//endfunction 

always@(posedge clk)
begin
    if(reset)begin
//        it1 <= 0;
//        it2 <= 0;
//        counter <= 0;
//        R_O <= 0;
//        dataOut <= 0;
//        for(i = 0; i < max_size; i = i + 1)begin
//            arr[i] = 0;
//            result[i] = 0;
//        end
        state <= S0;
    end
    else
    case(state)
        S0:
        begin
            // n <= 0;
            it1 <= 0;
            it2 <= 0;
            counter <= 0;
            R_O <= 0;
            dataOut <= 0;
            loop_flag <= 0;
            for(i = 0; i < max_size; i = i + 1)begin
                arr[i] = 0;
                result[i] = 0;
            end
            state <= S2;
        end
//        S1: // ввод n
//        begin
//            if(R_I)begin
//                n <= dataIn;
//                state <= S2;
//            end
//        end
        S2: // ввод массива
        begin
            if(R_I) begin
                arr[counter] <= dataIn;
                counter <= counter + 1;
            end
            if(counter == n)begin
                state <= S3;
                i <= 1;
            end
        end // сортировка
        
        S3: begin
            if(i < n)begin
                j <= 0;
                state <= S4;
            end else state <= S9;
        end
        
        S4:begin
            if(j < n - i)begin
//                l = j;
//                m = j + i;
//                if(j + 2 * i < n)
//                    r = j + 2 * i;
//                else 
//                    r = n;
                    
                left <= j;
                mid <= j + i;
                if(j + 2 * i < n)
                    right <= j + 2 * i;
                else 
                    right <= n;
                it1 <= 0;
                it2 <= 0;
                //z <= merge(l, m, r);
                $display(" i = %0h, j = %0h", i, j);
                j <= j + 2 * i;
                //state <= S4;
                state <= S5; 
            end else begin
                state <= S3;
                i <= i * 2;
            end
        end
        
        S5: begin
            if((left + it1 < mid) && (mid + it2 < right))begin
                if(arr[left + it1] < arr[mid + it2])begin
                    result[it1 + it2] = arr[left + it1];
                    it1 = it1 + 1;
                end
                else begin
                    result[it1 + it2] = arr[mid + it2];
                    it2 = it2 + 1;
                end
                state <= S5;
            end else
                state <= S6;
        end
        
        S6:begin
            if(left + it1 < mid)begin
                result[it1 + it2] = arr[left + it1];
                it1 = it1 + 1;
                state <= S6;
            end else state <= S7;
            
//            while(left + it1 < mid)begin
//                result[it1 + it2] = arr[left + it1];
//                it1 = it1 + 1;
//            end
        end
        
        S7:begin           
//            while(mid + it2 < right)begin
//                result[it1 + it2] = arr[mid + it2];
//                it2 = it2 + 1;
//            end
            if(mid + it2 < right)begin
                result[it1 + it2] = arr[mid + it2];
                it2 = it2 + 1;
                state <= S7;
            end else state <= S8;
        end
        
        S8:begin
            for(g = 0; g < it1 + it2; g = g + 1)begin 
                arr[left + g] = result[g];
            end
            state <= S4;
        end
//        S3: begin
//            //state <= S0;
//            for(i = 1; i < n; i = i * 2)begin 
//                for(j = 0; j < n - i; j = j + 2 * i)begin
//                    // $display("i: %d, j: %d", i, j);
//                    if(j + 2 * i < n)
//                        z = merge(j, j + i, j + 2 * i);
//                    else
//                        z = merge(j, j + i, n);
//                    it1 = 0;
//                    it2 = 0;
////                    for(k = 0; k < max_size; k = k + 1)begin
////                        result[k] = 0;
////                    end
//                end
//            end
//            counter <= 0;
//            state <= S6;
//        end
        S9: begin
            R_O <= 1'b1;
            for (i = 0; i < max_size; i = i + 1) begin
                packed[i*bit_size +: bit_size] = arr[n - 1 - i];  // "+:" - part-select
            end
            dataOut <= packed;
            //state <= S0;
        end
    endcase
end
endmodule