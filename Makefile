# ZİNDAN-1 SoC Makefile
# Hedefler: Sim, Harden, Temizlik
#
# Dependecy: iverilog, vvp, yosys, OpenLane

DESIGN    := zindan_core
SRC       := $(wildcard src/*.v)
TOP       := $(DESIGN)
TB        := testbench/zindan_tb.v
SIM_OUT   := sim/$(DESIGN).vvp
VCD_OUT   := sim/$(DESIGN).vcd

.PHONY: all sim clean harden lint

all: sim

# Create sim directory
sim:
	@mkdir -p sim
	iverilog -g2012 -Wall -o $(SIM_OUT) $(TB) $(SRC)
	vvp $(SIM_OUT)
	@echo "[ZİNDAN] Simülasyon tamamlandı."

# View waveforms (requires gtkwave)
wave: sim
	gtkwave $(VCD_OUT) &

# Lint check with iverilog
lint:
	iverilog -g2012 -Wall -t null $(SRC)
	@echo "[ZİNDAN] Lint check passed."

# OpenLane Hardening (ASIC Flow)
# Requires OpenLane to be installed and sourced
harden:
	@echo "[ZİNDAN] ASIC Hardening başlatılıyor..."
	flow.tcl -design $(shell pwd) -tag zindan_run_$(shell date +%Y%m%d_%H%M%S)
	@echo "[ZİNDAN] Hardening tamamlandı. GDS çıktısı için 'runs/' klasörünü kontrol edin."

clean:
	rm -rf sim/
	@echo "[ZİNDAN] Temizlik tamamlandı."

# Assemble test program
asm:
	python3 tools/assembler.py tools/hello_world.asm sim/hello_world.hex
	@echo "[ZİNDAN] Derleme tamamlandı: sim/hello_world.hex"

help:
	@echo "ZİNDAN-1 SoC Makefile Yardımı"
	@echo "================================"
	@echo "  make sim    - Simülasyonu çalıştır (iverilog)"
	@echo "  make wave   - Dalgaformu görüntüle (gtkwave)"
	@echo "  make lint   - Sözdizim kontrolü yap"
	@echo "  make harden - ASIC layout üret (OpenLane)"
	@echo "  make asm    - Assembly programı derle"
	@echo "  make clean  - Geçici dosyaları temizle"
