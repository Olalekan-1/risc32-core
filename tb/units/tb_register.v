`timescale 1ns/1ps

module reg_file_tb;

    reg clk, reg_write_en;
    reg [3:0] reg_addr_1, reg_addr_2, write_addr;
    reg [31:0] write_data, reg_addr_15;
    wire [31:0] read_data_1, read_data_2;

    initial clk = 0;
    always #1 clk = ~clk;

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

        @(posedge clk); reg_write_en = 1; write_addr = 0; write_data = 32'h2; #2; // read_data_1 = 0, read_data_2 = 0
        @(posedge clk); reg_write_en = 1; write_addr = 1;  write_data = 32'hFA; #2;  // read_data_1 = 0, read_data_2 = 0
        @(posedge clk); reg_write_en = 0; reg_addr_1 = 0; reg_addr_2 = 1; #2; // read_data_1 =  32'hFC, read_data_2 = 32'hFA
        reg_addr_1 = 15;  reg_addr_2 = 0; #2; // read_data_1 =  32'hF, read_data_2 = 32'h2

       //reg_addr_1 = 4'h3; reg_addr_2 = 4'hE;

        uut.reg_file[0] = 32'h7;
        uut.reg_file[1] = 32'h5;
        uut.reg_file[3] = 32'hC;
        uut.reg_file[14] = 32'hE;
        
        reg_addr_1 = 4'b0011; reg_addr_2 = 4'b1110;
        #2;
        
        $display("RA1 is %d", reg_addr_1);
        $display("RA2 is %d", reg_addr_2);
        

        if (read_data_1 != 32'hC)
           $error("Register address path 1 broken");
        $display("time=%0t src_1 value is %h", $time, read_data_1);
        
        if (read_data_2 != 32'hE)
            $error("Register address path 2 broken");
        $display("time=%0t src_2 value is %h", $time, read_data_2);


        @(posedge clk);
        reg_write_en = 1;
        write_addr   = 4'h1;
        write_data   = 32'h32;


        reg_addr_2 = 4'h1; //  read_data_1 =  32'hC, read_data_2 = 32'h32
        @(posedge clk); 
        reg_write_en = 0;
        #1;

        if (read_data_2 != 32'h32)
            $error("overwrite failed");
            $display("time=%0t src_2 value is %h", $time, read_data_2);

        $finish;

    end


endmodule