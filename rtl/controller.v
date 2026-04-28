module controller(input clk, reset, 
                  input [31:12] instr,
                  input [3:0] alu_flags,
                  output reg reg_write_en, mem_write_en, pc_src, reg_src_a, reg_src_b, mem_to_reg, alu_src,
                  output [2:0] alu_control, 
                  output [1:0] imm_src
                );

    wire [3:0] flag_w;
    wire mem_write, reg_write, pc_s;

   decoder decoder_i(.op(instr[27:0]), .funct(instr[25:20]), .rd([15:12]),
                      .flag_en(flag_w), .alu_control(alu_control), .imm_src(imm_src)
                      .pc_s(pc_s), .reg_src_a(reg_src_a), .reg_src_b(reg_src_b),
                      .mem_to_reg(mem_to_reg), .alu_src(alu_src), .reg_write(reg_write)
                      .mem_write(mem_write)
                      );


   cond_decoder cond_logic(.clk(clk), .reset(reset), .pc_s(pc_s), .reg_write(reg_write),
                            .mem_write(mem_write), .cond(instr[31:28]), .alu_flags(alu_flags),
                            .flag_w(flag_w), .pc_src(pc_src), .reg_write_en(reg_write_en), .mem_write_en(mem_write_en)
                            );

endmodule