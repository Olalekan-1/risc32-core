module top(clk, reset), ;


    wire mem_write_en;
    wire [31:0] instr, pc, read_data, write_data, write_addr;

 
    // integrate CPU
    cpu cpu_i(.clk(clk), .reset(reset), .mem_write_en(mem_write_en), .instr(instr), .read_data(read_data)
                .write_data(write_data), .write_addr(write_addr), .pc(pc)
                );

    // integrate instruction memory
    instr_mem instr_mem_i(.addr(pc), .read_data(instr));

    // integrate data memory
    data_mem data_mem_i(.clk(clk), .mem_write_en(mem_write_en), .addr(write_addr),
                        .write_data(write_data), .read_data(read_data)
                        ); 

endmodule