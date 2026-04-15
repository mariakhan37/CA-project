`timescale 1ns/1ps
module TopLevelProcessor_fpga (
    input         clk,       // 100 MHz system clock
    input         btnC,      // reset (active HIGH)
    input  [15:0] sw,
    output [15:0] led,
    output [6:0]  seg,
    output [3:0]  an,
    output        dp);
    assign dp = 1'b1;  
    wire proc_clk;
    ClockDivider #(.DIV(25_000_000)) slow_clk_div (
        .clk    (clk),
        .rst    (btnC),
        .clk_out(proc_clk)  );
    wire [31:0] instr_out;
    wire [15:0] leds_out;
    TopLevelProcessor proc (
        .clk            (proc_clk),   // <-- slow clock
        .rst            (btnC),
        .switches       (sw),
        .leds           (leds_out),
        .instruction_out(instr_out));
    assign led = leds_out;
    SevenSegment sseg (
        .clk   (clk),          // fast clock for clean digit mux
        .rst   (btnC),
        .value (instr_out[15:0]),
        .seg   (seg),
        .an    (an) );
endmodule