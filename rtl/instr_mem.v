module instr_mem(input [31:0] addr, 
                 output reg [31:0] read_data
                );

    reg [31:0] ROM[31:0];
        initial
            $readmemh("file.dat", ROM);
            assign read_data = ROM[addr[31:2]];


endmodule