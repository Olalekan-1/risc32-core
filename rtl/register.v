module reg_file(input clk, reg_write_en, 
                input[3:0] reg_addr_1, reg_addr_2, write_addr,
                input[31:0] write_data, reg_addr_15,
                output [31:0] read_data_1, read_data_2
                );

    reg [31:0] reg_file[14:0];
    

    always @(posedge clk) begin
        if (reg_write_en) 
            reg_file[write_addr] <= write_data;
    end
            
    assign read_data_1 = (reg_addr_1 == 4'b1111) ? reg_addr_15 : reg_file[reg_addr_1];
    assign read_data_2 = (reg_addr_2 == 4'b1111) ? reg_addr_15 : reg_file[reg_addr_2];

endmodule