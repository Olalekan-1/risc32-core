module extend(input [23:0] instr, 
              input [1:0] imm_src,
              output reg [31:0] ext_imm
            );

  always @(*) begin
    case(imm_src)
      2'b00: ext_imm = {24'b0, instr[7:0]}; // immediate operation (data processing)
      2'b01: ext_imm = {20'b0, instr[11:0]}; // memory operation
      2'b10: ext_imm = {{8{instr[23]}}, instr[23:0]} << 2; // branch operation
      default: ext_imm = 32'b0;
    endcase
  end

endmodule