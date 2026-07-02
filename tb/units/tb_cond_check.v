`timescale 1ns/1ps

module cond_check_tb;

    reg [3:0] cond;
    reg Z, N, C, V, expected;
    wire cond_ex;
    integer inc;

    cond_check uut(.cond(cond),
                    .Z(Z),
                    .N(N),
                    .C(C),
                    .V(V),
                    .cond_ex(cond_ex)
                    );

    function ref_model;
        input [3:0] cond;
        input Z, N, C, V;

        begin
            case(cond)
                4'b0000: ref_model = Z;
                4'b0001: ref_model = ~Z;
                4'b0010: ref_model = C;
                4'b0011: ref_model = ~C;
                4'b0100: ref_model = N;
                4'b0101: ref_model = ~N;
                4'b0110: ref_model = V;
                4'b0111: ref_model = ~V;
                4'b1000: ref_model = C & ~Z;
                4'b1001: ref_model = C | ~Z;
                4'b1010: ref_model = (N == V);
                4'b1011: ref_model = (N != V);
                4'b1100: ref_model = ~Z & (N == V);
                4'b1101: ref_model = Z | (N != V);
                4'b1110: ref_model = 1'b1;
                default: ref_model = 1'b0;
            endcase
        end
    endfunction



    initial begin
        $dumpfile("sim/waves/cond_check.vcd");
        $dumpvars(0, cond_check_tb);

        for (inc = 0; inc < 16; inc = inc + 1) begin

            V = inc[0];
            C = inc[1];
            N = inc[2];
            Z = inc[3];
            cond = inc;

            expected = ref_model(cond, Z, N, C, V);
            #1;

            if (cond_ex !== expected) begin
                    $display("FAIL cond=%b Z=%b N=%b C=%b V=%b expected=%b got=%b",
                             cond,Z,N,C,V,
                             expected,cond_ex);
                end
         end
        
        $display("DONE");
        $finish;
    end


endmodule