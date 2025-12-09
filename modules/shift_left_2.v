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
 * Arquivo: shift_left_2.v
 * Descrição: Deslocador de bits. Realiza um shift left de 2 posições (multiplicação por 4),
 * necessário para alinhar endereços de Branch e Jump.
 */

module shift_left_2 (
    input  wire [31:0] in,  // Entrada de 32 bits
    output wire [31:0] out  // Saída de 32 bits após deslocamento
);

// Desloca os bits 2 posições para a esquerda e adiciona 2 bits zero à direita
assign out = {in[29:0], 2'b00};

endmodule