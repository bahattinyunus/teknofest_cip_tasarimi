/*
 *  ZİNDAN-1: THE CHRONOS (TIMER MODULE)
 *  -------------------------------------------------------------
 *  Aciklama: 32-bit bellek haritalı (MMIO) zamanlayıcı.
 *            Belirli bir degere ulastiginda kesme uretir.
 */

module timer (
    input clk,
    input rst,
    input [31:0] addr,
    input [31:0] write_data,
    input mem_write,
    input mem_read,
    output [31:0] read_data,
    output reg interrupt
);

    reg [31:0] timer_val;   // 0x80000010
    reg [31:0] timer_cmp;   // 0x80000014
    reg [31:0] timer_ctrl;  // 0x80000018 (Bit 0: Enable, Bit 1: Int Pend)

    // Timer Increment
    always @(posedge clk or posedge rst) begin
        if (rst) begin
            timer_val <= 32'b0;
        end else if (timer_ctrl[0]) begin
            timer_val <= timer_val + 1;
        end
    end

    // Interrupt Logic
    always @(posedge clk or posedge rst) begin
        if (rst) begin
            interrupt <= 1'b0;
            timer_ctrl[1] <= 1'b0;
        end else begin
            if (timer_val >= timer_cmp && timer_cmp != 0) begin
                interrupt <= 1'b1;
                timer_ctrl[1] <= 1'b1;
            end
            
            // Manual Clear (Write 0 to Bit 1)
            if (mem_write && addr == 32'h80000018 && !write_data[1]) begin
                interrupt <= 1'b0;
                timer_ctrl[1] <= 1'b0;
            end
        end
    end

    // MMIO Register Write
    always @(posedge clk or posedge rst) begin
        if (rst) begin
            timer_cmp <= 32'hFFFFFFFF;
            timer_ctrl <= 32'h1; // Default: Enabled
        end else if (mem_write) begin
            case (addr)
                32'h80000010: timer_val <= write_data;
                32'h80000014: timer_cmp <= write_data;
                32'h80000018: timer_ctrl <= write_data;
            endcase
        end
    end

    // MMIO Register Read
    assign read_data = (addr == 32'h80000010) ? timer_val :
                       (addr == 32'h80000014) ? timer_cmp :
                       (addr == 32'h80000018) ? timer_ctrl : 32'b0;

endmodule
