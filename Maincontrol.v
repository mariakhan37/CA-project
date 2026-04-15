`timescale 1ns/1ps
module Maincontrol(input wire [6:0] opcode, output reg RegWrite, output reg [1:0] ALUOp,
output reg MemRead, output reg MemWrite, output reg ALUSrc, output reg [1:0] MemtoReg,
output reg Branch, output reg Jump);
localparam R_TYPE=7'b0110011,I_ALUI=7'b0010011,LOAD=7'b0000011,STORE=7'b0100011;
localparam BRANCH=7'b1100011,LUI=7'b0110111,AUIPC=7'b0010111,JAL=7'b1101111,JALR=7'b1100111;
always @(*) begin
RegWrite=0;ALUOp=0;MemRead=0;MemWrite=0;ALUSrc=0;MemtoReg=0;Branch=0;Jump=0;
case(opcode)
R_TYPE: begin RegWrite=1;ALUOp=2'b10; end
I_ALUI: begin RegWrite=1;ALUOp=2'b11;ALUSrc=1; end
LOAD:   begin RegWrite=1;MemRead=1;ALUSrc=1;MemtoReg=2'b01; end
STORE:  begin MemWrite=1;ALUSrc=1; end
BRANCH: begin ALUOp=2'b01;Branch=1; end
LUI:    begin RegWrite=1;ALUSrc=1;MemtoReg=2'b11; end
AUIPC:  begin RegWrite=1;ALUSrc=1; end
JAL:    begin RegWrite=1;ALUSrc=1;MemtoReg=2'b10;Jump=1; end
JALR:   begin RegWrite=1;ALUSrc=1;MemtoReg=2'b10;Jump=1; end
endcase
end
endmodule