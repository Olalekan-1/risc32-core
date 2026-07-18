module instr_mem(input [31:0] addr, 
                 output reg [31:0] read_data
                );

    reg [31:0] ROM[0:31];
        initial
            $readmemh("sim/files/file.dat", ROM);
           
        always @(*) begin
             read_data = ROM[addr >> 2];
         end
endmodule