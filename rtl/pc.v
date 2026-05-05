module pc(input clk, reset, en,
          input[31:0] data,
          output reg [31:0] q
          );

    always @(posedge clk or posedge reset) begin
        if (reset) 
            q <= 0;

        else if (en) 
            q <= data;
    end

endmodule