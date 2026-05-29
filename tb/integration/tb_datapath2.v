`timescale 1ns/1ps

module datapath_tb;

    reg clk, reset, pc_src, reg_write_en, reg_src_a, reg_src_b, mem_to_reg;
    reg [31:0] instr;
    wire [31:0] write_data, alu_result;

    datapath dut(
        .clk(clk),
        .reset(reset),
        .pc_src(pc_src),
        .reg_src_a(reg_src_a),
        .reg_src_b(reg_src_b),
        .write_data(write_data),
        .alu_result(alu_result),
        .reg_write_en(reg_write_en),
        .mem_to_reg(mem_to_reg),
        .instr(instr)
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

    /* simulate and test register files and its related logic */
    
    
    initial begin

        $dumpfile("sim/waves/datapath2.vcd");
        $dumpvars(0, datapath_tb);
        $display("Time = %0t", $time);

        reg_src_a = 0;
        reg_src_b = 0;
        reg_write_en = 0;
        pc_src = 0;

        // temporary register file data
        dut.rf.reg_file[0] = 32'h0;
        dut.rf.reg_file[1] = 32'h1;
        dut.rf.reg_file[6] = 32'h6;
        dut.rf.reg_file[10] = 32'hA;
        dut.rf.reg_file[14] = 32'hE;


        instr = 32'h0006E00A; // Rs = 6, Rm = 10, Rd = 14
        
        #0.1
        $display("Time = %0t", $time);

        if (dut.reg_addr1_mux.out != 6) begin
             $error("wrong mux address selection for Register addresss 1");
             $display("The adresss RA1 is %d", dut.reg_addr1_mux.out);
        end
        
        if (dut.reg_addr2_mux.out != 10)
            $error("wrong mux address selection for Register addresss 2");
        if (dut.src_a != 6)
            $error("Wrong data output from register for address line 1");
        if (dut.write_data != 10)
            $error("Wrong data output from register for address line 2");


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

        $display("The value of plus_8 register is %d at time = %0t", dut.plus8_adder.y, $time); // time = 1000, plus_8 = 12;

        
        
       #1;

        // writeback and register write operation

        reg_write_en = 1;
        instr = 32'h0000E000; // sets bits [15:12] = 14
        force dut.write_back_mux.data_1 = 6;
        force dut.write_back_mux.data_2 = 7;

        mem_to_reg = 1;

        @(posedge clk);

        #0.1;
        $display("The value of plus_8 register is %d at time = %0t", dut.plus8_adder.y, $time); // time = 3000, plus_8 = 16;
        if (dut.rf.reg_file[14] != 6)
            $error("Write back fails");
        $display("reg_[14] content is %d", dut.rf.reg_file[14]);
        //reg_write_en = 0;


        instr = 32'h0000A000; // sets bits [15:12] = 10. Rd = #10;
        mem_to_reg = 0;
        @(posedge clk);
        
        #0.1;

        if (dut.rf.reg_file[10] != 7)
            $error("Write back fails");
        $display("reg_[10] content is %d", dut.rf.reg_file[10]);
        reg_write_en = 0;

        release dut.write_back_mux.data_1;
        release dut.write_back_mux.data_2;


        $finish;

    end

endmodule