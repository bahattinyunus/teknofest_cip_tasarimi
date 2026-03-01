/*
 *  ZİNDAN-1: THE DIPLOMAT (GPIO MODULE)
 *  -------------------------------------------------------------
 *  Aciklama: 32-bit Generic amaçlı giriş/çıkış portu.
 *            Her bit bağımsız olarak IN veya OUT olarak 
 *            ayarlanabilir.
 *
 *  MMIO Haritası:
 *    0x80000030 -> GPIO_DATA  (R/W: Port değeri)
 *    0x80000034 -> GPIO_DIR   (R/W: Bit=1 Çıkış, Bit=0 Giriş)
 */

module gpio (
    input clk,
    input rst,
    input [31:0] addr,
    input [31:0] write_data,
    input mem_write,
    input mem_read,
    input [31:0] gpio_in,       // Fiziksel giriş pinleri
    output reg [31:0] gpio_out, // Fiziksel çıkış pinleri
    output [31:0] read_data
);

    reg [31:0] gpio_data; // Output register
    reg [31:0] gpio_dir;  // Direction register

    // Direction-gated output
    always @(*) begin
        gpio_out = gpio_data & gpio_dir; // Only drive output pins
    end

    // Register Write
    always @(posedge clk or posedge rst) begin
        if (rst) begin
            gpio_data <= 32'b0;
            gpio_dir  <= 32'b0; // Default: All inputs
        end else if (mem_write) begin
            case (addr)
                32'h80000030: gpio_data <= write_data;
                32'h80000034: gpio_dir  <= write_data;
            endcase
        end
    end

    // Register Read
    assign read_data = (addr == 32'h80000030) ? ((gpio_dir & gpio_data) | (~gpio_dir & gpio_in)) :
                       (addr == 32'h80000034) ? gpio_dir : 32'b0;

endmodule
