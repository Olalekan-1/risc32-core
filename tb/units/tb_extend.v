`timescale 1ns/1ps

module extend_tb;

reg [1:0] imm_src;
reg [23:0] instr;
wire [31:0] ext_imm;

extend uut(.instr(instr), .imm_src(imm_src), .ext_imm(ext_imm));

initial begin
    $dumpfile("sim/waves/extend.vcd");
    $dumpvars(0, extend_tb);

    instr = 2'b01; imm_src = 2'b11; #10; // ext_imm = 0
    instr = 8'h04; imm_src = 2'b00; #10; // ext_imm = 00000004
    instr = 12'h00C; imm_src = 2'b01; #10; // ext_imm = 0000000c
    instr = 24'h18; imm_src = 2'b10; #10; // ext_imm = 00000060
    imm_src = 2'b11; #10; // ext_imm = 0

    $finish;
end

endmodule