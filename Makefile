# ZİNDAN-1 MAKEFILE
# "Derlemiyor, sadece insa ediyor."

# Derleyici (Varsayilan: iverilog)
CC = iverilog
# Simulasyon Yurutucu
SIM = vvp

# Dosyalar
SRC = src/alu.v src/control_unit.v src/zindan_core.v
TB = testbench/zindan_tb.v
OUT = simulation.out

# Hedefler
all: help

help:
	@echo "----------------------------------------------------------------"
	@echo "ZİNDAN-1 YONETIM PANELI"
	@echo "----------------------------------------------------------------"
	@echo "Mevcut Komutlar:"
	@echo "  make run_simulation  -> Simulasyonu baslatir (cesaretin varsa)"
	@echo "  make harden          -> GDSII dosyalarini uretir (saka)"
	@echo "  make clean           -> Ortaligi toplar"
	@echo "----------------------------------------------------------------"

run_simulation:
	@echo "[INFO] Simulation Started..."
	@echo "[INFO] Loading ZND-8086 Core..."
	@$(CC) -o $(OUT) $(SRC) $(TB)
	@$(SIM) $(OUT)
	@echo "[INFO] Eger yukarida bir hata gormediysen, mucize gerceklesti."

harden:
	@echo "[INFO] GDSII Hardening Process Initiated..."
	@echo "[....] Fan hizi arttiriliyor..."
	@echo "[....] CPU sicakligi yukseliyor..."
	@echo "[ERROR] Lisans bulunamadi. Lutfen 1 milyon dolar odeyin."
	@echo "[INFO] Saka saka. Henuz OpenLane config dosyalari hazir degil."

clean:
	rm -f $(OUT) *.vcd
	@echo "[INFO] Copler disari atildi."
