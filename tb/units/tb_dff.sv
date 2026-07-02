`timescale 1ns/1ps

module dff_tb;

    logic clk, reset, en;
    logic d, q;

    localparam CLK_PERIOD = 1;


    dff uut(.clk(clk), .reset(reset), .en(en), .d(d), .q(q));

    initial begin
        clk = 0;
        forever #CLK_PERIOD clk = ~clk;
    end


    task initialize;
        begin
            reset = 0;
            d = 0;
            en = 0;
        end
    endtask

    task drive(input logic en_i,
            input logic data);

        begin

            @(negedge clk);
            en = en_i;
            d = data;
        end
    endtask

    task check(input logic expected);
        begin
             @(posedge clk);
            if (q !== expected)
                $error("Expected=%0b Got=%0b", expected, q);
            else
                $display("[%0t] PASS", $time);
        end
    endtask



    initial begin
        $dumpfile("sim/waves/dff.vcd");
        $dumpvars(0, dff_tb);
       
        initialize();

        // Reset
        reset = 1;
        repeat(2) @(posedge clk);
        reset = 0;

        
        drive(1, 1);
        @(posedge clk);
        check(1);

        // enable signal off
        drive(0, 0);
        @(posedge clk);
        check(1);

        // enable signal on
        drive(1, 0);
        @(posedge clk);
        check(0);

        $finish;

    end


endmodule