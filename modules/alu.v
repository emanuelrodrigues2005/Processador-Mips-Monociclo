/*
 * Universidade Federal Rural de Pernambuco - UFRPE
 * Disciplina: Arquitetura e Organização de Computadores - 2025.2
 * Projeto 02: Implementação de Processador MIPS Monociclo
 *
 * Grupo: 
 *  Emanuel Rodrigues
 *  Gustavo Henrique
 *  Heitor Santana
 *  João Ricardo 
 * 
 * Data: 09/12/2025
 *
 * Arquivo: alu.v
 * Descrição: Unidade Lógica e Aritmética. Executa operações matemáticas (Soma, Sub),
 * lógicas (AND, OR, XOR), shifts (SLL, SRA) e comparações (SLT, SLTU).
 */

module alu (
    input  wire [31:0] A,              // Operando A (entrada 1)
    input  wire [31:0] B,              // Operando B (entrada 2)
    input  wire [4:0]  shamt,          // Quantidade de deslocamento (shift amount)
    input  wire [3:0]  ALUControl,     // Código de controle da operação
    output reg  [31:0] Resultado,      // Resultado da operação
    output wire        Zero            // Flag que indica se o resultado é zero
);

// Definição dos códigos de operação da ULA
localparam AND   = 4'b0000; // Operação AND
localparam OR    = 4'b0001; // Operação OR
localparam ADD   = 4'b0010; // Operação ADD
localparam SUB   = 4'b0110; // Operação SUB
localparam SLT   = 4'b0111; // Set Less Than (com sinal)
localparam NOR   = 4'b1100; // Operação NOR

// Códigos de deslocamento
localparam SRA   = 4'b1011; // Shift Right Arithmetic
localparam SLL   = 4'b1110; // Shift Left Logical
localparam SRL   = 4'b1111; // Shift Right Logical

// Outras operações
localparam XOR   = 4'b0100; // Operação XOR
localparam LUI   = 4'b1010; // Load Upper Immediate
localparam SLTU  = 4'b1001; // Set Less Than Unsigned
localparam SLLV  = 4'b0011; // Shift Left Logical Variable
localparam SRLV  = 4'b0101; // Shift Right Logical Variable
localparam SRAV  = 4'b1000; // Shift Right Arithmetic Variable

// Atribuição da flag Zero
assign Zero = (Resultado == 32'b0); // Zero é 1 quando o resultado é 0

// Bloco always para definir o resultado com base no controle
always @(*) begin
    case (ALUControl)
        ADD: Resultado = A + B; // Soma
        SUB: Resultado = A - B; // Subtração
        AND: Resultado = A & B; // AND bit a bit
        OR:  Resultado = A | B; // OR bit a bit
        XOR: Resultado = A ^ B; // XOR bit a bit
        NOR: Resultado = ~(A | B); // NOR bit a bit

        // Comparação com sinal
        SLT: Resultado = ($signed(A) < $signed(B)) ? 32'd1 : 32'd0; // 1 se A < B (com sinal)

        // Comparação sem sinal
        SLTU: Resultado = (A < B) ? 32'd1 : 32'd0; // 1 se A < B (sem sinal)

        // Deslocamentos com shamt constante
        SLL: Resultado = B << shamt; // Desloca B para a esquerda
        SRL: Resultado = B >> shamt; // Desloca B para a direita (lógico)
        SRA: Resultado = $signed(B) >>> shamt; // Desloca B para a direita (aritmético)

        // Deslocamentos com valor variável (registrador A)
        SLLV: Resultado = B << A[4:0]; // Desloca B para a esquerda com valor de A
        SRLV: Resultado = B >> A[4:0]; // Desloca B para a direita (lógico) com valor de A
        SRAV: Resultado = $signed(B) >>> A[4:0]; // Desloca B para a direita (aritmético) com valor de A

        // Load Upper Immediate
        LUI: Resultado = B << 16; // Desloca imediato 16 bits para esquerda

        default: Resultado = 32'b0; // Resultado zero para operação desconhecida
    endcase
end

endmodule