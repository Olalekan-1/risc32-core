module cpu(input clk, reset,
            output reg mem_write_en,
            input [31:0] instr, read_data, 
            output reg [31:0] write_data, write_addr, pc
            );


    wire reg_write_en, pc_src, reg_src_a, reg_src_b, mem_to_reg, alu_src;
    wire [3:0] alu_flags;
    wire [1:0] imm_src;
    wire [2:0] alu_control;


    controller controller_i(.clk(clk), .reset(reset), .instr(instr[[31:12]]), .alu_flags(alu_flags),
                            .reg_write_en(reg_write_en), .mem_write_en(mem_write_en), .pc_src(pc_src),
                            .reg_src_a(reg_src_a), reg_src_b(reg_src_b), mem_to_reg(mem_to_reg),
                            .alu_src(alu_src), .alu_control(alu_control), .imm_src(imm_src)
                            );


    datapath datapath_i(.clk(clk), .reset(reset),.reg_write_en(reg_write_en), .mem_write_en(mem_write_en), 
                        .pc_src(pc_src), .reg_src_a(reg_src_a), reg_src_b(reg_src_b), mem_to_reg(mem_to_reg),
                        .alu_src(alu_src), .alu_control(alu_control), .imm_src(imm_src), .write_data(write_data),
                        .alu_result(write_addr), .pc(pc), .read_data(read_data), .instr(instr)
                        );


endmodule