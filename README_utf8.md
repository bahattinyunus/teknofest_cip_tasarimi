# 🔱 ZİNDAN-1: THE SILICON FRONTIER 🔱

> *"Silikon vadisinde bir kum tanesi değil, Zindan laboratuvarlarında bir elmas..."*

![System Status](https://img.shields.io/badge/System-OPERATIONAL-brightgreen?style=for-the-badge&logo=linux)
![Lithography](https://img.shields.io/badge/Lithography-130nm_SkyWater-blue?style=for-the-badge&logo=intel)
![Coffee Consumption](https://img.shields.io/badge/Coffee-CRITICAL_LEVELS-red?style=for-the-badge&logo=coffeescript)
![Sleep Status](https://img.shields.io/badge/Sleep-DEPRECATED-black?style=for-the-badge)

---

## 📜 MANİFESTO: Bir Çip Tasarım Destanı

Hoş geldiniz, yabancı. Burası sadece bir GitHub deposu değil; burası **ZİNDAN-1**, dijital mantığın fiziksel gerçeklikle çarpıştığı, `hold violation` hatalarının rüyalarımıza girdiği ve bir `GDSII` dosyasının Mona Lisa tablosundan daha değerli olduğu yerdir.

2024 yılında, bir grup cesur mühendis (bkz: Zindan Bekçileri), insanlığın en büyük sorusunu sormak için yola çıktı: 
*"Acaba kendi işlemcimizi yapıp üzerine DOOM kurabilir miyiz?"*

Cevap hâlâ belirsiz, ama süreçte öğrendiğimiz tek bir gerçek var: **Timing is everything.**

Bu proje, TEKNOFEST Çip Tasarım Yarışması için hazırlanmış olup, kan, ter ve Verilog gözyaşları içermektedir.

---

## 🏗️ SİSTEM MİMARİSİ (ZND-8086 CORE)

ZİNDAN-1, sıradan işlemcilerin korkulu rüyası, modern mimarilerin "bu ne?" diye bakıp anlam veremediği bir başyapıttır.

### 🧠 Çekirdek Özellikleri
| Özellik | Değer | Açıklama |
|Data Bus| 32-bit | Çünkü 64-bit'e kablo yetmedi. |
|Instruction Set| RISC-V (Modified) | Standartlar sıkıcıdır, biz "Kaos-V" kullanıyoruz. |
|Clock Speed| 50 MHz (Turbo) | Rüzgar arkadan eserse 55 MHz görüldü. |
|Pipeline| 5-Stage | Fetch, Decode, Execute, Memory, Regret. |
|L1 Cache| 4KB | Minimalist yaşam felsefesi. |
|Güç Tüketimi| ~100mW | Bir patatesle çalıştırılabilir. |

### 🧩 Modüler Ayrıştırma

#### 1. The Crusher (ALU - Arithmetic Logic Unit)
Sayıları toplar, çıkarır ve onlara kimin patron olduğunu gösterir. 
- **Desteklenen Operasyonlar**: ADD, SUB, XOR, OR, AND, VE "WHY_IS_THIS_NOT_WORKING" (deneysel).
- **Özellik**: Negatif sayıları sevmez, onları pozitife çevirip moral verir.

#### 2. The Traffic Cop (Control Unit)
Bütün veri trafiğini yöneten megaloman modül. Hangi verinin nereye gideceğini o belirler.
- **State Machine**: Sonsuz döngüye girmeyi çok sever.
- **Reset Politikası**: "Kapatıp aç düzelir."

#### 3. The Vault (Register File)
Verilerin kısa süreliğine konakladığı lüks otel. 
- **Kapasite**: 32 adet 32-bit register. 
- **x0 Register**: Her zaman 0 değerini verir. Dünyanın en dürüst register'ıdır. Asla yalan söylemez.

#### 4. The Bridge (Bus Interface)
Dış dünya ile iletişim kuran diplomatik birim. Bellekten veri çekerken bazen kahve molası verir (Latency).

---

## 🛠️ KURULUM VE SİMÜLASYON PROTOKOLLERİ

Eğer bu tasarımı kendi makinenizde çalıştırmak istiyorsanız, aşağıdaki **kutsal ritüelleri** sırasıyla gerçekleştirmeniz gerekmektedir. Hata yaparsanız mavi ekran almanız kaçınılmazdır.

### Gereksinimler (Pre-Requisites)
- Linux (Ubuntu 20.04 LTS veya "Ben Arch kullanıyorum" diyenler için Arch)
- Python 3.8+ (Yılan fobisi olanlar için trigger uyarısı)
- Magic VLSI (Büyücülük diploması gerektirir)
- OpenLane (Yolunu kaybedenler için)

### Adım 1: Depoyu Klonlayın (The Cloning)
Terminalinizi açın ve aşağıdaki büyülü sözcükleri fısıldayın:
```bash
git clone https://github.com/bahattinyunus/teknofest_cip_tasarimi.git
cd teknofest_cip_tasarimi
echo "Ben hazırım" > motivation.txt
```

### Adım 2: Bağımlılıkları Yükleyin (The Offering)
Bilgisayarınızın RAM'inden bir miktar kurban vererek:
```bash
sudo apt-get install -y build-essential bison flex libreadline-dev gawk tcl-dev libffi-dev git graphviz xdot pkg-config python3 libboost-system-dev libboost-python-dev libboost-filesystem-dev zlib1g-dev
# Bekleyin... Bu işlem bitene kadar bir çay demleyin.
```

### Adım 3: Simülasyonu Başlatın (The Ignition)
Eğer her şeyi doğru yaptıysanız (ki sanmıyoruz), aşağıdaki komut devreyi ayağa kaldıracaktır:
```bash
make run_simulation
```
**Beklenen Çıktı:**
```text
[INFO] Simulation Started...
[INFO] Loading ZND-8086 Core...
[INFO] ALU: "Ben hazırım patron!"
[INFO] Control Unit: "Trafik açık."
[SUCCESS] Test Passed! 
(Not: Eğer 'Segmentation Fault' alırsanız, bilgisayara sarılın ve ağlayın.)
```

### Adım 4: GDSII Üretimi (The Hardening)
Sanal tasarımı, üretime hazır bir fiziksel dosya haline getirmek için:
```bash
make harden
```
Bu işlem sırasında fanlarınız uçak kalkış sesi çıkarabilir. Endişelenmeyin, bu ses başarının sesidir.

---

## 🗺️ YOL HARİTASI (ROADMAP TO DOMINATION)

- [x] **Faz 1: Genesis**
    - [x] Repo oluşturulması.
    - [x] İlk komit ("Initial commit" yalanı).
    - [x] "Merhaba Dünya" yerine LED yakıp söndürme.

- [ ] **Faz 2: Awakening**
    - [ ] ALU'nun çarpma işlemi yapabilmesi (Zor).
    - [ ] Pipeline hazard'larının çözülmesi (Daha zor).
    - [ ] UART protokolü ile bilgisayara "Beni buradan çıkarın" mesajı yollama.

- [ ] **Faz 3: Ascension**
    - [ ] Teknofest'te final sunumu.
    - [ ] Jüriye simülasyonun video olmadığını kanıtlama.
    - [ ] Ödül töreninde sahneye robot süpürge ile çıkma.

- [ ] **Faz 4: Singularity**
    - [ ] Çipin kendi kendini yeniden tasarlaması.
    - [ ] SKYNET'in başlatılması. (Şaka, lütfen yapmayın.)

---

## 👥 ZİNDAN BEKÇİLERİ (THE FELLOWSHIP)

Bu proje, aşağıdaki **Kahraman Mühendisler** tarafından, sosyal hayatlarından feragat edilerek hazırlanmıştır:

| Kod Adı | Rütbe | Uzmanlık Alanı | Süper Gücü |
| :--- | :--- | :--- | :--- |
| **@bahattinyunus** | **Grand Architect** | System Verilog, RTL Design | Bakışlarıyla syntax hatası düzeltme. |
| **[İsim Eklenecek]** | **Lord of Layout** | Physical Design, DRC/LVS | Mikron seviyesinde kablo döşeme. |
| **[İsim Eklenecek]** | **Bug Hunter** | Verification, Testbench | Çalışan koda "ama ya çalışmazsa" deme. |
| **[İsim Eklenecek]** | **Documentation Wizard** | README Yazarı | Kelimeleri dans ettirme (bkz: şu an okuduğunuz metin). |

---

## 📜 LİSANS VE YASAL UYARILAR

Bu proje **MIT Lisansı** ile korunmaktadır. Ancak aşağıdaki ek maddeler geçerlidir:

1.  Bu kodu kullanarak bir yapay zeka geliştirip dünyayı ele geçirirseniz, bizi sorumlu tutamazsınız.
2.  Kodu kopyalayıp "ben yaptım" derseniz, rüyanızda `latch` oluşsun.
3.  Eğer bu README'yi okurken gülümsediyseniz, depoyu yıldızlamak zorundasınız ⭐.

---

> *"Silikon vadisi uzakta olabilir, ama silikon kalbimizde atıyor."*
> **— ZİNDAN-1 Takımı**

![Footer](https://capsule-render.vercel.app/api?type=waving&color=0:000000,100:333333&height=100&section=footer)
