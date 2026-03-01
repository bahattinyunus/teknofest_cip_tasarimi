/*
 *  ZİNDAN-1: THE CORE (5-STAGE PIPELINE)
 *  -------------------------------------------------------------
 *  Aciklama: Tek donguden (single-cycle) 5 asamali pipeline 
 *            mimarisine gecis yapilmis, kuresel standartlarda bir cekirdek.
 *  
 *  Asamalar: IF (Fetch), ID (Decode), EX (Execute), MEM (Memory), WB (Writeback)
 */

module zindan_core (
    input clk,
    input reset,
    output [31:0] debug_leds,
    output uart_tx_out
);

    // --- PIPELINE KAYITCILARI (PIPELINE REGISTERS) ---
    
    // IF/ID Registers
    reg [31:0] if_id_pc, if_id_instr;

    // ID/EX Registers
    reg [31:0] id_ex_pc, id_ex_instr, id_ex_read_data1, id_ex_read_data2, id_ex_imm;
    reg [4:0]  id_ex_rd, id_ex_rs1, id_ex_rs2;
    reg        id_ex_branch, id_ex_mem_read, id_ex_mem_to_reg, id_ex_mem_write, id_ex_alu_src, id_ex_reg_write, id_ex_jump, id_ex_jalr;
    reg [1:0]  id_ex_alu_ctrl_op;

    // EX/MEM Registers
    reg [31:0] ex_mem_alu_result, ex_mem_write_data, ex_mem_pc_plus_4;
    reg [4:0]  ex_mem_rd;
    reg        ex_mem_mem_read, ex_mem_mem_to_reg, ex_mem_mem_write, ex_mem_reg_write, ex_mem_jump;

    // MEM/WB Registers
    reg [31:0] mem_wb_mem_read_data, mem_wb_alu_result, mem_wb_pc_plus_4;
    reg [4:0]  mem_wb_rd;
    reg        mem_wb_mem_to_reg, mem_wb_reg_write, mem_wb_jump;

    // --- INTERNALS & WIRES ---
    wire [31:0] pc_plus_4, next_pc;
    wire [31:0] instruction;
    wire [31:0] reg_read_data1, reg_read_data2;
    wire [31:0] imm_ext, jal_imm;
    wire [31:0] alu_in1, alu_in2, alu_result;
    wire [31:0] mem_read_data;
    wire [31:0] write_back_data;
    wire [1:0]  alu_ctrl_op_wire;
    wire        branch_wire, mem_read_wire, mem_to_reg_wire, mem_write_wire, alu_src_wire, reg_write_wire, jump_wire, jalr_wire;
    wire        zero_flag;
    reg  [31:0] pc;
    reg  [3:0]  alu_op;

    // Hazard wires
    wire [1:0] forward_a, forward_b;
    wire stall_if, stall_id, flush_ex;
    reg [31:0] alu_fwd_a, alu_fwd_b;

    // --- STAGE 1: FETCH (IF) ---
    assign pc_plus_4 = pc + 4;
    
    // PC Hiyerarsisi
    assign next_pc = (id_ex_jalr) ? (alu_fwd_a + id_ex_imm) :
                     (id_ex_jump) ? (id_ex_pc + (jal_imm << 1)) :
                     (id_ex_branch && zero_flag) ? (id_ex_pc + (id_ex_imm << 1)) : 
                     (stall_if) ? pc : (pc + 4);

    always @(posedge clk or posedge reset) begin
        if (reset) pc <= 32'b0;
        else if (!stall_if) pc <= next_pc;
    end

    imem inst_mem (.addr(pc), .instruction(instruction));

    always @(posedge clk or posedge reset) begin
        if (reset) begin
            if_id_pc <= 0;
            if_id_instr <= 0;
        end else if (!stall_id) begin
            if_id_pc <= pc;
            if_id_instr <= (id_ex_jump || id_ex_jalr || (id_ex_branch && zero_flag)) ? 32'h00000013 : instruction; // Flush logic
        end
    end

    // --- STAGE 2: DECODE (ID) ---
    control_unit the_brain (
        .opcode(if_id_instr[6:0]),
        .branch(branch_wire), .mem_read(mem_read_wire), .mem_to_reg(mem_to_reg_wire),
        .alu_op(alu_ctrl_op_wire), .mem_write(mem_write_wire), .alu_src(alu_src_wire),
        .reg_write(reg_write_wire), .jump(jump_wire), .jalr(jalr_wire)
    );

    reg_file the_vault (
        .clk(clk), .reg_write(mem_wb_reg_write),
        .rs1(if_id_instr[19:15]), .rs2(if_id_instr[24:20]), .rd(mem_wb_rd),
        .write_data(write_back_data),
        .read_data1(reg_read_data1), .read_data2(reg_read_data2)
    );

    assign imm_ext = {{20{if_id_instr[31]}}, if_id_instr[31:20]};

    always @(posedge clk or posedge reset) begin
        if (reset || flush_ex) begin
            {id_ex_branch, id_ex_mem_read, id_ex_mem_to_reg, id_ex_mem_write, id_ex_alu_src, id_ex_reg_write, id_ex_jump, id_ex_jalr} <= 0;
        end else begin
            id_ex_pc <= if_id_pc;
            id_ex_instr <= if_id_instr;
            id_ex_read_data1 <= reg_read_data1;
            id_ex_read_data2 <= reg_read_data2;
            id_ex_imm <= imm_ext;
            id_ex_rd <= if_id_instr[11:7];
            id_ex_rs1 <= if_id_instr[19:15];
            id_ex_rs2 <= if_id_instr[24:20];
            id_ex_branch <= branch_wire;
            id_ex_mem_read <= mem_read_wire;
            id_ex_mem_to_reg <= mem_to_reg_wire;
            id_ex_mem_write <= mem_write_wire;
            id_ex_alu_src <= alu_src_wire;
            id_ex_reg_write <= reg_write_wire;
            id_ex_jump <= jump_wire;
            id_ex_jalr <= jalr_wire;
            id_ex_alu_ctrl_op <= alu_ctrl_op_wire;
        end
    end

    // --- STAGE 3: EXECUTE (EX) ---
    hazard_unit the_guardian (
        .id_ex_rs1(id_ex_rs1), .id_ex_rs2(id_ex_rs2),
        .ex_mem_rd(ex_mem_rd), .mem_wb_rd(mem_wb_rd),
        .ex_mem_reg_write(ex_mem_reg_write), .mem_wb_reg_write(mem_wb_reg_write),
        .id_ex_mem_read(id_ex_mem_read), .if_id_rs1(if_id_instr[19:15]), .if_id_rs2(if_id_instr[24:20]),
        .id_ex_rd(id_ex_rd),
        .forward_a(forward_a), .forward_b(forward_b),
        .stall_if(stall_if), .stall_id(stall_id), .flush_ex(flush_ex)
    );

    // Forwarding logic
    always @(*) begin
        case (forward_a)
            2'b10: alu_fwd_a = ex_mem_alu_result;
            2'b01: alu_fwd_a = write_back_data;
            default: alu_fwd_a = id_ex_read_data1;
        endcase
        case (forward_b)
            2'b10: alu_fwd_b = ex_mem_alu_result;
            2'b01: alu_fwd_b = write_back_data;
            default: alu_fwd_b = id_ex_read_data2;
        endcase
    end

    assign alu_in1 = alu_fwd_a;
    assign alu_in2 = (id_ex_alu_src) ? id_ex_imm : alu_fwd_b;
    assign jal_imm = {{12{id_ex_instr[31]}}, id_ex_instr[19:12], id_ex_instr[20], id_ex_instr[30:21]};

    always @(*) begin
        case (id_ex_alu_ctrl_op)
            2'b00: alu_op = 4'b0000;
            2'b01: alu_op = 4'b0001;
            2'b10: begin
                case (id_ex_instr[14:12])
                    3'b000: alu_op = (id_ex_instr[31]) ? 4'b0001 : 4'b0000;
                    3'b111: alu_op = 4'b0010;
                    3'b110: alu_op = 4'b0011;
                    3'b100: alu_op = 4'b0100;
                    3'b101: alu_op = 4'b0101; // MUL
                    default: alu_op = 4'b0000;
                endcase
            end
            2'b11: alu_op = 4'b0000;
            default: alu_op = 4'b0000;
        endcase
    end


    alu the_crusher (.a(alu_in1), .b(alu_in2), .alu_op(alu_op), .result(alu_result), .zero_flag(zero_flag));

    always @(posedge clk or posedge reset) begin
        if (reset) begin
            ex_mem_reg_write <= 0;
            ex_mem_mem_read <= 0;
            ex_mem_mem_write <= 0;
        end else begin
            ex_mem_alu_result <= alu_result;
            ex_mem_write_data <= id_ex_read_data2;
            ex_mem_rd <= id_ex_rd;
            ex_mem_reg_write <= id_ex_reg_write;
            ex_mem_mem_read <= id_ex_mem_read;
            ex_mem_mem_write <= id_ex_mem_write;
            ex_mem_mem_to_reg <= id_ex_mem_to_reg;
            ex_mem_jump <= id_ex_jump;
            ex_mem_pc_plus_4 <= id_ex_pc + 4;
        end
    end

    // --- STAGE 4: MEMORY (MEM) ---
    dmem the_warehouse (
        .clk(clk), .mem_read(ex_mem_mem_read), .mem_write(ex_mem_mem_write && ex_mem_alu_result < 32'h80000000),
        .addr(ex_mem_alu_result), .write_data(ex_mem_write_data), .read_data(mem_read_data)
    );

    // UART
    uart_tx the_courier (
        .clk(clk), .rst(reset), .data(ex_mem_write_data[7:0]),
        .tx_start(ex_mem_mem_write && ex_mem_alu_result == 32'h80000000),
        .tx_out(uart_tx_out), .tx_ready()
    );

    always @(posedge clk or posedge reset) begin
        if (reset) begin
            mem_wb_reg_write <= 0;
        end else begin
            mem_wb_mem_read_data <= (ex_mem_alu_result == 32'h80000004) ? 32'b1 : mem_read_data; // Mock UART ready
            mem_wb_alu_result <= ex_mem_alu_result;
            mem_wb_rd <= ex_mem_rd;
            mem_wb_reg_write <= ex_mem_reg_write;
            mem_wb_mem_to_reg <= ex_mem_mem_to_reg;
            mem_wb_jump <= ex_mem_jump;
            mem_wb_pc_plus_4 <= ex_mem_pc_plus_4;
        end
    end

    // --- STAGE 5: WRITEBACK (WB) ---
    assign write_back_data = (mem_wb_jump) ? mem_wb_pc_plus_4 :
                             (mem_wb_mem_to_reg) ? mem_wb_mem_read_data : mem_wb_alu_result;

    // --- NEXT PC LOGIC & HAZARDS (Simplified) ---
    // Simple Next PC (No branches implemented in pipeline stages yet for simplicity in this step)
    assign next_pc = pc + 4; 

    // LED'ler
    assign debug_leds = pc;

endmodule
