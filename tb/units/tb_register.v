`timescale 1ns/1ps

module reg_file_tb;

    reg clk, reg_write_en;
    reg [3:0] reg_addr_1, reg_addr_2, write_addr;
    reg [31:0] write_data, reg_addr_15;
    wire [31:0] read_data_1, read_data_2;

    initial clk = 0;
    always #5 clk = ~clk;

    reg_file uut(.clk(clk), .reg_write_en(reg_write_en), 
                .reg_addr_1(reg_addr_1),
                .reg_addr_2(reg_addr_2), 
                .write_addr(write_addr), 
                .write_data(write_data), 
                .reg_addr_15(reg_addr_15),
                .read_data_1(read_data_1), 
                .read_data_2(read_data_2));

    initial begin

        $dumpfile("sim/waves/register.vcd");
        $dumpvars(0, reg_file_tb);
        reg_addr_15 = 32'hF;
        write_data = 32'hFC;
        reg_write_en = 0;
        reg_addr_1 = 0; reg_addr_2 = 0; 
        write_addr = 0;

        // read_data_1 = 0, read_data_2 = 0
        #10;
        reg_write_en = 1; write_addr = 0; write_data = 32'h2; #10; // read_data_1 = 0, read_data_2 = 0
        reg_write_en = 1; write_addr = 1;  write_data = 32'hFA; #10;  // read_data_1 = 0, read_data_2 = 0
        reg_write_en = 0; reg_addr_1 = 0; reg_addr_2 = 1; #10; // read_data_1 =  32'hFC, read_data_2 = 32'hFA
        reg_addr_1 = 15;  reg_addr_2 = 0; #10; // read_data_1 =  332'hF, read_data_2 = 32'h2

        $finish;

    end



endmodule