module data_mem( input clk, mem_write_en,
                input [31:0] addr, write_data,
                output reg [31:0] read_data
                );

reg [31:0] RAM[31:0];

integer i;

initial begin
    for(i=0;i<32;i=i+1)
        RAM[i] = 32'd0;
end

always @(*) begin
    read_data = RAM[addr >> 2];
end

always @(posedge clk) begin
    if(mem_write_en)
        RAM[addr >> 2] <= write_data;
end

endmodule