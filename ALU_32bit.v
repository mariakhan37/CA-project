// ============================================================
// Project: ALU_32bit — extended for SLT and SRA
//
// New operations added:
//   0111 = SLT  (Set Less Than — signed comparison)
//   1000 = SRA  (Shift Right Arithmetic — preserves sign bit)
// ============================================================
`timescale 1ns/1ps
module ALU_32bit (
    input  [31:0] A,
    input  [31:0] B,
    input  [3:0]  ALUControl,
    output [31:0] ALUResult,
    output        Zero
);
    reg        b_invert;
    reg [1:0]  op;
    reg        is_shift;
    reg        shift_dir;
    reg        is_slt;        // NEW: SLT flag
    reg        is_sra;        // NEW: SRA flag

    always @(*) begin
        b_invert  = 0; op = 2'b11;
        is_shift  = 0; shift_dir = 0;
        is_slt    = 0; is_sra = 0;

        case (ALUControl)
            4'b0000: begin op = 2'b11; b_invert = 0; end // ADD
            4'b0001: begin op = 2'b11; b_invert = 1; end // SUB
            4'b0010: begin op = 2'b00; b_invert = 0; end // AND
            4'b0011: begin op = 2'b01; b_invert = 0; end // OR
            4'b0100: begin op = 2'b10; b_invert = 0; end // XOR
            4'b0101: begin is_shift = 1; shift_dir = 0; end // SLL
            4'b0110: begin is_shift = 1; shift_dir = 1; end // SRL
            4'b0111: begin op = 2'b11; b_invert = 1; is_slt = 1; end // SLT (SUB then check sign)
            4'b1000: begin is_sra = 1; end                             // SRA (NEW)
            default: begin op = 2'b11; b_invert = 0; end
        endcase
    end

    // Ripple carry chain
    wire [32:0] carry;
    wire [31:0] ripple_result;
    assign carry[0] = b_invert;

    genvar i;
    generate
        for (i = 0; i < 32; i = i + 1) begin : alu_chain
            ALU_1bit slice (
                .a        (A[i]),
                .b        (B[i]),
                .carry_in (carry[i]),
                .b_invert (b_invert),
                .op       (op),
                .result   (ripple_result[i]),
                .carry_out(carry[i+1])
            );
        end
    endgenerate

    // Shift results
    wire [31:0] sll_result = A << B[4:0];
    wire [31:0] srl_result = A >> B[4:0];
    wire [31:0] sra_result = $signed(A) >>> B[4:0]; // NEW: arithmetic shift

    // SLT: result = 1 if A < B (signed), else 0
    // After SUB: if ripple_result[31]=1 -> negative -> A < B
    // But must also handle overflow: XOR sign bits
    wire        overflow = (A[31] ^ B[31]) & (A[31] ^ ripple_result[31]);
    wire        slt_bit  = ripple_result[31] ^ overflow;
    wire [31:0] slt_result = {31'b0, slt_bit}; // NEW

    // Output mux
    assign ALUResult = is_sra   ? sra_result    :
                       is_slt   ? slt_result     :
                       is_shift ? (shift_dir ? srl_result : sll_result) :
                                  ripple_result;

    assign Zero = (ALUResult == 32'b0);
endmodule