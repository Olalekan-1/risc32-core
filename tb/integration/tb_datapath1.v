`timescale 1ns/1ps

module datapath_tb;

    reg clk, reset, pc_src, reg_write_en, reg_src_a, reg_src_b, alu_src;
    reg [2:0] alu_control;
    reg [31:0] instr;
    reg [1:0] imm_src;
    wire [3:0] alu_flags;
    wire [31:0] alu_result;

    datapath dut(
        .clk(clk),
        .reset(reset),
        .pc_src(pc_src),
        .reg_src_a(reg_src_a),
        .reg_src_b(reg_src_b),
        .alu_src(alu_src),
        .imm_src(imm_src),
        .alu_flags(alu_flags),
        .alu_control(alu_control),
        .instr(instr),
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

    /* simulate and test Alu and its related logic */
    
      initial begin

        $dumpfile("sim/waves/datapath1.vcd");
        $dumpvars(0, datapath_tb);

        pc_src = 0;

        
        // temporary register file data
        dut.rf.reg_file[0] = 32'h0;
        dut.rf.reg_file[1] = 32'h1;
        dut.rf.reg_file[6] = 32'h6;
        dut.rf.reg_file[10] = 32'hA;
        dut.rf.reg_file[14] = 32'hE;


        // data processing opertaion
        instr = 32'h0006E00A; // Rs = 6, Rm = 10, Rd = 14
        alu_src = 0;
        reg_src_a = 0;
        reg_src_b = 0;
        alu_control = 3'b000;

        #0.1;
        if (alu_result != 32'h2) begin
            $error("wrong alu operation and result");
            $display("alu_result = %d", alu_result);
        end
        $display("alu_result = %d", alu_result);
        
        #1;
        alu_control = 3'b001;
        #0.1;
        if (alu_result != 32'hE) begin
            $error("wrong alu operation and result");
            $display("alu_result = %d", alu_result);
        end
        $display("alu_result = %h", alu_result);

        #1;

        // data processing, immediate operation

        instr = 32'h0006E0FF; // Rs = 6, Rm = 255, Rd = 14
        alu_src = 1;
        imm_src = 2'b00;
        alu_control = 3'b010;

        #0.1;

         if (alu_result != 32'h105) begin
            $error("wrong alu operation and result");
            $display("alu_result = %h", alu_result);
        end
        $display("alu_result = %h", alu_result);

        #1;

        /* mmory instruction */

        instr = 32'h0006EEFF;       // Rs = 6, Rm = EFF(3823), Rd = 14; 
        alu_src = 1;
        imm_src = 2'b01;
        alu_control = 3'b010;

         #0.1;

         if (alu_result != 32'hF05) begin
            $error("wrong alu operation and result");
            $display("alu_result = %h", alu_result);
        end
        $display("alu_result = %h", alu_result); // F05 (3845)

        #1;

        /* branch operartion instruction */

        instr = 32'h000000FF;       //branch to instruction no. 255
        reg_src_a = 1; // R15 = 16;
        alu_src = 1;
        imm_src = 2'b10;
        alu_control = 3'b010;

         #0.1;

         if (alu_result != 32'h40C) begin
            $error("wrong alu operation and result");
            $display("alu_result = %h", alu_result); // 40C (1036)
        end
        $display("alu_result = %h", alu_result); //  40C (1036)

         #1;


        $finish;

      end


endmodule