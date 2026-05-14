`timescale 1ns/1ps

module datapath_tb;

    reg clk, reset, pc_src, reg_write_en, reg_src_a, reg_src_b;
    reg [31:0] old_pc;
    wire [31:0] write_data, alu_result;

    datapath dut(
        .clk(clk),
        .reset(reset),
        .pc_src(pc_src),
        .reg_src_a(reg_src_a),
        .reg_src_b(reg_src_b),
        .write_data(write_data),
        .alu_result(alu_result)
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
        #0.1;

        if (dut.pc_next != 32'h40)
            $error("Branch path broken");
        
        @(posedge clk);
        #0.1;
        if (dut.pc_flops.q != 32'h40)
             $error("Branch address broken");
        $display("time=%0t pc= %h", $time, dut.pc_flops.q); //40


        release dut.result;

        $finish;
    end


    // register file and its mux tests

    initial begin

        reg_src_a = 0;
        reg_src_b = 0;
        reg_write_en = 0;

        // temporary register file data
        dut.rf.reg_file[0] = 32'h0;
        dut.rf.reg_file[1] = 32'h1;
        dut.rf.reg_file[6] = 32'h6;
        dut.rf.reg_file[10] = 32'hA;
        dut.rf.reg_file[14] = 32'hE;


        force dut.reg_addr1_mux.data_2 = 6; // reg_address 6 = 6;
        force dut.reg_addr2_mux.data_2 = 10; // reg_adress 10 = 10;
        force dut.reg_addr2_mux.data_1 = 14; // rd for store operation; reg_address 14 = 14;

        #0.1

        if (dut.reg_addr1_mux.out != 6)
            $error("wrong mux address selection for Register addresss 1");
        if (dut.reg_addr2_mux.out != 10)
            $error("wrong mux address selection for Register addresss 2");
        if (dut.src_a != 6)
            $error("Wrong data output from register for address line 1");
        if (dut.write_data != 10)
            $error("Wrong data output from register for address line 2");

        #1;

        reg_src_a = 1;
        reg_src_b = 1;

        #1;

        if (dut.reg_addr1_mux.out != 4'hF)
            $error("wrong mux address selection for Register addresss 1");
        if (dut.reg_addr2_mux.out != 4'hE)
            $error("wrong mux address selection for Register addresss 2");
        if (dut.src_a != dut.plus8_adder.y)
            $error("Wrong data output from register for address line 1");
        if (dut.write_data != 4'hE)
            $error("Wrong data output from register for address line 2");

        
        
       #1;

        // writeback and register write operation

        reg_write_en = 1;
        force dut.result = 6;

        @(posedge clk);
        #0.1;
        if (dut.rf.reg_file[14] != 6)
            $error("Write back fails");
        $display("reg_[14] content is %d", dut.rf.reg_file[14]);
        reg_write_en = 0;

    end

endmodule