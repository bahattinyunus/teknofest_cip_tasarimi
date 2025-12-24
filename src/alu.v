/*
 *  ZİNDAN-1: THE CRUSHER (ALU)
 *  -------------------------------------------------------------
 *  Aciklama: Sayilari birbirine vurduran, toplama cikarma yapan,
 *            bazen de sikilip "don't care" ciktisi veren unite.
 *  
 *  Author: Zindan Team
 *  Clock Speed: "Belki calisir" MHz
 */

module alu (
    input [31:0] a,
    input [31:0] b,
    input [3:0] alu_op,
    output reg [31:0] result,
    output reg zero_flag
);

    always @(*) begin
        case (alu_op)
            4'b0000: result = a + b;       // Toplama (Basit isler)
            4'b0001: result = a - b;       // Cikarma (Borc hesaplama)
            4'b0010: result = a & b;       // AND (Mantikli ol)
            4'b0011: result = a | b;       // OR (Ya o ya bu)
            4'b0100: result = a ^ b;       // XOR (Karmasik iliskiler)
            4'b1111: result = 32'hDEADBEEF; // KAOS MODU
            default: result = 32'b0;       // Hicbir sey yapmama hakki
        endcase

        // Sifir mi? Evet sifir. Hayatimdaki anlam gibi.
        zero_flag = (result == 32'b0) ? 1'b1 : 1'b0;
    end

endmodule
