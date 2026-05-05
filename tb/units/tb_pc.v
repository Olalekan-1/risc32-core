`timescale 1ns/1ps

module pc_tb;

reg clk, reset, en;
reg [31:0] data;
wire [31:0] q;

pc uut(.clk(clk), .reset(reset), .en(en), .data(data), .q(q));

    initial begin
    clk = 0;
    end

    always #5 clk = ~clk;

    // reset 
    initial begin
    reset = 1;
    #10;
    reset = 0;
    end


    initial begin

        $dumpfile("sim/waves/pc.vcd");
        $dumpvars(0, pc_tb);

        en  = 0;
        data  = 0;

        #10;
        en = 1; data = 32'hFFFFFFF6; #10;
        en = 0; data = 32'hFFFFFFF7; #10;
        reset = 1; #10;
        reset = 0;
        en = 0; data = 9; #10;
        en = 1; #10;


        $finish;
    end

endmodule