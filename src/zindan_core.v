/*
 *  ZİNDAN-1: THE CORE (TOP MODULE)
 *  -------------------------------------------------------------
 *  Aciklama: Her seyin birlestigi yer. Kablo spagettisinin
 *            ana merkezi.
 *  
 *  Author: Zindan Team
 */

module zindan_core (
    input clk,
    input reset,
    output [31:0] debug_leds // Dis dunyaya yasiyorum mesaji
);

    // KABLOLAR (THE WIRES)
    wire [31:0] pc, next_pc;
    wire [31:0] instruction;
    wire [31:0] alu_result;
    wire zero_flag;
    
    // Alt modullerin cagrilmasi (Summoning Rituals)
    
    // ALU: Hesap makinesi
    alu the_crusher (
        .a(32'd10), 
        .b(32'd20), 
        .alu_op(4'b0000), 
        .result(alu_result), 
        .zero_flag(zero_flag)
    );

    // Control: Beyin
    control_unit the_brain (
        .opcode(7'b0110011),
        .branch(),
        .mem_read(),
        .mem_to_reg(),
        .alu_op(),
        .mem_write(),
        .alu_src(),
        .reg_write()
    );

    // LED'lere bagla da calistigini sanasinlar
    assign debug_leds = alu_result;

endmodule
