/*
 *  ZİNDAN-1: THE EAR (UART RECEIVER)
 *  -------------------------------------------------------------
 *  Aciklama: Seri veriyi paralel hale getiren UART alıcı modülü.
 *            115200 baud @ 50MHz.
 */

module uart_rx (
    input clk,
    input rst,
    input rx_in,
    output reg [7:0] data,
    output reg rx_ready,
    input rx_clear // Read signal to clear ready flag
);

    localparam CLKS_PER_BIT = 434;

    localparam IDLE  = 3'b000;
    localparam START = 3'b001;
    localparam DATA  = 3'b010;
    localparam STOP  = 3'b011;

    reg [2:0]  state;
    reg [9:0]  clk_count;
    reg [2:0]  bit_index;
    reg [7:0]  rx_data_reg;

    always @(posedge clk or posedge rst) begin
        if (rst) begin
            state <= IDLE;
            rx_ready <= 1'b0;
            clk_count <= 0;
            data <= 0;
        end else begin
            case (state)
                IDLE: begin
                    if (rx_in == 1'b0) begin // Start bit detected
                        clk_count <= 0;
                        state <= START;
                    end
                    if (rx_clear) rx_ready <= 1'b0;
                end

                START: begin
                    if (clk_count == (CLKS_PER_BIT-1)/2) begin
                        if (rx_in == 1'b0) begin
                            clk_count <= 0;
                            bit_index <= 0;
                            state <= DATA;
                        end else begin
                            state <= IDLE;
                        end
                    end else begin
                        clk_count <= clk_count + 1;
                    end
                end

                DATA: begin
                    if (clk_count < CLKS_PER_BIT - 1) begin
                        clk_count <= clk_count + 1;
                    end else begin
                        clk_count <= 0;
                        rx_data_reg[bit_index] <= rx_in;
                        if (bit_index < 7) begin
                            bit_index <= bit_index + 1;
                        end else begin
                            state <= STOP;
                        end
                    end
                end

                STOP: begin
                    if (clk_count < CLKS_PER_BIT - 1) begin
                        clk_count <= clk_count + 1;
                    end else begin
                        clk_count <= 0;
                        rx_ready <= 1'b1;
                        data <= rx_data_reg;
                        state <= IDLE;
                    end
                end

                default: state <= IDLE;
            endcase
        end
    end

endmodule
