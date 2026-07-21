module instr_mem(input [31:0] addr, 
                 output reg [31:0] read_data
                );

    reg [31:0] ROM[0:31];
        initial
            $readmemh("rtl/memory/program.hex", ROM);
           
        always @(*) begin
             read_data = ROM[addr >> 2];
         end
endmodule