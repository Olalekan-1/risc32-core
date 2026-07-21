module trace(input clk, reset, trace_valid, uart_busy, mem_write_en,
              input [31:0] pc, instr, alu_result, write_data, read_data,
              output reg uart_start, 
              output reg [7:0] uart_data
            );


    reg [31:0] trace_pc = 0;
    reg [31:0] trace_instr = 0;
    reg [31:0] trace_alu = 0;
    reg [31:0] trace_data = 0;
    reg [5:0] char_index = 0;
    reg [7:0] next_char = 0;
    wire is_memory;
    wire is_load;
    reg trace_is_memory;
    reg trace_is_load;

    //assign is_memory       = (instr[27:26] == 2'b01);
    //assign is_load         = is_memory && instr[20];

    //assign trace_is_memory = (trace_instr[27:26] == 2'b01);
    //assign trace_is_load   = trace_is_memory && trace_instr[20];

    localparam LAST_CHAR = 63;

    /// convert 4 bit hex to 8 bits ascii value.
    function automatic [7:0] hex_to_ascii(input [3:0] nibble);

        case (nibble)

            4'h0: hex_to_ascii = "0";
            4'h1: hex_to_ascii = "1";
            4'h2: hex_to_ascii = "2";
            4'h3: hex_to_ascii = "3";

            4'h4: hex_to_ascii = "4";
            4'h5: hex_to_ascii = "5";
            4'h6: hex_to_ascii = "6";
            4'h7: hex_to_ascii = "7";

            4'h8: hex_to_ascii = "8";
            4'h9: hex_to_ascii = "9";

            4'hA: hex_to_ascii = "A";
            4'hB: hex_to_ascii = "B";
            4'hC: hex_to_ascii = "C";
            4'hD: hex_to_ascii = "D";
            4'hE: hex_to_ascii = "E";
            4'hF: hex_to_ascii = "F";

            default: hex_to_ascii = "?";

        endcase
    endfunction


    localparam IDLE      = 2'b00;
    localparam SEND_CHAR = 2'b01;
    localparam WAIT_BUSY = 2'b10;
    localparam WAIT_DONE = 2'b11;

    reg [1:0] state = IDLE;


    always @(*) begin

        case(char_index)
            0: next_char = "P";
            1: next_char = "C";
            2: next_char = "=";
            3: next_char = hex_to_ascii(trace_pc[31:28]);
            4: next_char = hex_to_ascii(trace_pc[27:24]);
            5: next_char = hex_to_ascii(trace_pc[23:20]);
            6: next_char = hex_to_ascii(trace_pc[19:16]);
            7: next_char = hex_to_ascii(trace_pc[15:12]);
            8: next_char = hex_to_ascii(trace_pc[11:8]);
            9: next_char = hex_to_ascii(trace_pc[7:4]);
            10: next_char = hex_to_ascii(trace_pc[3:0]);
            11: next_char=" ";

            12: next_char = "I";
            13: next_char = "R";
            14: next_char = "=";
            15: next_char = hex_to_ascii(trace_instr[31:28]);
            16: next_char = hex_to_ascii(trace_instr[27:24]);
            17: next_char = hex_to_ascii(trace_instr[23:20]);
            18: next_char = hex_to_ascii(trace_instr[19:16]);
            19: next_char = hex_to_ascii(trace_instr[15:12]);
            20: next_char = hex_to_ascii(trace_instr[11:8]);
            21: next_char = hex_to_ascii(trace_instr[7:4]);
            22: next_char = hex_to_ascii(trace_instr[3:0]);
            23: next_char = " ";
            24: next_char = "A";
            25: next_char = "L";
            26: next_char = "U";
            27: next_char = "=";
            28: next_char = hex_to_ascii(trace_alu[31:28]);
            29: next_char = hex_to_ascii(trace_alu[27:24]);
            30: next_char = hex_to_ascii(trace_alu[23:20]);
            31: next_char = hex_to_ascii(trace_alu[19:16]);
            32: next_char = hex_to_ascii(trace_alu[15:12]);
            33: next_char = hex_to_ascii(trace_alu[11:8]);
            34: next_char = hex_to_ascii(trace_alu[7:4]);
            35: next_char = hex_to_ascii(trace_alu[3:0]);
            36: next_char = " ";
            37: next_char = trace_is_load ? "L" : "S";
            38: next_char = trace_is_load ? "D" : "T";
            39: next_char = "R";
            40: next_char = " ";
            41: next_char = "[";
            42: next_char = hex_to_ascii(trace_alu[31:28]);
            43: next_char = hex_to_ascii(trace_alu[27:24]);
            44: next_char = hex_to_ascii(trace_alu[23:20]);
            45: next_char = hex_to_ascii(trace_alu[19:16]);
            46: next_char = hex_to_ascii(trace_alu[15:12]);
            47: next_char = hex_to_ascii(trace_alu[11:8]);
            48: next_char = hex_to_ascii(trace_alu[7:4]);
            49: next_char = hex_to_ascii(trace_alu[3:0]);
            50: next_char = "]";
            51: next_char = " ";
            52: next_char = "=";
            53: next_char = " ";
            54: next_char = hex_to_ascii(trace_data[31:28]);
            55: next_char = hex_to_ascii(trace_data[27:24]);
            56: next_char = hex_to_ascii(trace_data[23:20]);
            57: next_char = hex_to_ascii(trace_data[19:16]);
            58: next_char = hex_to_ascii(trace_data[15:12]);
            59: next_char = hex_to_ascii(trace_data[11:8]);
            60: next_char = hex_to_ascii(trace_data[7:4]);
            61: next_char = hex_to_ascii(trace_data[3:0]);
           /* 54: next_char = hex_to_ascii(read_data[31:28]);
            55: next_char = hex_to_ascii(read_data[27:24]);
            56: next_char = hex_to_ascii(read_data[23:20]);
            57: next_char = hex_to_ascii(read_data[19:16]);
            58: next_char = hex_to_ascii(read_data[15:12]);
            59: next_char = hex_to_ascii(read_data[11:8]);
            60: next_char = hex_to_ascii(read_data[7:4]);
            61: next_char = hex_to_ascii(read_data[3:0]);*/
            62: next_char = 8'h0D;
            63: next_char = 8'h0A;

            default: next_char = 8'h00;
        endcase
    end

    always @(posedge clk or posedge reset) begin

        if(reset) begin

            state      <= IDLE;
            uart_start <= 1'b0;
            uart_data  <= 8'd0;

            char_index <= 0;

            trace_pc   <= 0;
            trace_instr<= 0;
            trace_alu  <= 0;
            trace_data <= 0;

        end

    else begin

        case(state)
        IDLE: begin
            uart_start <= 1'b0;
            if(trace_valid) begin
                trace_pc    <= pc;
                trace_instr <= instr;
                trace_alu   <= alu_result;
                trace_is_memory <= (instr[27:26] == 2'b01);

                //trace_is_memory = (trace_instr[27:26] == 2'b01);
                trace_is_load   = (instr[27:26] == 2'b01 && instr[20]);
                if (mem_write_en)
                        trace_data <= write_data;
                else if (trace_is_load)
                        trace_data <= read_data;
                else
                     trace_data <= 32'hFFFFFFFF;
                char_index <= 0;
                state <= SEND_CHAR;
            end

        end
        SEND_CHAR: begin

            uart_data <= next_char;
            uart_start <= 1'b1;
            state <= WAIT_BUSY;

        end
        WAIT_BUSY: begin
            uart_start <= 1'b0;
            if(uart_busy)
                state <= WAIT_DONE;

        end
        WAIT_DONE: begin
            if(!uart_busy) begin                    
                if(char_index == LAST_CHAR)
                    state <= IDLE;
                else begin
                     if(!trace_is_memory && char_index == 35)
                        char_index <= LAST_CHAR - 1; 
                    else
                        char_index <= char_index + 1;
                    state <= SEND_CHAR;
                end
            end
        end
        default:
            state <= IDLE;

        endcase
    end
end
endmodule
