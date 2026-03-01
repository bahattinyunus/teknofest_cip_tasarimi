; ZİNDAN-1 Hello World Assembly Program
; This file serves as a human-readable reference for the boot ROM binary
; Run through tools/assembler.py to produce the hex output
;
; Registers:
;   x2  (sp) = Stack Pointer
;   x5  (t0) = Temp
;   x6  (t1) = Peripheral base address
;   x7  (t2) = Data
;   x8  (s0) = Loop counter

; ============ BOOT SECTION ============

_start:
    # Init Stack Pointer to top of DMEM (0x4000)
    addi x2, x0, 0x4000

    # Configure Timer: TIMER_CMP = 50000
    # Load TIMER_CMP address (0x80000014)
    addi x6, x0, 0         # will be filled in assembler
    addi x7, x0, 50000     # compare value
    sw x7, 0x14(x6)        # store to TIMER_CMP

    # Send 'Z' boot character via UART TX (0x80000000)
    addi x6, x0, 0         # UART base
    addi x7, x0, 90        # 'Z' = 90
    sw x7, 0(x6)           # Transmit

; ============ MAIN PROGRAM ============

main:
    # Load UART base address
    addi x6, x0, 0         # (MMIO base)

    # Send 'H' = 72
    addi x8, x0, 72
    sw x8, 0(x6)

    # Send 'e' = 101
    addi x8, x0, 101
    sw x8, 0(x6)

    # Send 'l' = 108
    addi x8, x0, 108
    sw x8, 0(x6)

    # Send 'l' = 108
    addi x8, x0, 108
    sw x8, 0(x6)

    # Send 'o' = 111
    addi x8, x0, 111
    sw x8, 0(x6)

    # Send '!' = 33
    addi x8, x0, 33
    sw x8, 0(x6)

_hang:
    jal x0, _hang          # Infinite loop

; ============ TRAP HANDLER (must be at 0xFC) ============

_trap:
    # Clear Timer Interrupt Pending bit (write 0 to TIMER_CTRL bit 1)
    addi x6, x0, 0         # TIMER_CTRL base
    sw x0, 0x18(x6)        # Clear TIMER_CTRL interrupt pending
    # Return from interrupt (mret), simplified as jump back
    jal x0, main
