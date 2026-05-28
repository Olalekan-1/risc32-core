`timescale 1ns/1ps

module datapath_tb;

    reg clk, reset, pc_src, reg_write_en, reg_src_a, reg_src_b;
    reg [31:0] old_pc;
    wire [31:0] write_data, alu_result;

    datapath dut(
        .clk(clk),
        .reset(reset),
        .pc_src(pc_src)
    );


    // clock and reset
    initial begin
            clk = 0;
            reset = 1;
            #1;
            reset = 0;
        end

    // clock generator
    always #1 clk = ~clk;
    
    /* simulate and test program counter related logic */
    initial begin
        pc_src = 0;
        $dumpfile("sim/waves/datapath.vcd");
        $dumpvars(0, datapath_tb);
        
        // force branch target
        force dut.result = 32'h40;

        @(posedge clk);
        #0.1;

        $display("time=%0t pc_next = %h", $time, dut.pc_next); // h8
        if (dut.pc_next != 32'h8)
            $error("pc_plus4 broken");
        $display("time=%0t pc = %h", $time, dut.pc_flops.q); // 04
        old_pc = dut.pc_flops.q;

        @(posedge clk);
         #0.1;
        if (dut.pc_flops.q != old_pc + 4) //pc = 8
            $error("pc_plus4 broken");
        $display("time=%0t pc= %h", $time, dut.pc_flops.q); //8

        // branch path

        pc_src = 1;
        @(posedge clk);
        
        if (dut.pc_next != 32'h40)
            $error("time= %0t Branch path broken", $time);
    
        
        @(posedge clk);
        #0.1;
        if (dut.pc_flops.q != 32'h40)
             $error("Branch address broken");
        $display("time=%0t pc= %h", $time, dut.pc_flops.q); //40


        release dut.result;

       $finish;

    end

endmodule