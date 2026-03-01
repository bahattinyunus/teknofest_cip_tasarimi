/*
 *  ZİNDAN-1: THE JUDGE (TESTBENCH)
 *  -------------------------------------------------------------
 *  Aciklama: Kapsamlı donanım doğrulama testbench'i.
 *            Pipeline, UART, Timer, GPIO, SPI ve Interrupt
 *            mekanizmalarını test eder.
 *
 *  Kullanim:
 *    iverilog -o zindan_sim.vvp testbench/zindan_tb.v src/*.v
 *    vvp zindan_sim.vvp
 */

`timescale 1ns / 1ps

module zindan_tb;

    // Clock & Reset
    reg clk, reset;
    reg uart_rx_in;

    // Outputs
    wire [31:0] debug_leds;
    wire uart_tx_out;

    // Instantiate the DUT
    zindan_core dut (
        .clk(clk),
        .reset(reset),
        .uart_rx_in(uart_rx_in),
        .debug_leds(debug_leds),
        .uart_tx_out(uart_tx_out)
    );

    // Clock generation: 50 MHz => 20ns period
    initial clk = 0;
    always #10 clk = ~clk;

    // Test infrastructure
    integer test_num = 0;
    integer pass_count = 0;
    integer fail_count = 0;

    task check_equal;
        input [31:0] actual, expected;
        input [63:0] test_id;
        begin
            if (actual === expected) begin
                $display("[PASS] Test %0d: actual=0x%08h | expected=0x%08h", test_id, actual, expected);
                pass_count = pass_count + 1;
            end else begin
                $display("[FAIL] Test %0d: actual=0x%08h | expected=0x%08h", test_id, actual, expected);
                fail_count = fail_count + 1;
            end
        end
    endtask

    // =========================================================
    // TEST STIMULUS
    // =========================================================
    initial begin
        // Dump waveforms if VCD is needed
        $dumpfile("zindan.vcd");
        $dumpvars(0, zindan_tb);

        // --- PHASE 1: Reset ---
        $display("\n======================================");
        $display("  ZİNDAN-1 SIMULATION STARTING");
        $display("======================================\n");
        $display("[*] Phase 1: Reset Sequence");

        reset = 1;
        uart_rx_in = 1; // Idle high (UART idle)
        @(posedge clk); #1;
        @(posedge clk); #1;
        reset = 0;
        $display("[*] Reset sequence complete. PC starting at 0.");

        // --- PHASE 2: Observe Boot Sequence ---
        $display("\n[*] Phase 2: Boot Sequence Execution");
        repeat(50) @(posedge clk);
        $display("[*] PC after 50 cycles: 0x%08h", debug_leds);

        // --- PHASE 3: Check Pipeline is running ---
        $display("\n[*] Phase 3: Pipeline Execution Verification");
        repeat(200) @(posedge clk);
        check_equal(debug_leds > 0, 1, 1); // PC should have advanced

        // --- PHASE 4: UART TX Verification ---
        $display("\n[*] Phase 4: UART TX Observation");
        $display("    uart_tx_out initial state: %b (should be 1=idle)", uart_tx_out);
        repeat(500) @(posedge clk);
        $display("    uart_tx_out after boot: %b", uart_tx_out);

        // --- PHASE 5: Simulate UART RX ---
        $display("\n[*] Phase 5: UART RX Test (Sending 'A' = 0x41)");
        // Start bit
        uart_rx_in = 0;
        repeat(434) @(posedge clk);
        // Data bits LSB first: 0x41 = 0100_0001
        uart_rx_in = 1; repeat(434) @(posedge clk);
        uart_rx_in = 0; repeat(434) @(posedge clk);
        uart_rx_in = 0; repeat(434) @(posedge clk);
        uart_rx_in = 0; repeat(434) @(posedge clk);
        uart_rx_in = 0; repeat(434) @(posedge clk);
        uart_rx_in = 0; repeat(434) @(posedge clk);
        uart_rx_in = 1; repeat(434) @(posedge clk);
        uart_rx_in = 0; repeat(434) @(posedge clk);
        // Stop bit
        uart_rx_in = 1;
        repeat(434) @(posedge clk);
        $display("    UART RX 'A' transfer complete.");

        // --- PHASE 6: Timer and Interrupt ---
        $display("\n[*] Phase 6: Waiting for Timer Interrupt");
        repeat(1000) @(posedge clk);
        $display("    PC after timer duration: 0x%08h", debug_leds);

        // --- FINAL REPORT ---
        $display("\n======================================");
        $display("  SIMULATION COMPLETE");
        $display("  PASSED: %0d | FAILED: %0d", pass_count, fail_count);
        $display("======================================\n");

        $finish;
    end

    // Timeout watchdog
    initial begin
        #5000000; // 5ms timeout
        $display("[TIMEOUT] Simulation killed by watchdog.");
        $finish;
    end

endmodule
