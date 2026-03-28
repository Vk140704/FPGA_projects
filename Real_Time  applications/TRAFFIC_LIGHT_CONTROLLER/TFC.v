module traffic_light_controller #(
    parameter CLK_FREQ = 50_000_000
)(
    input clk,
    input rst,

    output reg [1:0] N, E, S, W   // 00=RED, 01=GREEN, 10=AMBER
);


localparam SEC_COUNT = CLK_FREQ - 1;

reg [25:0] clk_count;
wire sec_en;

assign sec_en = (clk_count == SEC_COUNT);

always @(posedge clk or posedge rst) begin
    if (rst)
        clk_count <= 0;
    else if (sec_en)
        clk_count <= 0;
    else
        clk_count <= clk_count + 1;
end


parameter N_G = 3'd0, N_Y = 3'd1,
          E_G = 3'd2, E_Y = 3'd3,
          S_G = 3'd4, S_Y = 3'd5,
          W_G = 3'd6, W_Y = 3'd7;

reg [2:0] state;

reg [3:0] timer;


always @(posedge clk or posedge rst) begin
    if (rst) begin
        state <= N_G;
        timer <= 0;
    end 
    else if (sec_en) begin

        case (state)

            N_G: begin
                if (timer == 9) begin
                    state <= N_Y;
                    timer <= 0;
                end else timer <= timer + 1;
            end

            N_Y: begin
                if (timer == 2) begin
                    state <= E_G;
                    timer <= 0;
                end else timer <= timer + 1;
            end

            E_G: begin
                if (timer == 9) begin
                    state <= E_Y;
                    timer <= 0;
                end else timer <= timer + 1;
            end

            E_Y: begin
                if (timer == 2) begin
                    state <= S_G;
                    timer <= 0;
                end else timer <= timer + 1;
            end

            S_G: begin
                if (timer == 9) begin
                    state <= S_Y;
                    timer <= 0;
                end else timer <= timer + 1;
            end

            S_Y: begin
                if (timer == 2) begin
                    state <= W_G;
                    timer <= 0;
                end else timer <= timer + 1;
            end

            W_G: begin
                if (timer == 9) begin
                    state <= W_Y;
                    timer <= 0;
                end else timer <= timer + 1;
            end

            W_Y: begin
                if (timer == 2) begin
                    state <= N_G;
                    timer <= 0;
                end else timer <= timer + 1;
            end

            default: begin
                state <= N_G;  // Safe recovery
                timer <= 0;
            end

        endcase
    end
end


always @(*) begin
    // Default: all RED
    N = 2'b00;
    E = 2'b00;
    S = 2'b00;
    W = 2'b00;

    case (state)
        N_G: N = 2'b01;
        N_Y: N = 2'b10;

        E_G: E = 2'b01;
        E_Y: E = 2'b10;

        S_G: S = 2'b01;
        S_Y: S = 2'b10;

        W_G: W = 2'b01;
        W_Y: W = 2'b10;
    endcase
end

endmodule
