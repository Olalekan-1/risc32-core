`timescale 1ns/1ps

module data_mem_tb;
    logic clk, mem_write_en;
    logic [31:0] addr, write_data, read_data;

    localparam CLK_PERIOD = 1;

    logic [31:0] expected_ram[0:31];
    logic [31:0] expected;

    data_mem uut(.clk(clk),
                 .mem_write_en(mem_write_en),
                 .addr(addr),
                 .write_data(write_data),
                 .read_data(read_data)
                );

    initial begin
            clk = 0;
            forever #CLK_PERIOD clk = ~clk;
    end

    task automatic drive_write(input logic mem_write_en_i,
                               input logic [31:0] addr_i,
                               input logic [31:0] write_data_i
                                );
        begin
           @(negedge clk )begin
            mem_write_en = mem_write_en_i;
            addr = addr_i;
            write_data = write_data_i;
           end
        end
    endtask

    task automatic drive_addr(input logic [31:0] addr_i);
        @(negedge clk)
         addr = addr_i;
    endtask

    function automatic logic [31:0] drive_read(input logic [31:0] addr_i);

        logic [31:0] expected_data;
         expected_data = expected_ram[addr_i >> 2];
        return expected_data;

    endfunction

    task automatic check_data(input logic [31:0] expected_data);

        assert((read_data === expected_data))
             $display("[%0t] PASS", $time);
        else
            $error("Expected expected_data=%0d Got=%0d", expected_data, read_data);
    endtask


    // generete random data and addresses
    logic [31:0] addresses[5], write_datas[5];


    initial begin

        addresses[0] = $urandom_range(31) << 2;
        addresses[1] = $urandom_range(31) << 2;
        addresses[2] = $urandom_range(31) << 2;
        addresses[3] = $urandom_range(31) << 2;
        addresses[4] = $urandom_range(31) << 2;

       
        write_datas[0] = $urandom();
        write_datas[1] = $urandom();
        write_datas[2] = $urandom();
        write_datas[3] = $urandom();
        write_datas[4] = $urandom();

        uut.RAM[addresses[0] >> 2] = write_datas[0];
        uut.RAM[addresses[1] >> 2] = write_datas[1];
        uut.RAM[addresses[2] >> 2] = write_datas[2];
        uut.RAM[addresses[3] >> 2] = write_datas[3];
        uut.RAM[addresses[4] >> 2] = write_datas[4];

    end

    initial begin
        $dumpfile("sim/waves/data_mem.vcd");
        $dumpvars(0,  data_mem_tb);
       

        for (int i = 0; i < 5; i++)  // write data into adresssed location
        begin
            drive_write(1'b1,
                        addresses[i],
                        write_datas[i]
                        );

            @(posedge clk);
            if(mem_write_en)
                expected_ram[addr >> 2] = write_data;
        end

        // mem_write_enable = 0;
        drive_write(1'b0,
                    addresses[3],
                    32'hFFFFF
                        );
         @(posedge clk);
          if(mem_write_en)
            expected_ram[(addr >> 2)] <= write_data;
         expected = drive_read(addresses[3]);
         check_data(expected);

         // check read operation

          for (int i = 0; i < 5; i++)
          begin
            drive_addr(addresses[i]);
            @(posedge clk);
            expected = drive_read(addresses[i]);
            check_data(expected);
          end


        $display("DONE");
        $finish;
    end


endmodule
