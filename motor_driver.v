module motor_driver (
    input  wire       clk,
    input  wire       rst_n,
    input  wire       en,
    input  wire [7:0] speed,
    input  wire       direction,
    output wire       pwm_out,
    output reg        in1,
    output reg        in2
);

    reg [7:0] counter;

    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            counter <= 8'b0;
        end else begin
            counter <= counter + 1'b1;
        end
    end

    assign pwm_out = (en) ? (counter < speed) : 1'b0;

    always @(*) begin
        if (!en) begin
            in1 = 1'b0;
            in2 = 1'b0;
        end else begin
            if (direction == 1'b0) begin
                in1 = 1'b1;
                in2 = 1'b0;
            end else begin
                in1 = 1'b0;
                in2 = 1'b1;
            end
        end
    end

endmodule
