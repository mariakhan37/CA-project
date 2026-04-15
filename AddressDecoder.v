// ============================================================
// AddressDecoder.v
//
// Decodes a 10-bit address (ALUResult[9:0]) into control
// signals for data memory, LED output, and switch input.
//
// Memory map (word-addressed, matching assembly program):
//   0x000 – 0x1FF  ->  Data Memory  (bit[9] = 0)
//   0x200           ->  LED Write    (bit[9]=1, bit[8]=0)
//   0x300           ->  Switch Read  (bit[9]=1, bit[8]=1)
//
// The assembly program uses:
//   t4 = 0x200  for LED writes  (SW t2, 0(t4))
//   t3 = 0x300  for switch read (LW t1, 0(t3))
// ============================================================
`timescale 1ns/1ps
module AddressDecoder (
    input      [9:0] address,      // ALUResult[9:0]
    input            readEnable,   // MemRead  from control
    input            writeEnable,  // MemWrite from control

    output reg       DataMemWrite,
    output reg       DataMemRead,
    output reg       LEDWrite,
    output reg       SwitchRead
);
    always @(*) begin
        // Default: nothing enabled
        DataMemWrite = 1'b0;
        DataMemRead  = 1'b0;
        LEDWrite     = 1'b0;
        SwitchRead   = 1'b0;

        if (address[9] == 1'b0) begin
            // ---- Normal data memory (0x000 – 0x1FF) ----
            DataMemWrite = writeEnable;
            DataMemRead  = readEnable;
        end else begin
            // ---- Memory-mapped I/O (0x200 and above) ----
            case (address[8])
                1'b0: begin
                    // 0x200 — LED register
                    LEDWrite = writeEnable;
                end
                1'b1: begin
                    // 0x300 — Switch input
                    SwitchRead = readEnable;
                end
            endcase
        end
    end
endmodule