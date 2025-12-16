module robot_drive_system (
    input  wire        clk,
    input  wire        rst_n,
    input  wire [2:0]  cmd,
    input  wire [7:0]  base_speed,
    output wire        left_pwm,
    output wire        left_in1,
    output wire        left_in2,
    output wire        right_pwm,
    output wire        right_in1,
    output wire        right_in2,
    output reg         robot_busy
);

    localparam CMD_STOP   = 3'b000;
    localparam CMD_FWD    = 3'b001;
    localparam CMD_LEFT   = 3'b010;
    localparam CMD_RIGHT  = 3'b011;
    localparam CMD_UTURN  = 3'b100;

    localparam IDLE         = 2'b00;
    localparam MANUAL       = 2'b01;
    localparam UTURN_ACTIVE = 2'b10;

    reg [1:0] state, next_state;
    reg [31:0] timer;
    parameter UTURN_TICKS = 32'd50_000_000;

    reg left_en, right_en;
    reg left_dir, right_dir;
    reg [7:0] left_speed, right_speed;

    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            state <= IDLE;
            timer <= 0;
        end else begin
            state <= next_state;
            if (state == UTURN_ACTIVE) 
                timer <= timer + 1;
            else 
                timer <= 0;
        end
    end

    always @(*) begin
        next_state  = state;
        left_en     = 0; right_en    = 0;
        left_dir    = 0; right_dir   = 0;
        left_speed  = 0; right_speed = 0;
        robot_busy  = 0;

        case (state)
            IDLE: begin
                if (cmd == CMD_UTURN) next_state = UTURN_ACTIVE;
                else if (cmd != CMD_STOP) next_state = MANUAL;
            end

            MANUAL: begin
                case (cmd)
                    CMD_FWD: begin
                        left_en = 1; left_dir = 0; left_speed = base_speed;
                        right_en = 1; right_dir = 0; right_speed = base_speed;
                    end
                    CMD_LEFT: begin
                        left_en = 1; left_dir = 1; left_speed = base_speed;
                        right_en = 1; right_dir = 0; right_speed = base_speed;
                    end
                    CMD_RIGHT: begin
                        left_en = 1; left_dir = 0; left_speed = base_speed;
                        right_en = 1; right_dir = 1; right_speed = base_speed;
                    end
                    CMD_STOP: begin
                        next_state = IDLE;
                    end
                    CMD_UTURN: begin
                        next_state = UTURN_ACTIVE;
                    end
                    default: next_state = IDLE;
                endcase
            end

            UTURN_ACTIVE: begin
                robot_busy = 1;
                left_en = 1; left_dir = 1; left_speed = base_speed;
                right_en = 1; right_dir = 0; right_speed = base_speed;

                if (timer >= UTURN_TICKS) begin
                    next_state = IDLE;
                end
            end
        endcase
    end

    motor_driver u_motor_left (
        .clk(clk), .rst_n(rst_n),
        .en(left_en),
        .speed(left_speed),
        .direction(left_dir),
        .pwm_out(left_pwm),
        .in1(left_in1),
        .in2(left_in2)
    );

    motor_driver u_motor_right (
        .clk(clk), .rst_n(rst_n),
        .en(right_en),
        .speed(right_speed),
        .direction(right_dir),
        .pwm_out(right_pwm),
        .in1(right_in1),
        .in2(right_in2)
    );

endmodule
