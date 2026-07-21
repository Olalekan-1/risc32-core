module processor_system(input clk, reset, pc_en,
            output mem_write_en,
            output [31:0] instr, pc,
            output [31:0] read_data, write_data, alu_result);

 
    // integrate CPU
    cpu cpu_i(.clk(clk), .reset(reset), .mem_write_en(mem_write_en), .instr(instr), .read_data(read_data),
                .write_data(write_data), .alu_result(alu_result), .pc(pc), .pc_en(pc_en));

    // integrate instruction memory
    instr_mem instr_mem_i(.addr(pc), .read_data(instr));

    // integrate data memory
    data_mem data_mem_i(.clk(clk), .mem_write_en(mem_write_en), .addr(alu_result),
                        .write_data(write_data), .read_data(read_data)
                        ); 
endmodule