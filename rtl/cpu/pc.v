module pc(input clk, reset,
          input [31:0] data,
          output reg [31:0] q
          );

    always @(posedge clk or posedge reset) begin
        if (reset) 
            q <= 0;

        else
            q <= data;
    end

endmodule