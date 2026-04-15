
`timescale 1ns/1ps
module instructionMemory #(
    parameter OPERAND_LENGTH = 31
)(
    input  [OPERAND_LENGTH:0] instAddress,
    output reg [31:0]         instruction
);
    reg [31:0] memory [0:63];
    integer i;

    initial begin
        for (i = 0; i < 64; i = i + 1)
            memory[i] = 32'h00000013; // fill with NOPs

        $readmemh("partB_sim.mem", memory);
    end

    always @(*) begin
        instruction = memory[instAddress[7:2]];
    end
endmodule