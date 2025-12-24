`timescale 1ns / 1ps

/*
 *  ZİNDAN-1: THE SIMULATION (TESTBENCH)
 *  -------------------------------------------------------------
 *  Aciklama: Sanal dunyada gercekligi ariyoruz.
 *  
 *  Test Senaryosu: 
 *  1. Reset at.
 *  2. Dua et.
 *  3. Sonucu gozle.
 */

module zindan_tb;

    // Inputs
    reg clk;
    reg reset;

    // Outputs
    wire [31:0] debug_leds;

    // Unit Under Test (UUT) - The Beast
    zindan_core uut (
        .clk(clk), 
        .reset(reset), 
        .debug_leds(debug_leds)
    );

    // Clock Uretimi (Kalp atislari)
    initial begin
        clk = 0;
        forever #10 clk = ~clk; // 50 MHz (Hayallerde)
    end

    // Test Senaryosu
    initial begin
        // Initialize Inputs
        reset = 1;
        
        // Wait 100 ns for global reset to finish
        #100;
        reset = 0;
        
        $display("-------------------------------------------");
        $display("ZİNDAN-1 SIMULASYONU BASLATILIYOR...");
        $display("-------------------------------------------");
        
        #50;
        $display("[INFO] Reset kaldirildi. Sistem ayakta.");
        
        #100;
        if (debug_leds !== 32'bx) begin
            $display("[SUCCESS] LED'ler yaniyor! Deger: %h", debug_leds);
        end else begin
            $display("[FAIL] Karanliktayiz... LED'ler yanmadi.");
        end

        // Finish
        #500;
        $display("-------------------------------------------");
        $display("SIMULASYON BITTI. EVE DONEBILIRSINIZ.");
        $display("-------------------------------------------");
        $finish;
    end
      
endmodule
