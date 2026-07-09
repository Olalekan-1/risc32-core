`timescale 1ns/1ps

module instr_mem_tb;

    logic [31:0] addr, read_data;


    instr_mem uut(.addr(addr),
                   .read_data(read_data));

    initial begin

        $dumpfile("sim/waves/instr_mem.vcd");
        $dumpvars(0,  instr_mem_tb);

        for (int i = 0; i < 32; i++) begin
            addr = i << 2;  
            #1;

            assert(read_data === uut.ROM[i])
                $display("PASS addr=%h data=%h",
                        addr, read_data);
            else
                $error("Mismatch at address %h", addr);
        end
end

endmodule