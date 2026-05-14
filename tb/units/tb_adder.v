
`timescale 1ns/1ps

module adder_tb;

    reg [31:0] a, b;
    wire [31:0] y;

    adder uut(.a(a), .b(b), .y(y));

    initial begin
        $dumpfile("sim/waves/adder.vcd");
        $dumpvars(0, adder_tb);
        
        a = 0; b = 0; #10; // y = 0
        a = 10; b = 5; #10; // y = 15
        a = 100; b = 200; #10; //y = 300
        a = 20; b = 4; #10; // y = 24
        a = -5; b = 3; #10;   // y = 5
        a = 32'hFFFFFFFF; b = 32'h00000001; #10; // 00000000

        $finish;

        
    end

endmodule