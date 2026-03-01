/*
 *  ZİNDAN-1: THE WAREHOUSE (DATA MEMORY)
 *  -------------------------------------------------------------
 *  Aciklama: Yukle/Sakla komutlari icin ana depo.
 */

module dmem (
    input clk,
    input mem_read,
    input mem_write,
    input [31:0] addr,
    input [31:0] write_data,
    output [31:0] read_data
);

    reg [31:0] memory [0:1023]; // 4KB Data Memory

    // Read logic
    assign read_data = (mem_read) ? memory[addr[31:2]] : 32'b0;

    // Write logic
    always @(posedge clk) begin
        if (mem_write) begin
            memory[addr[31:2]] <= write_data;
        end
    end

endmodule
