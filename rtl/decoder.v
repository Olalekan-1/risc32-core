module decoder(input [1:0] op,
                    input [5:0] funct,
                    input [3:0] rd,
                    output reg [3:0] flag_en,
                    output reg [2:0] alu_control,
                    output reg [1:0] imm_src,
                    output reg pc_s, reg_src_a, reg_src_b, mem_to_reg, alu_src,
                    output reg reg_write, mem_write,

                    );

    reg alu_op, branch;
    reg [9:0] contr_sigs;


// main decoder
    always @(*) begin
        case(op)
            2'b00: if (funct[0]) contr_sigs = 10'b0001100010;
                    else contr_sigs = 10'b0000100010;
            2'01: if (funct[0]) = contr_sigs = 10'b0001010110;
                    else contr_sigs = 10'b0101000101;
            2'b11: contr_sigs = 10'b1011011000;
            default: contr_sigs = 10'b0;
        endcase
    
        assign {reg_src_a, reg_src_b, branch, alu_src, alu_op, mem_to_reg, imm_src, reg_write, mem_write} = contr_sigs;
    end



// Alu decoder
    always @(*) begin
        if (alu_op) begin
            case(funct[4:1])
                4'b0000: alu_control = 3'b000;
                4'b0001: alu_control = 3'b001;
                4'b0010: alu_control = 3'b010;
                4'b0011: alu_control = 3'b011;
                4'b0100: alu_control = 3'b100;
                default: alu_control = 3'b0;
            endcase
            flag_en[0] = funct[0] & (alu_control == 3'b010 | alu_control == 3'b011);
            flag_en[1] = funct[0] & (alu_control == 3'b010 | alu_control == 3'b011);
            flag_en[2] = funct[0];
            flag_en[3] = funct[0];
        end

        else begin
            alu_control = 3'b010;
            flag_en = 4'b0;
        end
    end


    assign pc_s = ((rd == 4'b1111) & reg_write) | branch;


endmodule