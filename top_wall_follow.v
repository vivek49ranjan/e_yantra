module wall_following_robot_top (
    input  wire        clk_50M,
    input  wire        rst_n,
    input  wire        echo_left,
    input  wire        echo_front,
    input  wire        echo_right,
    output wire        trig_left,
    output wire        trig_front,
    output wire        trig_right,
    output wire        left_pwm,
    output wire        left_in1,
    output wire        left_in2,
    output wire        right_pwm,
    output wire        right_in1,
    output wire        right_in2,
    output wire [2:0]  state_leds
);

    wire [15:0] dist_left;
    wire [15:0] dist_front;
    wire [15:0] dist_right;
    wire [2:0]  drive_cmd;
    wire        robot_busy;
    wire        op_l, op_f, op_r;

    t1b_ultrasonic sensor_L (
        .clk_50M(clk_50M), .reset(rst_n), .echo_rx(echo_left), 
        .trig(trig_left), .op(op_l), .distance_out(dist_left)
    );

    t1b_ultrasonic sensor_F (
        .clk_50M(clk_50M), .reset(rst_n), .echo_rx(echo_front), 
        .trig(trig_front), .op(op_f), .distance_out(dist_front)
    );

    t1b_ultrasonic sensor_R (
        .clk_50M(clk_50M), .reset(rst_n), .echo_rx(echo_right), 
        .trig(trig_right), .op(op_r), .distance_out(dist_right)
    );

    wall_follower_logic u_brain (
        .clk(clk_50M),
        .rst_n(rst_n),
        .dist_left(dist_left),
        .dist_front(dist_front),
        .dist_right(dist_right),
        .drive_cmd(drive_cmd)
    );
    
    assign state_leds = drive_cmd;

    robot_drive_system u_drive_sys (
        .clk(clk_50M),
        .rst_n(rst_n),
        .cmd(drive_cmd),
        .base_speed(8'd180),
        .left_pwm(left_pwm),   .left_in1(left_in1),   .left_in2(left_in2),
        .right_pwm(right_pwm), .right_in1(right_in1), .right_in2(right_in2),
        .robot_busy(robot_busy)
    );

endmodule
