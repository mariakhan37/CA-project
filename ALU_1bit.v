`timescale 1ns/1ps
module ALU_1bit(input a, input b, input carry_in, input b_invert, input [1:0] op,
output reg result, output reg carry_out);
wire bin=b^b_invert;
wire sum=a^bin^carry_in;
wire cout=(a&bin)|(a&carry_in)|(bin&carry_in);
always @(*) begin
case(op)
2'b00: begin result=a&bin; carry_out=0; end
2'b01: begin result=a|bin; carry_out=0; end
2'b10: begin result=a^bin; carry_out=0; end
2'b11: begin result=sum;   carry_out=cout; end
default: begin result=0; carry_out=0; end
endcase
end
endmodule