module mux2 #(parameter WIDTH = 8) (
    input  [WIDTH-1:0] data_1, data_2,
    input sel
    output [WIDTH-1:0] out
    );

    out = sel? data_1 : data_2;


endmodule