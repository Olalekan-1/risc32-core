module alu(input [31:0] src_a, src_b,
           input [2:0] alu_control,
           output reg zero, negative, overflow, carry,
           output reg[31:0] alu_result
        );


    always @(*) begin
        case(alu_control)
        3'b000: begin
            alu_result = src_a & src_b;
            carry = 0;
            overflow = 0;
        end
        3'b001:begin
           alu_result = src_a | src_b;
           carry = 0;
           overflow = 0; 
        end
        3'b010: begin
            {carry, alu_result} = src_a + src_b;
            overflow = ((src_a[31] == src_b[31]) && (alu_result[31] != src_a[31]));
        end

         3'b011: begin
            {carry, alu_result} = src_a - src_b;
            overflow = ((src_a[31] == src_b[31]) && (alu_result[31] != src_a[31]));
        end
        3'b100:begin
           alu_result = src_a ^ src_b;
           carry = 0;
           overflow = 0; 
        end
        default: begin
            alu_result = 32'b0;
            carry = 0;
            overflow = 0;

        end

        endcase
    end

    assign zero = (alu_result == 0);
    assign negative = alu_result[31];


endmodule