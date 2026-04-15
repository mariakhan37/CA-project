`timescale 1ns/1ps
module TopLevelProcessor (
    input         clk,
    input         rst,
    input  [15:0] switches,
    output [15:0] leds,
    output [31:0] instruction_out   // <-- NEW: expose for 7-seg display
);
    wire [31:0] PC, PCPlus4, branchTarget, nextPC;
    wire        PCSrc;

    wire [31:0] instruction;
    assign instruction_out = instruction;  // drive the new output

    wire [6:0]  opcode   = instruction[6:0];
    wire [4:0]  rd_addr  = instruction[11:7];
    wire [2:0]  funct3   = instruction[14:12];
    wire [4:0]  rs1_addr = instruction[19:15];
    wire [4:0]  rs2_addr = instruction[24:20];
    wire [6:0]  funct7   = instruction[31:25];

    wire [31:0] imm;
    wire        RegWrite, MemRead, MemWrite_ctrl, ALUSrc, Branch, Jump;
    wire [1:0]  ALUOp, MemtoReg;
    wire [3:0]  aluCtrlOut;
    wire [31:0] ALU_B, ALUResult;
    wire        Zero;
    wire [31:0] ReadData1, ReadData2, RegWriteData;
    wire        DataMemWrite, DataMemRead, LEDWrite, SwitchRead;
    wire [31:0] mem_read_data;
    reg  [31:0] led_reg;
    assign leds = led_reg[15:0];

    // ----------------------------------------------------------
    // Branch condition — BEQ, BNE, BLT, BGE
    // signed_lt uses overflow-corrected comparison so BLT works
    // correctly even when subtraction overflows.
    // ----------------------------------------------------------
    wire signed_lt = ALUResult[31] ^
                     ((ReadData1[31] ^ ReadData2[31]) & (ReadData1[31] ^ ALUResult[31]));

    wire branch_taken =
        (funct3 == 3'b000) ?  Zero       :  // BEQ
        (funct3 == 3'b001) ? ~Zero       :  // BNE
        (funct3 == 3'b100) ?  signed_lt  :  // BLT
        (funct3 == 3'b101) ? ~signed_lt  :  // BGE
        1'b0;

    assign PCSrc = (Branch & branch_taken) | Jump;

    // JALR target: rs1 + imm
    wire        isJALR     = (opcode == 7'b1100111);
    wire [31:0] jalrTarget = ReadData1 + imm;
    wire [31:0] jumpTarget = isJALR ? jalrTarget : branchTarget;

    // 1. Program Counter
    ProgramCounter pc_reg (.clk(clk),.rst(rst),.nextPC(nextPC),.PC(PC));

    // 2. PC + 4
    pcAdder pc_add (.PC(PC),.PCPlus4(PCPlus4));

    // 3. Branch target
    branchAdder br_add (.PC(PC),.imm(imm),.branchTarget(branchTarget));

    // 4. Next PC mux
    mux2 pc_mux (.in0(PCPlus4),.in1(jumpTarget),.sel(PCSrc),.out(nextPC));

    // 5. Instruction Memory
    instructionMemory #(.OPERAND_LENGTH(31)) imem (
        .instAddress(PC),.instruction(instruction));

    // 6. Immediate Generator
    immGen imm_gen (.instruction(instruction),.imm(imm));

    // 7. Main Control
    Maincontrol ctrl (
        .opcode(opcode),.RegWrite(RegWrite),.ALUOp(ALUOp),
        .MemRead(MemRead),.MemWrite(MemWrite_ctrl),.ALUSrc(ALUSrc),
        .MemtoReg(MemtoReg),.Branch(Branch),.Jump(Jump));

    // 8. Register File
    RegisterFile regfile (
        .clk(clk),.rst(rst),.WriteEnable(RegWrite),
        .rs1(rs1_addr),.rs2(rs2_addr),.rd(rd_addr),
        .WriteData(RegWriteData),.ReadData1(ReadData1),.ReadData2(ReadData2));

    // 9. ALU Source Mux
    mux2 alu_src_mux (.in0(ReadData2),.in1(imm),.sel(ALUSrc),.out(ALU_B));

    // 10. ALU Control
    ALUControl alu_ctrl (
        .ALUOp(ALUOp),.funct3(funct3),.funct7(funct7),.ALUControl(aluCtrlOut));

    // 11. ALU
    ALU_32bit alu (
        .A(ReadData1),.B(ALU_B),.ALUControl(aluCtrlOut),
        .ALUResult(ALUResult),.Zero(Zero));

    // 12. Address Decoder
    AddressDecoder addr_dec (
        .address(ALUResult[9:0]),.readEnable(MemRead),.writeEnable(MemWrite_ctrl),
        .DataMemWrite(DataMemWrite),.DataMemRead(DataMemRead),
        .LEDWrite(LEDWrite),.SwitchRead(SwitchRead));

    // 13. Data Memory
    DataMemory dmem (
        .clk(clk),.MemWrite(DataMemWrite),
        .address(ALUResult[8:0]),.write_data(ReadData2),.read_data(mem_read_data));

    // 14. LED register — updated only when LEDWrite is asserted
    always @(posedge clk) begin
        if (rst)           led_reg <= 32'b0;
        else if (LEDWrite) led_reg <= ReadData2;
    end

    // Switch input override: when SwitchRead, return switch value instead of memory
    wire [31:0] effective_read_data = SwitchRead ? {16'b0, switches} : mem_read_data;

    // 15. Write-back Mux
    assign RegWriteData =
        (MemtoReg == 2'b00) ? ALUResult           :
        (MemtoReg == 2'b01) ? effective_read_data  :
        (MemtoReg == 2'b10) ? PCPlus4              :
                               imm;
endmodule