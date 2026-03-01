import sys
import re

# ZİNDAN-1 (Simple RV32I-like) Assembler
# Aciklama: Assembly kodunu Verilog'un anlayacagi hex formatina cevirir.

OPCODES = {
    'add':  '0000000', 'sub':  '0100000', 'and':  '0000000', 'or':   '0000000',
    'xor':  '0000000', 'mul':  '0000001', 'addi': '0010011', 'lw':   '0000011',
    'sw':   '0100011', 'beq':  '1100011', 'jal':  '1101111'
}

REG_MAP = {f'x{i}': i for i in range(32)}
REG_MAP.update({f'r{i}': i for i in range(32)})
REG_MAP.update({'zero': 0, 'ra': 1, 'sp': 2, 'gp': 3, 'tp': 4, 't0': 5, 't1': 6, 't2': 7})

def to_bin(val, bits):
    return format(val & (2**bits - 1), f'0{bits}b')

def assemble_line(line):
    line = re.sub(r'#.*', '', line).strip()
    if not line: return None
    
    parts = re.split(r'[,\s()]+', line)
    instr = parts[0].lower()
    
    if instr == 'addi':
        rd, rs1, imm = parts[1], parts[2], int(parts[3])
        return to_bin(imm, 12) + to_bin(REG_MAP[rs1], 5) + '000' + to_bin(REG_MAP[rd], 5) + '0010011'
    
    elif instr in ['add', 'sub', 'mul', 'and', 'or', 'xor']:
        rd, rs1, rs2 = parts[1], parts[2], parts[3]
        funct7 = OPCODES[instr]
        funct3 = '000' if instr in ['add', 'sub'] else '111' if instr=='and' else '110' if instr=='or' else '100'
        return funct7 + to_bin(REG_MAP[rs2], 5) + to_bin(REG_MAP[rs1], 5) + funct3 + to_bin(REG_MAP[rd], 5) + '0110011'
    
    elif instr == 'sw':
        rs2, imm, rs1 = parts[1], int(parts[2]), parts[3]
        imm_bin = to_bin(imm, 12)
        return imm_bin[:7] + to_bin(REG_MAP[rs2], 5) + to_bin(REG_MAP[rs1], 5) + '010' + imm_bin[7:] + '0100011'

    # Simple placeholder for other types
    return f"// Unsupported instruction: {instr}"

def main():
    if len(sys.argv) < 3:
        print("Usage: python assembler.py input.asm output.hex")
        return

    with open(sys.argv[1], 'r') as f:
        lines = f.readlines()

    with open(sys.argv[2], 'w') as f:
        for line in lines:
            res = assemble_line(line)
            if res:
                hex_val = hex(int(res, 2))[2:].zfill(8)
                f.write(hex_val + '\n')

if __name__ == "__main__":
    main()
