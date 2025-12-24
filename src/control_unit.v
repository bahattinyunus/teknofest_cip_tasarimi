/*
 *  ZİNDAN-1: THE TRAFFIC COP (CONTROL UNIT)
 *  -------------------------------------------------------------
 *  Aciklama: Tum islemciyi yoneten, kimin ne zaman konusacagina
 *            karar veren diktator modül.
 *  
 *  Author: Zindan Team
 *  State Machine: Spaghetti
 */

module control_unit (
    input [6:0] opcode,
    output reg branch,
    output reg mem_read,
    output reg mem_to_reg,
    output reg [1:0] alu_op,
    output reg mem_write,
    output reg alu_src,
    output reg reg_write
);

    always @(*) begin
        // Varsayilan: Hicbir sey yapma, enerji tasarrufu.
        {branch, mem_read, mem_to_reg, alu_op, mem_write, alu_src, reg_write} = 0;

        case (opcode)
            7'b0110011: begin // R-Type (Gercek Muhendislik)
                reg_write = 1;
                alu_op = 2'b10;
            end
            7'b0000011: begin // Load (Veri tasiyici)
                alu_src = 1;
                mem_to_reg = 1;
                reg_write = 1;
                mem_read = 1;
            end
            7'b0100011: begin // Store (Veri gomucu)
                alu_src = 1;
                mem_write = 1;
            end
            7'b1111111: begin // HALT (Yeter duralim artik)
                // Sistemi kilitle
            end
            default: begin
                // Tanimsiz opcode -> Panik yapma, ignorance is bliss.
            end
        endcase
    end

endmodule
