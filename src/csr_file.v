/*
 *  ZİNDAN-1: THE ORACLE (CSR - CONTROL & STATUS REGISTERS)
 *  -------------------------------------------------------------
 *  Aciklama: RISC-V CSR standardine benzer hafif bir kontrol ve
 *            durum yazmaci birimi.
 *            - mstatus: Interrupt enable bits
 *            - mtvec:   Trap Vector address
 *            - mepc:    Exception Program Counter
 *            - mcause:  Cause of last interrupt/exception
 *            - mhartid: Hardware Thread ID (always 0 for ZİNDAN-1)
 *
 *  CSR Komutları doğrudan zindan_core.v'den yönetilmektedir.
 */

module csr_file (
    input clk,
    input rst,
    // Write interface
    input        csr_write,
    input [11:0] csr_addr,
    input [31:0] csr_write_data,
    // Read interface
    output reg [31:0] csr_read_data,
    // Interrupt interface
    input        timer_int,
    input        external_int,
    input [31:0] exception_pc,
    // Outputs to core
    output [31:0] trap_vec,
    output        int_enabled
);

    reg [31:0] mstatus;  // CSR 0x300
    reg [31:0] mtvec;    // CSR 0x305
    reg [31:0] mepc;     // CSR 0x341
    reg [31:0] mcause;   // CSR 0x342
    reg [31:0] mip;      // CSR 0x344 (interrupt pending)

    localparam CSR_MSTATUS = 12'h300;
    localparam CSR_MTVEC   = 12'h305;
    localparam CSR_MEPC    = 12'h341;
    localparam CSR_MCAUSE  = 12'h342;
    localparam CSR_MIP     = 12'h344;
    localparam CSR_MHARTID = 12'hF14;

    assign trap_vec   = mtvec;
    assign int_enabled = mstatus[3]; // MIE bit

    always @(posedge clk or posedge rst) begin
        if (rst) begin
            mstatus <= 32'h8;        // MIE enabled by default
            mtvec   <= 32'h000000FC; // Default Trap Vector
            mepc    <= 32'b0;
            mcause  <= 32'b0;
            mip     <= 32'b0;
        end else begin
            // Interrupt handling
            if (timer_int && mstatus[3]) begin
                mepc   <= exception_pc;
                mcause <= 32'h80000007; // Machine timer interrupt
                mstatus[3] <= 0; // Disable interrupts while handling
                mip[7] <= 1;
            end
            if (external_int && mstatus[3]) begin
                mepc   <= exception_pc;
                mcause <= 32'h8000000B; // Machine external interrupt
                mstatus[3] <= 0;
                mip[11] <= 1;
            end

            // CSR Write
            if (csr_write) begin
                case (csr_addr)
                    CSR_MSTATUS: mstatus <= csr_write_data;
                    CSR_MTVEC:   mtvec   <= csr_write_data;
                    CSR_MEPC:    mepc    <= csr_write_data;
                    CSR_MCAUSE:  mcause  <= csr_write_data;
                    CSR_MIP:     mip     <= csr_write_data;
                endcase
            end
        end
    end

    // CSR Read
    always @(*) begin
        case (csr_addr)
            CSR_MSTATUS: csr_read_data = mstatus;
            CSR_MTVEC:   csr_read_data = mtvec;
            CSR_MEPC:    csr_read_data = mepc;
            CSR_MCAUSE:  csr_read_data = mcause;
            CSR_MIP:     csr_read_data = mip;
            CSR_MHARTID: csr_read_data = 32'b0;
            default:     csr_read_data = 32'b0;
        endcase
    end

endmodule
