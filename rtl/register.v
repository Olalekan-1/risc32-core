module reg_file(input clk, write_en, 
                input[3:0] reg_addr_1, reg_addr_2, write_addr,
                input[31:0] write_data,
                output [31:0] read_data_1, read_data_2
                );

    reg [31:0] reg_file[15:0];

    always @(posedge clk)
        if (write_en) reg_file[write_addr] <= write_data;
        
        
    assign read_data_1 = (reg_addr_1 == 4'b1111) ? reg_addr_15 : reg_file[reg_addr_1];
    assign read_data_2 = (reg_addr_2 == 4'b1111) ? reg_addr_15 : reg_file[reg_addr_2];





endmodule