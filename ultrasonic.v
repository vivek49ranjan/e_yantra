module t1b_ultrasonic(
    input  wire        clk_50M, 
    input  wire        reset, 
    input  wire        echo_rx,
    output reg         trig,
    output wire        op,
    output wire [15:0] distance_out
);

    localparam INIT_DELAY   = 3'd0;
    localparam PRE_TRIGGER  = 3'd1; 
    localparam TRIGGER      = 3'd2;
    localparam MEASURE_ECHO = 3'd3;
    localparam WAIT         = 3'd4;

    reg [2:0]  state;
    reg [8:0]  counter_50M;      
    reg [19:0] trig_timer;      
    reg [16:0] echo_count;      
    reg [15:0] distance_reg; 
    reg        echo_rx_dly;         

    assign distance_out = distance_reg;
    assign op = (distance_reg > 0 && distance_reg < 70) ? 1'b1 : 1'b0;

    initial trig = 1'b0;

    always @(posedge clk_50M) begin
        if (reset == 0) begin
            state <= INIT_DELAY;
            trig <= 1'b0;
            counter_50M <= 0;
            trig_timer <= 0;
        end else begin
            if (trig_timer < 600_000) 
                trig_timer <= trig_timer + 1;

            case(state)
                INIT_DELAY: begin 
                    counter_50M <= counter_50M + 1;
                    if (counter_50M >= 50) begin 
                        counter_50M <= 0;
                        state <= TRIGGER;
                    end
                end
                PRE_TRIGGER: begin 
                    counter_50M <= counter_50M + 1;
                    if (counter_50M >= 51) begin 
                        counter_50M <= 0;
                        state <= TRIGGER;
                    end
                end
                TRIGGER: begin 
                    if (counter_50M == 0) 
                        trig <= 1'b1; 
                    counter_50M <= counter_50M + 1;
                    if (counter_50M >= 500) begin 
                        trig <= 1'b0;       
                        trig_timer <= 0;    
                        counter_50M <= 0;
                        state <= MEASURE_ECHO;
                    end
                end
                MEASURE_ECHO: begin 
                    if (!echo_rx) state <= WAIT; 
                end
                WAIT: begin 
                    if (trig_timer >= 600_000) begin
                        counter_50M <= 0;
                        state <= PRE_TRIGGER;
                    end
                end
                default: state <= INIT_DELAY; 
            endcase
        end
    end

    always @(posedge clk_50M) begin 
         if (reset == 0) begin
            echo_count <= 0;
        end else begin
            if (echo_rx) 
                echo_count <= echo_count + 1;
            else 
                echo_count <= 0;
        end
    end

    always @(posedge clk_50M) begin 
        if (reset == 0) begin
            distance_reg <= 0;
            echo_rx_dly  <= 1'b0;
        end
        else begin
            echo_rx_dly <= echo_rx;
            if (echo_rx_dly && !echo_rx) begin
                distance_reg <= ((echo_count * 34) / 10000) - 1;
            end
            if (counter_50M == 500 && echo_count == 0 && !echo_rx) begin 
                 distance_reg <= 16'd0;
            end
        end
    end

endmodule
