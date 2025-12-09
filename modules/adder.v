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
 * Arquivo: adder.v
 * Descrição: Somador Simples. Utilizado para incrementar o PC (PC+4) e calcular
 * endereços de destino para instruções de desvio (Branch).
 */

module adder #(
    parameter MODE_PC = 1'b0,         // 0: modo genérico, 1: modo PC+4
    parameter CONSTANT_B = 32'd4      // Constante usada no modo PC
)(
    input [31:0] A,                   // Primeiro operando da soma
    input [31:0] B,                   // Segundo operando (ignorado no modo PC)
    output [31:0] Resultado,          // Resultado da soma
    output CarryOut                   // Carry out da soma
);

// Seleciona entre B ou constante 4, dependendo do modo
wire [31:0] B_effective = MODE_PC ? CONSTANT_B : B;

// Realiza a soma e extrai o carry out
assign {CarryOut, Resultado} = A + B_effective;

endmodule