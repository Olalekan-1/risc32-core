`timescale 1ns/1ps

module controller_tb;

    logic clk, reset;
    logic [3:0] alu_flags;
    logic [31:12] instr;
    logic [2:0] alu_control;
    logic [1:0] imm_src;
    logic reg_write_en, mem_write_en, pc_src, reg_src_a, reg_src_b, mem_to_reg, alu_src;

    localparam CLK_PERIOD = 1;
    localparam TESTS_NO = 11;

    /// Expected control transaction
    typedef struct packed {
        logic reg_write_en, mem_write_en, pc_src;
        logic reg_src_a, reg_src_b, mem_to_reg, alu_src;
        logic [2:0] alu_control;
        logic [1:0] imm_src;
    } control_signals;

    typedef struct packed{

        logic [31:12] instr;
        logic [3:0] alu_flags;

    } test_case;

    control_signals expected;



    controller dut(.clk(clk),
                    .reset(reset),
                    .instr(instr),
                    .alu_flags(alu_flags),
                    .alu_control(alu_control),
                    .imm_src(imm_src),
                    .reg_write_en(reg_write_en),
                    .mem_write_en(mem_write_en),
                    .pc_src(pc_src),
                    .reg_src_a(reg_src_a),
                    .reg_src_b(reg_src_b),
                    .mem_to_reg(mem_to_reg),
                    .alu_src(alu_src)
                    );

    initial begin
            clk = 0;
            forever #CLK_PERIOD clk = ~clk;
        end


    // Reset Dut
    task automatic reset_dut;
        begin

            instr = 0;
            alu_flags = 0;
            reset = 1;
            repeat(2) @(posedge clk);
            reset = 0;

        end
    endtask

    // Driver - Apply inputs
    task automatic drive(input logic [31:12] instr_i,
                          input logic [3:0]  alu_flags_i);
        begin

            @(negedge clk);
            instr = instr_i;
            alu_flags = alu_flags_i;
        end
    endtask

    // checker
    task automatic check_outputs(input control_signals control_sigs);

        begin

            @(posedge clk)
            assert ((control_sigs.pc_src ==  pc_src)) // program counter source // 
                $display("[%0t] PASS", $time);
            else
                 $error("Expected pc_src=%0b Got=%0b", control_sigs.pc_src, pc_src);
            
            assert ((control_sigs.reg_write_en ==  reg_write_en)) 
                $display("[%0t] PASS", $time);
            else
                 $error("Expected reg_write_en=%0b Got=%0b", control_sigs.reg_write_en, reg_write_en);

            assert ((control_sigs.mem_write_en ==  mem_write_en)) 
                $display("[%0t] PASS", $time);
            else
                 $error("Expected mem_write_en=%0b Got=%0b", control_sigs.mem_write_en, mem_write_en);

             assert ((control_sigs.reg_src_a ==  reg_src_a)) 
                $display("[%0t] PASS", $time);
            else
                 $error("Expected reg_src_a=%0b Got=%0b", control_sigs.reg_src_a, reg_src_a);

             assert ((control_sigs.reg_src_b ==  reg_src_b)) 
                $display("[%0t] PASS", $time);
            else
                 $error("Expected reg_src_b=%0b Got=%0b", control_sigs.reg_src_b, reg_src_b);

             assert ((control_sigs.mem_to_reg ==  mem_to_reg)) 
                $display("[%0t] PASS", $time);
            else
                 $error("Expected mem_write_en=%0b Got=%0b", control_sigs.mem_to_reg, mem_to_reg);
            
            assert ((control_sigs.alu_src ==  alu_src)) 
                $display("[%0t] PASS", $time);
            else
                 $error("Expected alu_src=%0b Got=%0b", control_sigs.alu_src, alu_src);

            assert ((control_sigs.imm_src ==  imm_src)) 
                $display("[%0t] PASS", $time);
            else
                 $error("Expected imm_src=%0b Got=%0b", control_sigs.imm_src, imm_src);

            assert ((control_sigs.alu_control ==  alu_control)) 
                $display("[%0t] PASS", $time);
            else
                 $error("Expected alu_control=%0b Got=%0b", control_sigs.alu_control,  alu_control);

        end
    endtask
    
    
    // Test instruction cases 

        logic [31:12] instructions [TESTS_NO];
        logic [3:0] flags [TESTS_NO];
         
    initial begin

        instructions[0] = 20'b11100000010000000000; // ADD 
        flags[0] = 4'b0000;

        instructions[1] = 20'b11100000010100000000; // ADDS
        flags[1] = 4'b0001;

        instructions[2] = 20'b00000000010000000000; // ADDEQ
        flags[2] = 4'b0000;

        instructions[3] = 20'b00000000010100000000; // ADDSEQ
        flags[3] = 4'b1000;

        instructions[4] = 20'b11100010010100000000; // ADDIS
        flags[4] = 4'b0000;

        instructions[5] = 20'b00010000011100000000; // SUBSNEQ
        flags[5] = 4'b0111;

        instructions[6] = 20'b00100010000100000000; //ANDISC
        flags[6] = 4'b0000;

        instructions[7] = 20'b11100100000000000000; // STR
        flags[7] = 4'b0000;

        instructions[8] = 20'b11100100010100000000; // LDR
        flags[8] = 4'b0000;

        instructions[9] = 20'b11101000000000000000; // Branch
        flags[9] = 4'b0000;

        instructions[10] = 20'b11100000000000001111; // Branch (rd = 1111, reg_write =1)
        flags[10] = 4'b0000;


    end

    // Reference model
    function automatic control_signals ref_model(input logic [31:12] instr);

        control_signals control_sigs;
        begin
            case(instr)

                20'b11100000010000000000: begin  // ADD
                    control_sigs.alu_control = 3'b010;
                    control_sigs.alu_src = 1'b0;
                    control_sigs.imm_src = 2'b00;
                    control_sigs.mem_to_reg = 1'b0;
                    control_sigs.mem_write_en = 1'b0;
                    control_sigs.pc_src = 1'b0;
                    control_sigs.reg_src_a = 1'b0;
                    control_sigs.reg_src_b = 1'b0;
                    control_sigs.reg_write_en = 1'b1;
                end
                20'b11100000010100000000: begin // ADDS
                    control_sigs.alu_control = 3'b010;
                    control_sigs.alu_src = 1'b0;
                    control_sigs.imm_src = 2'b00;
                    control_sigs.mem_to_reg = 1'b0;
                    control_sigs.mem_write_en = 1'b0;
                    control_sigs.pc_src = 1'b0;
                    control_sigs.reg_src_a = 1'b0;
                    control_sigs.reg_src_b = 1'b0;
                    control_sigs.reg_write_en = 1'b1;
                end
               20'b00000000010000000000: begin // ADDEQ
                    control_sigs.alu_control = 3'b010;
                    control_sigs.alu_src = 1'b0;
                    control_sigs.imm_src = 2'b00;
                    control_sigs.mem_to_reg = 1'b0;
                    control_sigs.mem_write_en = 1'b0;
                    control_sigs.pc_src = 1'b0;
                    control_sigs.reg_src_a = 1'b0;
                    control_sigs.reg_src_b = 1'b0;
                    control_sigs.reg_write_en = 1'b0;
                end
                20'b00000000010100000000: begin // ADDSEQ
                    control_sigs.alu_control = 3'b010;
                    control_sigs.alu_src = 1'b0;
                    control_sigs.imm_src = 2'b00;
                    control_sigs.mem_to_reg = 1'b0;
                    control_sigs.mem_write_en = 1'b0;
                    control_sigs.pc_src = 1'b0;
                    control_sigs.reg_src_a = 1'b0;
                    control_sigs.reg_src_b = 1'b0;
                    control_sigs.reg_write_en = 1'b0;
                end
                20'b11100010010100000000: begin // ADDIS
                    control_sigs.alu_control = 3'b010;
                    control_sigs.alu_src = 1'b1;
                    control_sigs.imm_src = 2'b00;
                    control_sigs.mem_to_reg = 1'b0;
                    control_sigs.mem_write_en = 1'b0;
                    control_sigs.pc_src = 1'b0;
                    control_sigs.reg_src_a = 1'b0;
                    control_sigs.reg_src_b = 1'b0;
                    control_sigs.reg_write_en = 1'b1;
                end
                 20'b00010000011100000000: begin // SUBSNEQ
                    control_sigs.alu_control = 3'b011;
                    control_sigs.alu_src = 1'b0;
                    control_sigs.imm_src = 2'b00;
                    control_sigs.mem_to_reg = 1'b0;
                    control_sigs.mem_write_en = 1'b0;
                    control_sigs.pc_src = 1'b0;
                    control_sigs.reg_src_a = 1'b0;
                    control_sigs.reg_src_b = 1'b0;
                    control_sigs.reg_write_en = 1'b1;
                end
                20'b00100010000100000000: begin // ANDISC
                    control_sigs.alu_control = 3'b000;
                    control_sigs.alu_src = 1'b1;
                    control_sigs.imm_src = 2'b00;
                    control_sigs.mem_to_reg = 1'b0;
                    control_sigs.mem_write_en = 1'b0;
                    control_sigs.pc_src = 1'b0;
                    control_sigs.reg_src_a = 1'b0;
                    control_sigs.reg_src_b = 1'b0;
                    control_sigs.reg_write_en = 1'b1;
                end
                20'b11100100000000000000: begin // STR
                    control_sigs.alu_control = 3'b010;
                    control_sigs.alu_src = 1'b1;
                    control_sigs.imm_src = 2'b01;
                    control_sigs.mem_to_reg = 1'b0;
                    control_sigs.mem_write_en = 1'b1;
                    control_sigs.pc_src = 1'b0;
                    control_sigs.reg_src_a = 1'b0;
                    control_sigs.reg_src_b = 1'b1;
                    control_sigs.reg_write_en = 1'b0;
                end
                 20'b11100100010100000000: begin // LDR
                    control_sigs.alu_control = 3'b010;
                    control_sigs.alu_src = 1'b1;
                    control_sigs.imm_src = 2'b01;
                    control_sigs.mem_to_reg = 1'b1;
                    control_sigs.mem_write_en = 1'b0;
                    control_sigs.pc_src = 1'b0;
                    control_sigs.reg_src_a = 1'b0;
                    control_sigs.reg_src_b = 1'b0;
                    control_sigs.reg_write_en = 1'b1;
                end
                20'b11101000000000000000: begin // Branch
                    control_sigs.alu_control = 3'b010;
                    control_sigs.alu_src = 1'b1;
                    control_sigs.imm_src = 2'b10;
                    control_sigs.mem_to_reg = 1'b0;
                    control_sigs.mem_write_en = 1'b0;
                    control_sigs.pc_src = 1'b1;
                    control_sigs.reg_src_a = 1'b1;
                    control_sigs.reg_src_b = 1'b0;
                    control_sigs.reg_write_en = 1'b0;
                end
                20'b11100000000000001111: begin // Branch (rd = 1111, reg_write = 1)
                    control_sigs.alu_control = 3'b000;
                    control_sigs.alu_src = 1'b0;
                    control_sigs.imm_src = 2'b00;
                    control_sigs.mem_to_reg = 1'b0;
                    control_sigs.mem_write_en = 1'b0;
                    control_sigs.pc_src = 1'b1;
                    control_sigs.reg_src_a = 1'b0;
                    control_sigs.reg_src_b = 1'b0;
                    control_sigs.reg_write_en = 1'b1;
                end
                default: control_sigs = '0;
            endcase
        end

    return control_sigs;
        
    endfunction

    initial begin

        $dumpfile("sim/waves/controller.vcd");
        $dumpvars(0, controller_tb);

         reset_dut();

         for (int i = 0; i < 10; i++)
         begin
            drive( instructions[i],  flags[i]);
            $display("instruction code=%0b", instr);
            @(posedge clk);
          // expected
             expected = ref_model(instructions[i]);
            check_outputs(expected);
         end
        
        // implicit branch
        force dut.reg_write_en = 1;
        drive(instructions[10],  flags[10]);
        $display("instruction code=%0b", instr);
        @(posedge clk);
            expected = ref_model(instructions[10]);
        check_outputs(expected);
        release dut.reg_write_en;

          
        $display("DONE");
        $finish;
    end


endmodule
