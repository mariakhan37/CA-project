`timescale 1ns/1ps
module DataMemory(input clk, input MemWrite, input [8:0] address, input [31:0] write_data, output [31:0] read_data);
reg [31:0] mem[0:511]; integer i;
initial begin for(i=0;i<512;i=i+1) mem[i]=0; end
always @(posedge clk) begin if(MemWrite) mem[address]<=write_data; end
assign read_data=mem[address];
endmodule