/*
 *  ZİNDAN-1: THE LIBRARY (INSTRUCTION MEMORY)
 *  -------------------------------------------------------------
 *  Aciklama: Buyulu talimatlarin saklandigi yer. 
 *            Simdilik statik, ileride dinamik olabilir.
 */

module imem (
    input [31:0] addr,
    output [31:0] instruction
);

    reg [31:0] memory [0:1023]; // 4KB Instruction Memory

    // Read logic (Word-aligned)
    assign instruction = memory[addr[31:2]];

    // Baslangic talimatlari (Simple Program)
    initial begin
        // r1 = 10, r2 = 20, r3 = r1 + r2
        // ADDI r1, x0, 10 -> 0x00a00093
        // ADDI r2, x0, 20 -> 0x01400113
        // ADD  r3, r1, r2 -> 0x002081b3
        memory[0] = 32'h00a00093;
        memory[1] = 32'h01400113;
        memory[2] = 32'h002081b3;
    end

endmodule
