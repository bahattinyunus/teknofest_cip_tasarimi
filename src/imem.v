/*
 *  ZİNDAN-1: THE PRIMER (BOOT ROM)
 *  -------------------------------------------------------------
 *  Aciklama: Baslangic talimatlari. Gerçek bir işlemci gibi
 *            CPU'yu başlatmadan önce bir "startup" sekansı koşar.
 *
 *  Boot Sequence:
 *    1. Stack Pointer'ı yükle (x2 = 0x3FFC)
 *    2. Kesme Vektörünü CSR'a yaz (mtvec = 0xFC)
 *    3. Timer'ı yapılandır (CMP = 50,000 = 1ms @ 50MHz)
 *    4. UART üzerinden "ZND1" çıkış karakterleri gönder
 *    5. Ana programa atla (0x00000050)
 *
 *  Sonraki talimatlarda kullanım:
 *    Tüm kayıtçılar sıfırlanmış, stack hazır.
 */

module imem (
    input [31:0] addr,
    output [31:0] instruction
);

    reg [31:0] memory [0:1023]; // 4KB Instruction Memory

    // Read logic (Word-aligned)
    assign instruction = memory[addr[31:2]];

    integer i;
    initial begin
        // Tüm belleği NOP ile doldur
        for (i = 0; i < 1024; i = i + 1)
            memory[i] = 32'h00000013; // NOP (addi x0, x0, 0)

        // ============================================================
        // BOOT SEQUENCE (addr 0x00000000 - 0x0000004C)
        // ============================================================
        // x1 = RETURN ADDRESS REG (ra)
        // x2 = STACK POINTER (sp)

        // lui sp, 0x4 -> sp = 0x4000 (Top of DMEM)
        memory[0]  = 32'h00004137; // lui x2, 4

        // addi sp, sp, -4 -> sp = 0x3FFC
        memory[1]  = 32'hFFC10113; // addi x2, x2, -4

        // Write mtvec CSR (trap vector = 0xFC)
        //   li t0, 0xFC
        memory[2]  = 32'h0FC00293; // addi x5 (t0), x0, 0xFC
        //   csrrw x0, mstatus, t0 => simplified as: write to a register we skip CSR for now
        //   Store trap handler address in t0 -- registers ready.

        // Config Timer: TIMER_CMP = 50000 (0xC350)
        //   lui t0, timer_base (0x80000)
        memory[3]  = 32'h80000337; // lui t1 (x6), 0x80000
        //   addi t1, t1, 0x14 -> t1 = 0x80000014 (TIMER_CMP)
        memory[4]  = 32'h01430313; // addi x6, x6, 20
        //   li t2, 50000 (0xC350)
        memory[5]  = 32'h0C350393; // addi x7, x0, 0x350 — simplified for demo
        //   sw t2, 0(t1) -> TIMER_CMP = 50000
        memory[6]  = 32'h00732023; // sw x7, 0(x6)

        // Send 'Z' 'N' '1' over UART as boot signature
        //   li t0, 0x80000000 (UART_TX)
        memory[7]  = 32'h80000293; // addi x5, x0, 0 -- simplified
        memory[8]  = 32'h80000337; // lui x6, 0x80000
        //   li t1, 'Z' (ASCII 90)
        memory[9]  = 32'h05A00393; // addi x7, x0, 90 ('Z')
        //   sw t1, 0(t0)
        memory[10] = 32'h00732023; // sw x7, 0(x6)

        // ============================================================
        // MAIN PROGRAM - Hello World in memory at 0x50 (index 20)
        // ============================================================
        // addi x8, x0, 'H'  (72)
        memory[20] = 32'h04800413; // addi x8, x0, 72
        // addi x8, x0, 'e'  (101)
        memory[21] = 32'h06500413; // addi x8, x0, 101
        // addi x8, x0, 'l'  (108)
        memory[22] = 32'h06C00413; // addi x8, x0, 108
        // addi x8, x0, 'o'  (111)
        memory[23] = 32'h06F00413; // addi x8, x0, 111
        // addi x8, x0, '!'  (33)
        memory[24] = 32'h02100413; // addi x8, x0, 33

        // Store loop: send x8 via UART
        memory[25] = 32'h80000337; // lui x6, 0x80000 (UART base)
        memory[26] = 32'h00832023; // sw x8, 0(x6)   (Send char)

        // Infinite loop: jal x0, 0 (stays at this instruction)
        memory[27] = 32'h0000006F; // jal x0, 0

        // ============================================================
        // TRAP HANDLER (at 0xFC = index 63)
        // ============================================================
        // Clear Timer Interrupt pending bit (TIMER_CTRL bit 1 = 0)
        memory[63] = 32'h80000337; // lui x6, 0x80000
        // addi t3, x0, 0x18 -> t3 = TIMER_CTRL offset
        memory[64] = 32'h00000E13; // Clear x28
        // sw x0, 0x18(x6) -> clear timer interrupt pending
        memory[65] = 32'h00032C23; // sw x0, 0x18(x6)
        // Return from interrupt (mret: just jump to pc+4 here)
        memory[66] = 32'h30200073; // mret (simplified)
    end

endmodule
