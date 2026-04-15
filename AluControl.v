// ============================================================
// Project: ALUControl — extended for SLTI and SRA
//
// ALU encoding (matches ALU_32bit):
//   0000 = ADD    0001 = SUB    0010 = AND
//   0011 = OR     0100 = XOR    0101 = SLL
//   0110 = SRL    0111 = SLT    1000 = SRA  (NEW)
// ============================================================
`timescale 1ns/1ps
module ALUControl (
    input  wire [1:0] ALUOp,
    input  wire [2:0] funct3,
    input  wire [6:0] funct7,
    output reg  [3:0] ALUControl
);
    wire funct7_b5 = funct7[5];

    always @(*) begin
        case (ALUOp)
            2'b00: ALUControl = 4'b0000; // ADD (load/store)
            2'b01: ALUControl = 4'b0001; // SUB (branch compare)
            2'b11: begin                  // I-type ALU (ADDI, SLTI etc)
                case (funct3)
                    3'b000: ALUControl = 4'b0000; // ADDI  -> ADD
                    3'b010: ALUControl = 4'b0111; // SLTI  -> SLT (NEW)
                    3'b100: ALUControl = 4'b0100; // XORI  -> XOR
                    3'b110: ALUControl = 4'b0011; // ORI   -> OR
                    3'b111: ALUControl = 4'b0010; // ANDI  -> AND
                    3'b001: ALUControl = 4'b0101; // SLLI  -> SLL
                    3'b101: ALUControl = funct7_b5 ? 4'b1000 : 4'b0110; // SRAI/SRLI
                    default: ALUControl = 4'b0000;
                endcase
            end
            2'b10: begin                  // R-type
                case (funct3)
                    3'b000: ALUControl = funct7_b5 ? 4'b0001 : 4'b0000; // SUB/ADD
                    3'b001: ALUControl = 4'b0101; // SLL
                    3'b010: ALUControl = 4'b0111; // SLT  (NEW)
                    3'b100: ALUControl = 4'b0100; // XOR
                    3'b101: ALUControl = funct7_b5 ? 4'b1000 : 4'b0110; // SRA/SRL (NEW/existing)
                    3'b110: ALUControl = 4'b0011; // OR
                    3'b111: ALUControl = 4'b0010; // AND
                    default: ALUControl = 4'b0000;
                endcase
            end
            default: ALUControl = 4'b0000;
        endcase
    end
endmodule