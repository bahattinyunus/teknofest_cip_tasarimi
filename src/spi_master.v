/*
 *  ZİNDAN-1: THE NETWORKER (SPI MASTER MODULE)
 *  -------------------------------------------------------------
 *  Aciklama: Tam özellikli SPI (Serial Peripheral Interface) 
 *            Master modülü. CPOL=0, CPHA=0.
 *            Ekranlar, hafıza ve sensörlerle konuşmak için.
 *
 *  MMIO Haritası:
 *    0x80000040 -> SPI_DATA   (W: Göndermek istenen byte)
 *    0x80000044 -> SPI_STATUS (R: Bit 0: TXready, Bit 1: Busy)
 *    0x80000048 -> SPI_CTRL   (W: Bit 0: CS_n Assert/Deassert)
 */

module spi_master (
    input clk,
    input rst,
    input [31:0] addr,
    input [31:0] write_data,
    input mem_write,
    output [31:0] read_data,
    // SPI Physical Pins
    output reg spi_sck,
    output reg spi_mosi,
    input      spi_miso,
    output reg spi_cs_n
);

    localparam SPI_CLK_DIV = 25; // 50MHz / 25 / 2 = 1 MHz SPI clock

    reg [7:0]  shift_reg;
    reg [7:0]  rx_data;
    reg [3:0]  bit_count;
    reg [5:0]  clk_div_cnt;
    reg        busy;
    reg        tx_ready;

    localparam IDLE = 1'b0;
    localparam RUN  = 1'b1;
    reg state;

    always @(posedge clk or posedge rst) begin
        if (rst) begin
            state <= IDLE;
            spi_sck <= 0;
            spi_mosi <= 0;
            spi_cs_n <= 1;
            busy <= 0;
            tx_ready <= 1;
        end else begin
            case (state)
                IDLE: begin
                    if (mem_write && addr == 32'h80000040) begin
                        shift_reg <= write_data[7:0];
                        bit_count <= 0;
                        clk_div_cnt <= 0;
                        busy <= 1;
                        tx_ready <= 0;
                        spi_cs_n <= 0;
                        state <= RUN;
                    end
                    if (mem_write && addr == 32'h80000048) begin
                        spi_cs_n <= write_data[0];
                    end
                end

                RUN: begin
                    if (clk_div_cnt < SPI_CLK_DIV - 1) begin
                        clk_div_cnt <= clk_div_cnt + 1;
                    end else begin
                        clk_div_cnt <= 0;
                        spi_sck <= ~spi_sck;
                        if (spi_sck == 1'b0) begin
                            // Rising edge: Sample MISO
                            rx_data <= {rx_data[6:0], spi_miso};
                        end else begin
                            // Falling edge: Drive MOSI
                            spi_mosi <= shift_reg[7];
                            shift_reg <= {shift_reg[6:0], 1'b0};
                            bit_count <= bit_count + 1;
                            if (bit_count == 7) begin
                                busy <= 0;
                                tx_ready <= 1;
                                state <= IDLE;
                            end
                        end
                    end
                end
            endcase
        end
    end

    assign read_data = (addr == 32'h80000044) ? {30'b0, busy, tx_ready} : 32'b0;

endmodule
