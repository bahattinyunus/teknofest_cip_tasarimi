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

            7'b0110011: begin // R-Type (Muhendislik Harikasi)
                reg_write = 1;
                alu_op = 2'b10; // R-Type ALU op
            end
            7'b0010011: begin // I-Type (Immediate)
                reg_write = 1;
                alu_src = 1;
                alu_op = 2'b11; // I-Type ALU op
            end
            7'b0000011: begin // Load (Veri Tasiyici)
                alu_src = 1;
                mem_to_reg = 1;
                reg_write = 1;
                mem_read = 1;
                alu_op = 2'b00; // Addition for address
            end
            7'b0100011: begin // Store (Veri Gomucu)
                alu_src = 1;
                mem_write = 1;
                alu_op = 2'b00; // Addition for address
            end
            7'b1100011: begin // Branch (Karar Verici)
                branch = 1;
                alu_op = 2'b01; // Subtraction for comparison
            end
            7'b1111111: begin // HALT (Yeter duralim artik)
                // Sistemi kilitle
            end
            default: begin
                // Tanimsiz opcode -> Ignorance is bliss.
            end
        endcase
    end

endmodule
