/**
 * adder.v
 * Somador para MIPS Monociclo
 * Unifica adder_32 e adder_32_pc em um único módulo configurável
 * 
 * MODO DE USO:
 * - Modo normal: Conecte A e B para soma genérica
 * - Modo PC+4: Conecte apenas A, B será automaticamente 4
 */

module adder #(
    parameter MODE_PC = 1'b0,  // 0=modo genérico, 1=modo PC+4
    parameter CONSTANT_B = 32'd4  // Constante para modo PC (padrão: 4)
)(
    input [31:0] A,          // Entrada A (obrigatória)
    input [31:0] B,          // Entrada B 
    output [31:0] Resultado, // A + B (ou A + CONSTANT_B no modo PC)
    output CarryOut          
);

// Modo PC+4: usa constante interna, ignora entrada B
wire [31:0] B_effective = MODE_PC ? CONSTANT_B : B;

// Operação de soma
assign {CarryOut, Resultado} = A + B_effective;

endmodule
