`timescale 1ns/1ps
module ClockDivider #(
    parameter DIV = 25000000  // divide 100MHz by 25M = 4Hz (slow enough to read)
)(
    input  clk,
    input  rst,
    output reg clk_out
);
    reg [31:0] counter;
    always @(posedge clk) begin
        if (rst) begin
            counter <= 0;
            clk_out <= 0;
        end else if (counter >= DIV-1) begin
            counter <= 0;
            clk_out <= ~clk_out;
        end else begin
            counter <= counter + 1;
        end
    end
endmodule