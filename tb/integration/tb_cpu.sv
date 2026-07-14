`timescale 1ns/1ps

module cpu_tb;

    logic clk, reset, mem_write_en;
    logic [31:0] instr, read_data, write_data, result, pc;

    localparam CLK_PERIOD = 1;
     localparam TESTS_NO = 10;

    typedef struct packed {

        logic mem_write_en;
        logic [31:0] write_data; 
        logic [31:0] result;
        logic [31:0] pc;
    } outputs;
    
    outputs expected;
    


    cpu dut(.clk(clk),
            .reset(reset),
            .mem_write_en(mem_write_en),
            .instr(instr),
            .pc(pc),
            .write_addr(result),
            .write_data(write_data)
            );

    initial begin
                clk = 0;
                forever #CLK_PERIOD clk = ~clk;
    end

    // Reset Dut
    task automatic reset_dut;
        begin

            instr = 0;
            read_data = 0;
            reset = 1;
            @(posedge clk);
            reset = 0;

        end
    endtask

     // Driver - Apply inputs
    task automatic drive(input logic [31:0] instr_i,
                          input logic [31:0]  read_data_i);
        begin

            @(negedge clk);
            instr = instr_i;
            read_data = read_data_i;
        end
    endtask

    // checker
    task automatic check_outputs(input outputs out);

        begin

            @(posedge clk)
            assert ((out.pc === pc)) // program counter // 
                $display("[%0t] PASS", $time);
            else
                 $error("Expected pc=%0h Got=%0h", out.pc, pc);

            assert ((out.mem_write_en === mem_write_en)) // mem_write_en // 
                $display("[%0t] PASS", $time);
            else
                 $error("Expected mem_write_en=%0h Got=%0h", out.mem_write_en, mem_write_en);

            assert ((out.result === result)) //re
                $display("[%0t] PASS", $time);
            else
                 $error("Expected result=%0h Got=%0h", out.result, result); 

            assert ((out.write_data === write_data)) // write_data
                $display("[%0t] PASS", $time);
            else
                 $error("Expected write_data=%0h Got=%0h", out.write_data , write_data);
        end
    endtask


     // Test instruction cases 

    logic [31:0] instructions [TESTS_NO];
    logic [31:0] data [TESTS_NO];

    initial begin
        instructions[0] = 32'hE2A00019; // MOVI R0, #25;
        data[0] = 32'h0;
        instructions[1] = 32'hE2401005; // ADDI R1, #5  ; R1 = 30
        data[1] = 32'h0;
        instructions[2] = 32'hE0502001; // ADDS R2, R0 R1 ; R2 = 55
        data[2] = 32'h0;
        instructions[3] = 32'hE272304D;  // SUBIS R3, R2 #77; R3 = -22   
        data[3] = 32'h0;
        instructions[4] = 32'h42534016;  // ADDISNE R4, R3 #22 ; R4 = 0  
        data[4] = 32'h0;
        instructions[5] = 32'h00545000;  // ADDEQ R5, R4 R0 ; R5 = 25
        data[5] = 32'h0;
        instructions[6] = 32'hE0146005; // AND R6, R4 R5 ; R6 = 0
        data[6] = 32'h0; 


    end

// Reference model
    function automatic outputs ref_model(input logic [31:0] instr);

        outputs out;
        case(instr)

            32'hE2A00019: begin
                out.mem_write_en = 1'b0;
                out.pc = 32'h4;
                out.write_data = 32'hx;
                out.result = 32'h19;
            end 

            32'hE2401005: begin
                out.mem_write_en = 1'b0;
                out.pc = 32'h8;
                out.write_data = 32'hx;
                out.result = 32'h1E;
            end

            32'hE0502001: begin
                out.mem_write_en = 1'b0;
                out.pc = 32'hC;
                out.write_data = 32'h1E;
                out.result = 32'h37;
            end

            32'hE272304D: begin
                out.mem_write_en = 1'b0;
                out.pc = 32'h10;
                out.write_data = 32'hx;
                out.result = 32'hFFFFFFEA;
            end

            32'h42534016: begin
                out.mem_write_en = 1'b0;
                out.pc = 32'h14;
                out.write_data = 32'hx;
                out.result = 32'h0;
            end

            32'h00545000: begin
                out.mem_write_en = 1'b0;
                out.pc = 32'h18;
                out.write_data = 32'h19;
                out.result = 32'h19;
            end

            32'hE0146005: begin
                out.mem_write_en = 1'b0;
                out.pc = 32'h1C;
                out.write_data = 32'h19;
                out.result = 32'h0;
            end
        default: out = '0;
        endcase
    return out;

    endfunction

     initial begin

        $dumpfile("sim/waves/cpu.vcd");
        $dumpvars(0,  cpu_tb);

        reset_dut();
        $display("pc_content=%0h", pc);

        for (int i = 0; i < 7; i++)
        begin
            //$display("alu_srca=%0d... alu_srcb=%0d ... alu_result=%0d", dut.datapath_i.src_a, dut.datapath_i.src_b, dut.datapath_i.result);
            //$display("flags [ZNCV] = %0b%0b%0b%0b", dut.controller_i.cond_logic.z_ff.q, dut.controller_i.cond_logic.n_ff.q, dut.controller_i.cond_logic.c_ff.q, dut.controller_i.cond_logic.v_ff.q);
           //$display("reg_write_en = %0b", dut.reg_write_en);
            drive( instructions[i],  data[i]);
            $display("instruction code=%0h", instr);
            expected = ref_model(instructions[i]);
            check_outputs(expected);
        end

       //for(int i= 0; i < 5; i++)
        // $display("content of destination register[%0d]=%0d", i, dut.datapath_i.rf.reg_file[i]);


        $display("DONE");
        $finish;
    end

    
         

endmodule
