module wall_follower_logic (
    input  wire        clk,
    input  wire        rst_n,
    input  wire [15:0] dist_left,
    input  wire [15:0] dist_front,
    input  wire [15:0] dist_right,
    output reg  [2:0]  drive_cmd
);

    localparam CMD_STOP   = 3'b000;
    localparam CMD_FWD    = 3'b001;
    localparam CMD_LEFT   = 3'b010;
    localparam CMD_RIGHT  = 3'b011;
    
    parameter WALL_DIST_MIN = 16'd15; 
    parameter WALL_DIST_MAX = 16'd30;
    parameter FRONT_STOP    = 16'd20;

    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            drive_cmd <= CMD_STOP;
        end else begin
            if (dist_front > 0 && dist_front < FRONT_STOP) begin
                drive_cmd <= CMD_RIGHT;
            end
            else if (dist_left > 0 && dist_left < WALL_DIST_MIN) begin
                drive_cmd <= CMD_RIGHT; 
            end
            else if (dist_left > WALL_DIST_MAX || dist_left == 0) begin
                drive_cmd <= CMD_LEFT;
            end
            else begin
                drive_cmd <= CMD_FWD;
            end
        end
    end

endmodule
