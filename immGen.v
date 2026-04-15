module immGen(input [31:0] instruction, output reg [31:0] imm);
wire [6:0] opcode = instruction[6:0];
always @(*) begin
case(opcode)
7'h03,7'h13,7'h67: imm={{20{instruction[31]}},instruction[31:20]};
7'h23: imm={{20{instruction[31]}},instruction[31:25],instruction[11:7]};
7'h63: imm={{19{instruction[31]}},instruction[31],instruction[7],instruction[30:25],instruction[11:8],1'b0};
7'h6F: imm={{11{instruction[31]}},instruction[31],instruction[19:12],instruction[20],instruction[30:21],1'b0};
7'h37,7'h17: imm={instruction[31:12],12'b0};
default: imm=32'h0;
endcase
end
endmodule