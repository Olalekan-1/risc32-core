`timescale 1ns/1ps

module mux_tb;
    
    reg [31:0] a, b;
    reg sel;
    wire [31:0] y;

    mux2 #(.WIDTH(32)) uut(.data_1(a), .data_2(b), .sel(sel), .out(y));

    initial begin
        $dumpfile("sim/waves/mux.vcd");
        $dumpvars(0, mux_tb);

        a = 32'hFFFFFFF3; b = 32'hFFFFFFF4; 
        
        sel = 0; #10;
        sel = 1; #10;
        sel = 0; #10;

        $finish;
    end
endmodule