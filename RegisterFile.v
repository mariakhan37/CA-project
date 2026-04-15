`timescale 1ns/1ps
module RegisterFile(input clk, input rst, input WriteEnable, input [4:0] rs1, input [4:0] rs2, input [4:0] rd, input [31:0] WriteData, output [31:0] ReadData1, output [31:0] ReadData2);
reg [31:0] regs[0:31]; integer i;
assign ReadData1=(rs1==5'b0)?32'b0:regs[rs1];
assign ReadData2=(rs2==5'b0)?32'b0:regs[rs2];
always @(posedge clk) begin
if(rst) begin for(i=0;i<32;i=i+1) regs[i]<=0; end
else if(WriteEnable&&rd!=5'b0) regs[rd]<=WriteData;
end
endmodule