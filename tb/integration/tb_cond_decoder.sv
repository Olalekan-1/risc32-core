`timescale 1ns/1ps

module cond_decoder_tb;

    logic clk, reset, pc_s, reg_write, mem_write;
    logic [3:0] cond, alu_flags, flag_w, flags;
    logic pc_src, reg_write_en, mem_write_en, cond_ex;

    localparam CLK_PERIOD = 1;

    typedef struct packed {
        logic exp_pc_src;
        logic exp_reg_write_en; 
        logic exp_mem_write_en;
    } outputs_t;

    outputs_t expected;


    cond_decoder dut(.clk(clk),
                      .reset(reset),
                      .pc_s(pc_s),
                      .reg_write(reg_write),
                      .mem_write(mem_write),
                      .cond(cond),
                      .alu_flags(alu_flags),
                      .flag_w(flag_w),
                      .pc_src(pc_src),
                      .reg_write_en(reg_write_en),
                      .mem_write_en(mem_write_en)
                        );


    initial begin
        clk = 0;
        forever #CLK_PERIOD clk = ~clk;
    end

    task automatic reset_dut;
        begin
    
            reset = 1;
            pc_s = 0;
            reg_write = 0;
            mem_write = 0; 
            cond = 0;
            alu_flags = 0; 
            flag_w = 0;
            flags = 0;
            repeat(2) @(posedge clk);
            reset = 0;

        end
    endtask
    
    task automatic drive(input logic pc_s_i, reg_write_i, mem_write_i,
                          input logic [3:0] cond_i, alu_flags_i, flag_w_i);
        begin
            @(negedge clk);
            pc_s =  pc_s_i;
            reg_write = reg_write_i;
            mem_write =  mem_write_i; 
            cond = cond_i;
            alu_flags = alu_flags_i; 
            flag_w = flag_w_i;
        end
    endtask

    task automatic check_outputs(input outputs_t outputs);

        begin
            @(posedge clk)
            assert ((outputs.exp_pc_src ==  pc_src)) // program counter source
                $display("[%0t] PASS", $time);
            else
                 $error("Expected pc_src=%0b Got=%0b", outputs.exp_pc_src, pc_src);
            
            assert ((outputs.exp_reg_write_en ==  reg_write_en)) // register write 
                $display("[%0t] PASS", $time);
            else
                 $error("Expected reg_write=%0b Got=%0b", outputs.exp_reg_write_en, reg_write_en);

            assert ((outputs.exp_mem_write_en ==  mem_write_en)) // memory write
                $display("[%0t] PASS", $time);
            else
                 $error("Expected mem_write=%0b Got=%0b", outputs.exp_mem_write_en , mem_write_en);

        end

    endtask

    function automatic outputs_t ref_model(input logic cond_ex);

        logic exp_pc_src, exp_reg_write_en, exp_mem_write_en;
        //logic [3:0] flags;
        //logic [3:0] flag_en;
        //logic cond_ex;
        outputs_t outputs;


        exp_mem_write_en = cond_ex & mem_write;
        exp_reg_write_en = cond_ex & reg_write;
        exp_pc_src = cond_ex & pc_s;

        //assign flag_en = (flag_w) & {4{cond_ex}};

         outputs.exp_pc_src       = exp_pc_src;
         outputs.exp_reg_write_en = exp_reg_write_en;
         outputs.exp_mem_write_en = exp_mem_write_en;


        return outputs;
            
    endfunction

     function automatic logic cond_check(input logic [3:0] cond,
                                            input logic Z, N, C, V
                                            );
        

        begin
            case(cond)
                4'b0000: cond_check = Z;
                4'b0001: cond_check = ~Z;
                4'b0010: cond_check = C;
                4'b0011: cond_check = ~C;
                4'b0100: cond_check = N;
                4'b0101: cond_check = ~N;
                4'b0110: cond_check = V;
                4'b0111: cond_check = ~V;
                4'b1000: cond_check = C & ~Z;
                4'b1001: cond_check = C | ~Z;
                4'b1010: cond_check = (N == V);
                4'b1011: cond_check = (N != V);
                4'b1100: cond_check = ~Z & (N == V);
                4'b1101: cond_check = Z | (N != V);
                4'b1110: cond_check = 1'b1;
                default: cond_check = 1'b0;
            endcase
        end
    endfunction

    initial begin

        $dumpfile("sim/waves/cond_decoder.vcd");
        $dumpvars(0, cond_decoder_tb);

        reset_dut();
        for (int cond_i = 0; cond_i < 16; cond_i++)
        for (int alu_flags_i = 0; alu_flags_i < 16; alu_flags_i++)
        for (int flag_w_i = 0; flag_w_i < 16; flag_w_i++)
        for (int pc_s_i = 0; pc_s_i < 2; pc_s_i++)
        for (int reg_write_i = 0; reg_write_i < 2; reg_write_i++)
        for (int mem_write_i = 0; mem_write_i < 2; mem_write_i++)

        begin

            drive(pc_s_i, reg_write_i, mem_write_i, cond_i, alu_flags_i, flag_w_i);


            cond_ex = cond_check(cond,
            (flags[3]),
            (flags[2]),
            (flags[1]),
            (flags[0])
            );
        
            @(posedge clk);
             if (reset)
                flags <= '0;
            else begin
                for (int i = 0; i < 4; i++) begin
                    if ((flag_w[i] && cond_ex))
                         flags[i] <= alu_flags[i];
                end
            end


            expected = ref_model(cond_ex);
            check_outputs(expected);
        end


        $display("DONE");
        $finish;
    end

endmodule