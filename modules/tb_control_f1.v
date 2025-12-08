// tb_control_f1.v
`timescale 1 ns / 1 ps

module tb_control_f1;

reg [5:0] opcode;
reg [5:0] funct;

wire [1:0] RegDst;
wire [2:0] MemToReg;
wire [1:0] ALUOp;
wire ALUSrc, RegWrite, MemRead, MemWrite, Branch, BranchNot, Jump, JumpReg;

control uut (
    .opcode(opcode),
    .funct(funct),
    .RegDst(RegDst),
    .MemToReg(MemToReg),
    .ALUOp(ALUOp),
    .ALUSrc(ALUSrc),
    .RegWrite(RegWrite),
    .MemRead(MemRead),
    .MemWrite(MemWrite),
    .Branch(Branch),
    .BranchNot(BranchNot),
    .Jump(Jump),
    .JumpReg(JumpReg)
);

initial begin
    // LW
    opcode = 6'b100011; funct = 6'b000000; #10;
    $display("LW: MemToReg=%b ALUOp=%b", MemToReg, ALUOp);

    // JAL
    opcode = 6'b000011; funct = 6'b000000; #10;
    $display("JAL: MemToReg=%b ALUOp=%b", MemToReg, ALUOp);

    // ANDI  (ALUOp deve ser 2'b11)
    opcode = 6'b001100; funct = 6'b000000; #10;
    $display("ANDI: ALUOp=%b", ALUOp);

    // R-Type ADD
    opcode = 6'b000000; funct = 6'b100000; #10;
    $display("R-Type ADD: ALUOp=%b", ALUOp);

    $stop;  // finaliza a simulação
end

endmodule