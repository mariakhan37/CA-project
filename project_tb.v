`timescale 1ns/1ps
module project_tb;
    reg         clk, rst;
    reg  [15:0] switches;
    wire [15:0] leds;
    initial clk = 0;
    always #5 clk = ~clk;  // 100MHz
    TopLevelProcessor uut (
        .clk            (clk),
        .rst            (rst),
        .switches       (switches),
        .leds           (leds),
        .instruction_out()
    );
    // Print every time LEDs change
    reg [15:0] leds_prev;
    always @(posedge clk) begin
        #1;
        if (leds !== leds_prev) begin
            $display("t=%0dns  PC=0x%03X  LEDs=0x%04X (%0d)  instr=0x%08X",
                $time, uut.PC, leds, leds, uut.instruction);
            leds_prev <= leds;
        end
    end
    initial begin
        rst = 1; switches = 0; leds_prev = 0;
        repeat(4) @(posedge clk);
        rst = 0;

        // PART A: uncomment switches line, set partA_sim.mem
//         switches = 16'h0006;   // countdown from 6
//         repeat(800) @(posedge clk);

        // PART B: uncomment block below, set partB_sim.mem
//                  $display("PART B: New Instructions Demo ");
//         $display("Test value: t1 = 20");
//         $display("");
//         repeat(20) @(posedge clk);

//         $display("--- SLTI: is 20 < 8? ---");
//         $display("  Operand A (t1) = 20");
//         $display("  Operand B (imm) = 8");
//         repeat(20) @(posedge clk);
//         $display("  Result (t0)    = %0d  (expect 0)", uut.regfile.regs[5]);

//         $display("");
//         $display("--- SRA: 20 >> 2 ---");
//         $display("  Operand A (t1)  = 20");
//         $display("  Shift amount    = 2");
//         repeat(20) @(posedge clk);
//         $display("  Result (t0)     = %0d  (expect 5)", uut.regfile.regs[5]);

//         $display("");
//         $display("--- BLT: is 20 < 30? ---");
//         $display("  Operand A (t1)  = 20");
//         $display("  Operand B (t2)  = 30");
//         repeat(20) @(posedge clk);
//         $display("  Branch taken    = 1  (expect 1, 20 < 30 is TRUE)");
//         $display("  LEDs final      = %0d  (expect 5)", leds);
//         repeat(200) @(posedge clk);

        // PART C: uncomment block below, set partC_sim.mem
         switches = 16'h0006;   // show first 6 fibonacci numbers
         $display(" PART C: Fibonacci Sequence ");
         $display("Input N = 6, expect: 0 -> 1 -> 1 -> 2 -> 3 -> 5");
         $display("(each LED change = next number in sequence)");
         repeat(1000) @(posedge clk);
         repeat(800) @(posedge clk);

        $finish;
    end
endmodule