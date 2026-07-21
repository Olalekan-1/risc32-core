module top(input clk, button, step_en,
            output tx);

    wire reset, pc_en, button_pulse_1, button_pulse_2;

    assign reset = ~button;
    assign pc_en = ~step_en;

    wire mem_write_en;
    wire [31:0] instr, pc, read_data, write_data, alu_result;
    wire tx_busy;
    wire tx_start;
    wire [7:0] tx_data;

    //reg trace_valid_d;


    // button controller
    
    button_controller #( .CLK_FREQ(12000000), 
                         .DEBOUNCE_MS(10)
                         ) button_i (.clk(clk), 
                         .button(reset), 
                         .button_pulse(button_pulse_1)
                         );

    button_controller #( .CLK_FREQ(12000000), 
                         .DEBOUNCE_MS(10)
                         ) button_u (.clk(clk), 
                         .button(pc_en), 
                         .button_pulse(button_pulse_2)
                         );
        
      //  always @(posedge clk) begin
      //  trace_valid_d <= button_pulse_2;
    //end



    // processor system
    processor_system processor(.clk(clk),
                                .reset(button_pulse_1),
                                .pc_en(button_pulse_2),
                                .instr(instr),
                                .mem_write_en(mem_write_en),
                                .pc(pc),
                                .read_data(read_data),
                                .write_data(write_data),
                                .alu_result(alu_result)
                                );

    // integrate  pc trace
    trace trace_i(.clk(clk), 
                    .reset(button_pulse_1),
                    .trace_valid(button_pulse_2),
                    .pc(pc),
                    .instr(instr),
                    .alu_result(alu_result),
                    .mem_write_en(mem_write_en),
                    .write_data(write_data),
                    .read_data(read_data),
                    .uart_busy(tx_busy),
                    .uart_start(tx_start),
                    .uart_data(tx_data)
                    );


    uart_tx #(.CLK_FREQ(12000000),
            .BAUD_RATE(9600)) uart_i(.clk(clk),
                .tx_start(tx_start),
                .tx_data(tx_data),
                .tx_busy(tx_busy),
                .tx(tx)
    );


endmodule