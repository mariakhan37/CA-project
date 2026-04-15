`timescale 1ns/1ps
module SevenSegment (
    input         clk,
    input         rst,
    input  [15:0] value,
    output reg [6:0] seg,
    output reg [3:0] an
);
    reg [17:0] count;
    always @(posedge clk) begin
        if (rst) count <= 0;
        else     count <= count + 1;
    end

    // Top 2 bits select which digit to show
    wire [1:0] sel = count[17:16];
    reg  [3:0] nibble;

    always @(*) begin
        case (sel)
            2'b00: begin an = 4'b1110; nibble = value[3:0];   end 
            2'b01: begin an = 4'b1101; nibble = value[7:4];   end 
            2'b10: begin an = 4'b1011; nibble = value[11:8];  end 
            2'b11: begin an = 4'b0111; nibble = value[15:12]; end 
        endcase
    end

    always @(*) begin
        case (nibble)
            4'h0: seg = 7'b1000000;
            4'h1: seg = 7'b1111001;
            4'h2: seg = 7'b0100100;
            4'h3: seg = 7'b0110000;
            4'h4: seg = 7'b0011001;
            4'h5: seg = 7'b0010010;
            4'h6: seg = 7'b0000010;
            4'h7: seg = 7'b1111000;
            4'h8: seg = 7'b0000000;
            4'h9: seg = 7'b0010000;
            4'ha: seg = 7'b0001000;
            4'hb: seg = 7'b0000011;
            4'hc: seg = 7'b1000110;
            4'hd: seg = 7'b0100001;
            4'he: seg = 7'b0000110;
            4'hf: seg = 7'b0001110;
        endcase
    end

endmodule