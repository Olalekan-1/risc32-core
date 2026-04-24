module datapath(input clk, reset, reg_write_en, mem_write_en, pc_src, reg_src_a, reg_src_b, mem_to_reg, alu_src,
                input [2:0] alu_control, 
                input [1:0] imm_src,
                output reg  [3:0] alu_flags
                output reg [31:0] write_data, alu_result, pc,
                input [31:0] read_data, instr,
                );


    wire [3:0] reg_addr_1, reg_addr_2;
    wire [31:0] pc_next, pc_plus4, pc_plus8;
    wire [31:0] ext_imm, src_a, src_b, result;

    // program counter logic
    mux2 #(32) pc_mux(.data_1(result), .data_2(pc_plus4), .sel(pc_src), .out(pc_next));
    pc pc_flops(.clk(clk), .reset(reset), .data(pc_next), .q(pc));
    adder plus4_adder(.a(pc), .b(32'b100), .y(pc_plus4));
    adder plus8_adder(.a(pc_plus4), .b(32'b100), .y(pc_plus8));


    // register file logc
    mux2 #(4) reg_addr1_mux(.data_1(4'b1111), .data_2(instr[19:16]), .sel(reg_src_a), .out(reg_addr_1));
    mux2 #(4) reg_addr2_mux(.data_1(instr[15:12]), .data_2(instr[3:0]), .sel(reg_src_b), .out(reg_addr_2));
    reg_file rf(.clk(clk), .reg_write_en(reg_write_en), .reg_addr_1(reg_addr_1), .reg_addr_2(reg_addr_2), .write_addr(instr[15:12]),
                .write_data(result), .reg_addr_15(pc_plus8), .read_data_1(src_a), .read_data_2(write_data));
    mux2 #(32) write_back_mux(.data_1(read_data), .data_2(alu_result), .sel(mem_to_reg), .out(result));



    // alu logic
    extend ext(.instr(instr[23:0]), .imm_src(imm_src), .ext_imm(ext_imm));
    mux2 #(32) alu_src_b(.data_1(ext_imm), .data_2(write_data), .sel(alu_src), .out(src_b));
    alu alu_i(.src_a(src_a), .src_b(src_b), .alu_control(alu_control), .zero(alu_flags[3]),
                .negative(alu_flags[2]), .overflow(alu_flags[1]), .carry(alu_flags[0]), .alu_result(alu_result));

endmodule