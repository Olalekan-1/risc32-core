module cond_decoder(input clk, reset, pc_s, reg_write, mem_write,
                    input [3:0] cond, alu_flags, flag_w,
                    output reg pc_src, reg_write_en, mem_write_en
                    );


    wire [3:0] flags;
    wire [3:0] flag_en;
    reg cond_ex;

    dff z_ff(.clk(clk), .reset(reset), .en(flag_en[3]), .d(alu_flags[3]), .q(flags[3]));
    dff n_ff(.clk(clk), .reset(reset), .en(flag_en[2]), .d(alu_flags[2]), .q(flags[2]));
    dff c_ff(.clk(clk), .reset(reset), .en(flag_en[1]), .d(alu_flags[1]), .q(flags[1]));
    dff v_ff(.clk(clk), .reset(reset), .en(flag_en[0]), .d(alu_flags[0]), .q(flags[0]));

    assign mem_write_en = cond_ex & mem_write;
    assign reg_write_en = cond_ex & reg_write;
    assign pc_src = cond_ex & pc_s;
    assign flag_en = flag_w & (4{cond_ex});

    cond_check cond_check_i (
        .cond(cond),
        .Z(flags[3]),
        .N(flags[2]),
        .C(flags[1]),
        .V(flags[0]),
        .cond_ex(cond_ex)
    );

endmodule




module cond_check(input [3:0] cond,
                  input Z, N, C, V
                  output reg cond_ex
                );

    always @(*)begin
        case(cond)
            4'b0000: cond_ex = Z;
            4'b0001: cond_ex = ~Z;
            4'b0010: cond_ex = C;
            4'b0011: cond_ex = ~C;
            4'b0100: cond_ex = N;
            4'b0101: cond_ex = ~N;
            4'b0110: cond_ex = V;
            4'b0111: cond_ex = ~V;
            4'b1000: cond_ex = C & ~Z;
            4'b1001: cond_ex = C | ~Z;
            4'b1010: cond_ex = (N == V);
            4'b1011: cond_ex = (N != V);
            4'b1100: cond_ex = ~Z & (N == V);
            4'b1101: cond_ex = Z | (N != V);
            4'b1110: cond_ex = 1'b1;
            default: cond_ex = 1'b0;
        endcase
    end


endmodule


module dff(
    input clk,
    input reset,
    input en,
    input d,
    output reg q
);

    always @(posedge clk or posedge reset) begin
        if (reset)
            q <= 1'b0;
        else if (en)
            q <= d;
    end

endmodule