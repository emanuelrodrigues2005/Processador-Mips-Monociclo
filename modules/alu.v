/**
 * file alu.v
 * brief Unidade Lógica Aritmética (ULA) para MIPS Monociclo
 * details Implementa operações: ADD, SUB, AND, OR, XOR, NOR, SLT
 */

module alu (
    input [31:0] A,          // Entrada A da ULA
    input [31:0] B,          // Entrada B da ULA
    input [3:0] ALUControl,  // Controle da ULA vindo do alu_ctrl
    output reg [31:0] Resultado, // Saída da operação
    output Zero              // Flag zero (para beq)
);

// Definição dos códigos de operação da ULA
localparam ADD   = 4'b0010;  // A + B
localparam SUB   = 4'b0110;  // A - B (usado para SLT e beq)
localparam AND   = 4'b0000;  // A & B
localparam OR    = 4'b0001;  // A | B
localparam XOR   = 4'b0111;  // A ^ B
localparam NOR   = 4'b1100;  // ~(A | B)
localparam SLT   = 4'b0111;  // Set on Less Than (pseudo-operação)

// Flag Zero - resultado é zero quando A == B (usado no beq)
assign Zero = (Resultado == 32'b0);

// Lógica combinacional da ULA
always @(*) begin
    case (ALUControl)
        ADD:   Resultado = A + B;                     // ADD, ADDI, LW, SW
        SUB:   Resultado = A - B;                     // SUB, BEQ (comparação)
        AND:   Resultado = A & B;                     // AND, ANDI
        OR:    Resultado = A | B;                     // OR, ORI
        XOR:   Resultado = A ^ B;                     // XOR, XORI
        NOR:   Resultado = ~(A | B);                  // NOR
        SLT:   Resultado = ($signed(A) < $signed(B)) ? 32'd1 : 32'd0; // SLT, SLTI
        default: Resultado = 32'b0;                   // Valor padrão seguro
    endcase
end

endmodule
