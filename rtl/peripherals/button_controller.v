module button_controller #(
    parameter CLK_FREQ = 12000000,
    parameter DEBOUNCE_MS = 10
)(
    input clk,
    input button,

    output  button_pulse
);

    // Calculate debounce count
    localparam integer DEBOUNCE_COUNT =
        (CLK_FREQ / 1000) * DEBOUNCE_MS;

    // Number of bits required for the counter
    reg [31:0] debounce_counter = 0;

    // Synchronizer
    reg btn_ff0 = 0;
    reg btn_ff1 = 0;

    always @(posedge clk) begin
        btn_ff0 <= button;
        btn_ff1 <= btn_ff0;
    end

    // Debouncer
    reg button_state = 0;

    always @(posedge clk) begin

        if(btn_ff1 == button_state) begin

            debounce_counter <= 0;

        end
        else begin

            if(debounce_counter >= DEBOUNCE_COUNT-1) begin

                button_state <= btn_ff1;
                debounce_counter <= 0;

            end
            else begin

                debounce_counter <= debounce_counter + 1;

            end

        end

    end

    // Rising Edge Detector
    reg button_state_d = 0;

    always @(posedge clk)
        button_state_d <= button_state;

    assign button_pulse = button_state & ~button_state_d;

endmodule