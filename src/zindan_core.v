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
    reg [31:0] pc;
    wire [31:0] next_pc;
    wire [31:0] instruction;
    wire [31:0] read_data1, read_data2, write_data;
    wire [31:0] imm_ext, jal_imm;
    wire [31:0] alu_in2, alu_result;
    wire [31:0] mem_read_data;
    wire zero_flag;
    
    // Control Signals
    wire branch, mem_read, mem_to_reg, mem_write, alu_src, reg_write, jump, jalr;
    wire [1:0] alu_ctrl_op;
    reg [3:0] alu_op;

    // UART Signals
    wire uart_tx_ready;
    wire uart_tx_start;
    assign uart_tx_start = (mem_write && alu_result == 32'h80000000);

    // PC Logic
    always @(posedge clk or posedge reset) begin
        if (reset) pc <= 32'b0;
        else pc <= next_pc;
    end
    
    // PC Hiyerarsisi: Jump > Branch > Next
    assign next_pc = (jalr) ? (read_data1 + imm_ext) :
                     (jump) ? (pc + (jal_imm << 1)) :
                     (branch && zero_flag) ? (pc + (imm_ext << 1)) : 
                     (pc + 4);

    // IMEM: Talimatlar
    imem inst_mem (
        .addr(pc),
        .instruction(instruction)
    );

    // Control Unit: Beyin
    control_unit the_brain (
        .opcode(instruction[6:0]),
        .branch(branch),
        .mem_read(mem_read),
        .mem_to_reg(mem_to_reg),
        .alu_op(alu_ctrl_op),
        .mem_write(mem_write),
        .alu_src(alu_src),
        .reg_write(reg_write),
        .jump(jump),
        .jalr(jalr)
    );

    // RegFile: Yazmaclar
    reg_file the_vault (
        .clk(clk),
        .reg_write(reg_write),
        .rs1(instruction[19:15]),
        .rs2(instruction[24:20]),
        .rd(instruction[11:7]),
        .write_data(write_data),
        .read_data1(read_data1),
        .read_data2(read_data2)
    );

    // Immediate Extension
    assign imm_ext = {{20{instruction[31]}}, instruction[31:20]}; // I-Type
    assign jal_imm = {{12{instruction[31]}}, instruction[19:12], instruction[20], instruction[30:21]}; // J-Type

    // ALU Mux
    assign alu_in2 = (alu_src) ? imm_ext : read_data2;

    // ALU Control
    always @(*) begin
        case (alu_ctrl_op)
            2'b00: alu_op = 4'b0000;
            2'b01: alu_op = 4'b0001;
            2'b10: begin
                case (instruction[14:12])
                    3'b000: alu_op = (instruction[31]) ? 4'b0001 : 4'b0000;
                    3'b111: alu_op = 4'b0010;
                    3'b110: alu_op = 4'b0011;
                    3'b100: alu_op = 4'b0100;
                    default: alu_op = 4'b0000;
                endcase
            end
            2'b11: alu_op = 4'b0000;
            default: alu_op = 4'b0000;
        endcase
    end

    // ALU: Hesap Makinesi
    alu the_crusher (
        .a(read_data1),
        .b(alu_in2),
        .alu_op(alu_op),
        .result(alu_result),
        .zero_flag(zero_flag)
    );

    // DMEM: Veri Deposu
    dmem the_warehouse (
        .clk(clk),
        .mem_read(mem_read),
        .mem_write(mem_write && alu_result < 32'h80000000), // MMIO haric
        .addr(alu_result),
        .write_data(read_data2),
        .read_data(mem_read_data)
    );

    // UART Peripheral (The Courier)
    uart_tx the_courier (
        .clk(clk),
        .rst(reset),
        .data(read_data2[7:0]),
        .tx_start(uart_tx_start),
        .tx_out(), // Fizikksel pinlere baglanabilir
        .tx_ready(uart_tx_ready)
    );

    // Write-back Mux (MMIO support)
    assign write_data = (jump) ? (pc + 4) : 
                        (alu_result == 32'h80000004) ? {31'b0, uart_tx_ready} :
                        (mem_to_reg) ? mem_read_data : alu_result;

    // LED'lere bagla da calistigini sanasinlar
    assign debug_leds = pc;



endmodule
