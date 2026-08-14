`timescale 1ns/1ps

module processor_system_tb;

    logic clk, reset, mem_write_en, pc_en;
    logic [31:0] instr, read_data, write_data, result, pc;

    localparam CLK_PERIOD = 1;

    processor_system processor(.clk(clk),
                                .reset(reset),
                                .mem_write_en(mem_write_en),
                                .pc_en(pc_en),
                                .instr(instr),
                                .read_data(read_data),
                                .write_data(write_data),
                                .alu_result(result),
                                .pc(pc)
                                ); 

    initial begin
                clk = 0;
                forever #CLK_PERIOD clk = ~clk;
    end


    // Reset system
    task automatic reset_system;
        begin
            reset = 1;
            pc_en = 0;
            repeat(2) @(posedge clk);
            reset = 0;
            pc_en = 1;
        end
    endtask

    // Test sequence
    initial begin
        
        // waveform
        $dumpfile("sim/waves/processor_system.vcd");
        $dumpvars(0, processor_system_tb);
        reset_system();
        repeat (12) @(posedge clk);

        $finish;

    end


    // Monitor processor execution
    always @(posedge clk) begin

        $display("PC=%h  IR=%h  ALU=%h  MEM_WR=%b  WDATA=%h  RDATA=%h",
                 pc,
                 instr,
                 result,
                 mem_write_en,
                 write_data,
                 read_data);

    end

endmodule