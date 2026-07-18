module trace(input clk, reset, trace_valid, uart_busy, mem_write_en,
              input [31:0] pc, instr, alu_result, write_data,
              output reg uart_start, 
              output reg [7:0] uart_data
            );


    reg [31:0] trace_pc = 0;
    reg [31:0] trace_instr = 0;
    reg [31:0] trace_alu = 0;
    reg [31:0] trace_data = 0;
    reg [5:0] char_index = 0;
    reg [7:0] next_char = 0;

    localparam LAST_CHAR = 55;

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
            //11: next_char = 8'h0D;
            //12: next_char = 8'h0A;
            12: next_char=" ";

            13: next_char = "I";
            14: next_char = "R";
            15: next_char = "=";
            16: next_char = hex_to_ascii(trace_instr[31:28]);
            17: next_char = hex_to_ascii(trace_instr[27:24]);
            18: next_char = hex_to_ascii(trace_instr[23:20]);
            19: next_char = hex_to_ascii(trace_instr[19:16]);
            20: next_char = hex_to_ascii(trace_instr[15:12]);
            21: next_char = hex_to_ascii(trace_instr[11:8]);
            22: next_char = hex_to_ascii(trace_instr[7:4]);
            23: next_char = hex_to_ascii(trace_instr[3:0]);
            24: next_char = " ";
            25: next_char = "A";
            26: next_char = "L";
            27: next_char = "U";
            28: next_char = "=";
            29: next_char = hex_to_ascii(trace_alu[31:28]);
            30: next_char = hex_to_ascii(trace_alu[27:24]);
            31: next_char = hex_to_ascii(trace_alu[23:20]);
            32: next_char = hex_to_ascii(trace_alu[15:12]);
            33: next_char = hex_to_ascii(trace_alu[11:8]);
            34: next_char = hex_to_ascii(trace_alu[7:4]);
            35: next_char = hex_to_ascii(trace_alu[3:0]);
            36: next_char = " ";
            37: next_char = "A";
            38: next_char = "D";
            39: next_char = "D";
            40: next_char = "R";
            41: next_char = "=";
            42: next_char = hex_to_ascii(trace_alu[31:28]);
            43: next_char = hex_to_ascii(trace_alu[27:24]);
            44: next_char = hex_to_ascii(trace_alu[23:20]);
            45: next_char = hex_to_ascii(trace_alu[15:12]);
            46: next_char = hex_to_ascii(trace_alu[11:8]);
            47: next_char = hex_to_ascii(trace_alu[7:4]);
            48: next_char = hex_to_ascii(trace_alu[3:0]);
            49: next_char = " ";
            50: next_char = "D";
            51: next_char = "A";
            52: next_char = "T";
            53: next_char = "A";


            54: next_char = 8'h0D;
            55: next_char = 8'h0A;

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
                trace_data  <= write_data;
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
