/**
 * alu.v
 * Unidade Lógica Aritmética para MIPS Monociclo
 * Correções: Adicionado shamt, operações de shift e resolvido conflito XOR/SLT
 */
module alu (
    input  wire [31:0] A,          // Operando 1 (rs)
    input  wire [31:0] B,          // Operando 2 (rt ou imediato)
    input  wire [4:0]  shamt,      // Shift Amount (bits [10:6] da instrução)
    input  wire [3:0]  ALUControl, // Código de controle vindo do alu_ctrl
    output reg  [31:0] Resultado,  // Resultado da operação
    output wire        Zero        // Flag Zero para instruções de branch (BEQ)
);

    // Definição dos códigos de operação (Devem bater com alu_ctrl.v, exceto XOR corrigido)
    localparam AND = 4'b0000;
    localparam OR  = 4'b0001;
    localparam ADD = 4'b0010;
    localparam SUB = 4'b0110;
    localparam SLT = 4'b0111;  // Set on Less Than
    localparam NOR = 4'b1100;
    
    // Códigos de Shift (confome seu alu_ctrl.v)
    localparam SRA = 4'b1011;  // Shift Right Arithmetic
    localparam SLL = 4'b1110;  // Shift Left Logical
    localparam SRL = 4'b1111;  // Shift Right Logical
    
    // *** CORREÇÃO ***: XOR alterado para não colidir com SLT (altere no alu_ctrl também)
    localparam XOR = 4'b0100;  

    // Flag Zero: Ativa se o resultado for 0
    assign Zero = (Resultado == 32'b0);

    always @(*) begin
        case (ALUControl)
            ADD: Resultado = A + B;             // Soma
            SUB: Resultado = A - B;             // Subtração
            AND: Resultado = A & B;             // AND lógico
            OR:  Resultado = A | B;             // OR lógico
            XOR: Resultado = A ^ B;             // XOR lógico
            NOR: Resultado = ~(A | B);          // NOR lógico
            
            // SLT: Se A < B (com sinal), resultado é 1, senão 0
            SLT: Resultado = ($signed(A) < $signed(B)) ? 32'd1 : 32'd0;

            // Operações de Deslocamento (Shift)
            // Note que o deslocamento é feito sobre o operando B (rt) usando shamt
            SLL: Resultado = B << shamt;        
            SRL: Resultado = B >> shamt;
            SRA: Resultado = $signed(B) >>> shamt; // >>> mantém o sinal (aritmético)

            default: Resultado = 32'b0;         // Segurança
        endcase
    end
endmodule