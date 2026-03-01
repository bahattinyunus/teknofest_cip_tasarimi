/*
 *  ZİNDAN-1: THE GUARDIAN (HAZARD & FORWARDING UNIT)
 *  -------------------------------------------------------------
 *  Aciklama: Pipeline icerisindeki veri ve kontrol cakismalarini 
 *            (hazards) tespit edip cozen, verinin dogru yere 
 *            akitilmasini saglayan unit.
 */

module hazard_unit (
    // Inputs from Pipeline Stages
    input [4:0] id_ex_rs1,
    input [4:0] id_ex_rs2,
    input [4:0] ex_mem_rd,
    input [4:0] mem_wb_rd,
    input       ex_mem_reg_write,
    input       mem_wb_reg_write,
    input       id_ex_mem_read, // For Load-Use hazard
    input [4:0] if_id_rs1,
    input [4:0] if_id_rs2,
    input [4:0] id_ex_rd,

    // Forwarding Outputs
    output reg [1:0] forward_a,
    output reg [1:0] forward_b,
    
    // Stall/Flush Outputs
    output reg stall_if,
    output reg stall_id,
    output reg flush_ex
);

    always @(*) begin
        // --- FORWARDING LOGIC ---
        // Forward A
        if (ex_mem_reg_write && (ex_mem_rd != 0) && (ex_mem_rd == id_ex_rs1))
            forward_a = 2'b10; // Forward from EX/MEM
        else if (mem_wb_reg_write && (mem_wb_rd != 0) && (mem_wb_rd == id_ex_rs1))
            forward_a = 2'b01; // Forward from MEM/WB
        else
            forward_a = 2'b00;

        // Forward B
        if (ex_mem_reg_write && (ex_mem_rd != 0) && (ex_mem_rd == id_ex_rs2))
            forward_b = 2'b10; // Forward from EX/MEM
        else if (mem_wb_reg_write && (mem_wb_rd != 0) && (mem_wb_rd == id_ex_rs2))
            forward_b = 2'b01; // Forward from MEM/WB
        else
            forward_b = 2'b00;

        // --- HAZARD DETECTION (Stall Logic) ---
        // Load-Use Hazard
        if (id_ex_mem_read && ((id_ex_rd == if_id_rs1) || (id_ex_rd == if_id_rs2))) begin
            stall_if = 1;
            stall_id = 1;
            flush_ex = 1;
        end else begin
            stall_if = 0;
            stall_id = 0;
            flush_ex = 0;
        end
    end

endmodule
