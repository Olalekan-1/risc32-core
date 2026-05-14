module data_mem(input clk, mem_write_en, 
                input [31:0] addr, write_data,
                output reg [31:0] read_data
                );

    reg [31:0] RAM[31:0];

    always @(*) begin
        assign read_data = RAM[addr[31:2]];
    end
    

    always @(posedge clk) begin
        if (mem_write_en) 
             RAM[addr[31:2]] <= write_data;
    end


endmodule