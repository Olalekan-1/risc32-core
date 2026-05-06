`timescale 1ns/1ps

module alu_tb;

    reg [31:0] src_a, src_b;
    reg [2:0] alu_control;
    wire zero, negative, overflow, carry;
    wire [31:0] alu_result;

    alu uut(.src_a(src_a), .src_b(src_b), 
            .alu_control(alu_control),
            .zero(zero), 
            .negative(negative), 
            .overflow(overflow), 
            .carry(carry),
            .alu_result(alu_result)
            );

    initial begin

        $dumpfile("sim/waves/alu.vcd");
        $dumpvars(0, alu_tb);

        src_a = 32'h7FFFFFFF;
        src_b = 32'h7FFFFFFF;

        alu_control = 3'b000; #10; // alu_result = 7FFF FFFF; carry = 0, negative = 0, overflow = 0, zero = 0;
        alu_control = 3'b001; #10;  // alu_result = 7FFF FFFF; carry = 0, negative = 0, overflow = 0, zero = 0;
        alu_control = 3'b010; #10; // alu result = FFFF FFFE; carry = 0, negative = 1, overflow = 1, zero = 0;
        alu_control = 3'b011; #10; // alu_result = 0; carry = 0, negative = 0, zero = 1;
        alu_control = 3'b100; #10;  // alu_result = 0; carry = 0, negative = 0, zero = 1;

        src_a = 32'hFFFFFFFE; src_b = 32'hFFFFFFFE;

        alu_control = 3'b010; #10;  // alu_result = 1 FFFF FFFC, carry = 1, overflow = 0; negative = 1;
        //alu_control = 3'b011; #10;

        src_a = 32'h7FFFFFFF; src_b = 32'hFFFFFFFE;
        alu_control = 3'b011; #10; // alu_result = 80000001, overflow = 1, negative = 1; carry = 0;

        $finish;

    end

endmodule