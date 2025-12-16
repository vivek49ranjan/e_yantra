module ir_servo_controller (
    input wire clk,
    input wire [2:0] ir_in,
    output wire [2:0] servo_out
);

    genvar i;
    generate
        for (i = 0; i < 3; i = i + 1) begin : servo_gen
            servo_channel u_servo (
                .clk(clk),
                .trigger(ir_in[i]),
                .pwm_signal(servo_out[i])
            );
        end
    endgenerate

endmodule

module servo_channel (
    input wire clk,
    input wire trigger,
    output reg pwm_signal
);

    parameter CLK_FREQ = 50000000;
    parameter PWM_PERIOD_TICKS = 1000000; 
    parameter PULSE_0_DEG = 50000;
    parameter PULSE_90_DEG = 75000;
    
    reg [19:0] counter = 0;
    reg [19:0] current_pulse_width;

    wire obstacle_detected = (trigger == 1'b0); 

    always @(posedge clk) begin
        if (obstacle_detected) 
            current_pulse_width <= PULSE_90_DEG;
        else 
            current_pulse_width <= PULSE_0_DEG;

        if (counter < PWM_PERIOD_TICKS - 1)
            counter <= counter + 1;
        else
            counter <= 0;

        if (counter < current_pulse_width)
            pwm_signal <= 1'b1;
        else
            pwm_signal <= 1'b0;
    end

endmodule
