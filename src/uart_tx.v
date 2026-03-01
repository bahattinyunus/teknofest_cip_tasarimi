/*
 *  ZİNDAN-1: THE COURIER (UART TX)
 *  -------------------------------------------------------------
 *  Aciklama: Dis dunyaya veri tasiyan hizli ulak.
 *            Baud Rate: 115200 @ 50MHz
 */

module uart_tx (
    input clk,
    input rst,
    input [7:0] data,
    input tx_start,
    output reg tx_out,
    output reg tx_ready
);

    // Baud rate generator (50MHz / 115200 = ~434)
    localparam CLKS_PER_BIT = 434;

    reg [2:0] state;
    reg [9:0] clk_count;
    reg [2:0] bit_index;
    reg [7:0] tx_data;

    localparam IDLE  = 3'b000;
    localparam START = 3'b001;
    localparam DATA  = 3'b010;
    localparam STOP  = 3'b011;

    always @(posedge clk or posedge rst) begin
        if (rst) begin
            state <= IDLE;
            tx_out <= 1'b1;
            tx_ready <= 1'b1;
            clk_count <= 0;
        end else begin
            case (state)
                IDLE: begin
                    tx_out <= 1'b1;
                    tx_ready <= 1'b1;
                    clk_count <= 0;
                    if (tx_start) begin
                        tx_data <= data;
                        tx_ready <= 1'b0;
                        state <= START;
                    end
                end

                START: begin
                    tx_out <= 1'b0; // Start bit
                    if (clk_count < CLKS_PER_BIT - 1) begin
                        clk_count <= clk_count + 1;
                    end else begin
                        clk_count <= 0;
                        bit_index <= 0;
                        state <= DATA;
                    end
                end

                DATA: begin
                    tx_out <= tx_data[bit_index];
                    if (clk_count < CLKS_PER_BIT - 1) begin
                        clk_count <= clk_count + 1;
                    end else begin
                        clk_count <= 0;
                        if (bit_index < 7) begin
                            bit_index <= bit_index + 1;
                        end else begin
                            state <= STOP;
                        end
                    end
                end

                STOP: begin
                    tx_out <= 1'b1; // Stop bit
                    if (clk_count < CLKS_PER_BIT - 1) begin
                        clk_count <= clk_count + 1;
                    end else begin
                        clk_count <= 0;
                        state <= IDLE;
                    end
                end
                
                default: state <= IDLE;
            endcase
        end
    end

endmodule
