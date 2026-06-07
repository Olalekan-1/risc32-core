`timescale 1ns/1ps

module decoder_tb;


    logic [5:0] funct;
    logic [1:0] op;
    logic [3:0] rd;
    logic pc_s, reg_src_a, reg_src_b, mem_to_reg, alu_src, reg_write, mem_write;
    logic [1:0] imm_src;
    logic [2:0] alu_control;
    logic [3:0] flag_en;

    decoder uut(.op(op),
                .funct(funct),
                .rd(rd),
                .pc_s(pc_s),
                .reg_src_a(reg_src_a),
                .reg_src_b(reg_src_b),
                .mem_to_reg(mem_to_reg),
                .alu_src(alu_src),
                .reg_write(reg_write),
                .mem_write(mem_write),
                .imm_src(imm_src),
                .alu_control(alu_control),
                .flag_en(flag_en)
                );


    initial begin
        $dumpfile("sim/waves/decoder.vcd");
        $dumpvars(0, decoder_tb);

        op = 2'b00;
        funct = 0;
        #1;
        assert (!reg_src_a && !reg_src_b && !uut.branch && !alu_src && 
                uut.alu_op && !mem_to_reg && reg_write && !mem_write)
            $display("expected control signal for data processing operation (register)");
        else
            $error("invalid control output");

        assert ({reg_src_a, reg_src_b, uut.branch, alu_src, uut.alu_op,
                mem_to_reg, imm_src, reg_write, mem_write} ==  10'b0000100010)
            $display("expected control signal for data processing operation (register)");
        else
            $error("invalid control output");
        $display("control output for register data processing = %b", uut.contr_sigs);


        #1;
        // immediate data processing operation
        funct = 6'b100000;
        #0.1;
        assert (!reg_src_a && !reg_src_b && !uut.branch && alu_src && uut.alu_op && 
                !mem_to_reg && (imm_src == 2'b00) && reg_write && !mem_write)
            $display("expected control signal for data processing operation (immediate)");
        else
            $error("invalid data processing (immediate) control output");

        assert ({reg_src_a, reg_src_b, uut.branch, alu_src, uut.alu_op,
                mem_to_reg, imm_src, reg_write, mem_write} ==  10'b0001100010)
            $display("expected control signal for data processing operation (immediate)");
        else
            $error("invalid data processing (immediate) control output");
         $display("control output for immediate data processing = %b", uut.contr_sigs);

        #1;
         // memory operation
        op = 2'b01;
        funct = 0;
        #0.1;

        assert (!reg_src_a && reg_src_b && !uut.branch && alu_src && !uut.alu_op && 
                !mem_to_reg && (imm_src == 2'b01) && !reg_write && mem_write)
            $display("expected control signal for 'store' memory operation");
        else
            $error("invalid store operation control output");
        $display("control output for 'store' memory operation = %b", uut.contr_sigs);

        #1;
        funct = 1;
        #0.1;

         assert (!reg_src_a && !reg_src_b && !uut.branch && alu_src && !uut.alu_op && 
                mem_to_reg && (imm_src == 2'b01) && reg_write && !mem_write)
            $display("expected control signal for 'load' memory operation");
        else
            $error("invalid load operation control output");
        $display("control output for 'load' memory operation = %b", uut.contr_sigs);

        #1;

        // branch operation
        op = 2'b10;
        #0.1;

        assert (reg_src_a && !reg_src_b && uut.branch && alu_src && !uut.alu_op && 
                mem_to_reg && (imm_src == 2'b10) && !reg_write && !mem_write)
            $display("expected control signal for branch operation");
        else
            $error("invalid branch operation control output");
        $display("control output for branch operation = %b", uut.contr_sigs);



        // alu control and set flags
        #1;
        force uut.alu_op = 0;
        #0.1;

        assert ((alu_control == 3'b010) && (flag_en == 4'b0))
            $display("expected alu operation verified");
        else
            $error("unexpected alu operation");
            

        
        #1;
        force uut.alu_op = 1;
        funct = 6'b000101;
        op = 2'b00; //  flag_en = 4'b111
        
        #0.1;
        assert ((flag_en == 4'b1111) && (alu_control == 3'b010))
            $display("ALU operation and status flag set verified");
        else
            $error("worng ALU operation and unexpected flags set");

        #1;
        funct = 6'b000001; // AND Operation flag_en = 4'b1100
        
        #0.1;
        assert ((flag_en == 4'b1100) && (alu_control == 3'b000))
            $display("ALU operation and status flag set verified");
        else
            $error("worng ALU operation and unexpected flags set");

            #1;

        funct = 6'b000011; // OR Operation  flag_en = 4'b1100
        
        #0.1;
        assert ((flag_en == 4'b1100) && (alu_control == 3'b001))
            $display("ALU operation and status flag set verified");
        else
            $error("worng ALU operation and unexpected flags set");

        #1;

        funct = 6'b000111; // SUB Operation  flag_en = 4'b1111
            
        #0.1;
        assert ((flag_en == 4'b1111) && (alu_control == 3'b011))
            $display("ALU operation and status flag set verified");
        else
            $error("worng ALU operation and unexpected flags set");

        #1;

        funct = 6'b001001; // SUB Operation  flag_en = 4'b1111

        #0.1;
        assert ((flag_en == 4'b1100) && (alu_control == 3'b100))
            $display("ALU operation and status flag set verified");
        else
            $error("worng ALU operation and unexpected flags set");

        release uut.alu_op;


        #1;
        // branch operation control
        rd = 4'b1110;
        force uut.branch = 0;

        #0.1;
        assert (!pc_s)
            $display("expected program counter mux selector value");
        else
            $error("wrong pc sel value");
            
        #1;


        rd = 4'b1111;
        op = 2'b00;
        #0.1;
        assert (pc_s)
            $display("correct program counter mux selector value!");
        else
            $error("wrong pc sel value");

         #1;

        force uut.branch = 0;

        #0.1;
        assert (pc_s)
            $display("correct program counter mux selector value!");
        else
            $error("wrong pc sel value");

        #1;

        force uut.branch = 0;
        rd = 4'b1111;

        #0.1;
        assert (pc_s)
            $display("correct program counter mux selector value!");
        else
            $error("wrong pc sel value");



        $finish;
        
    end

endmodule