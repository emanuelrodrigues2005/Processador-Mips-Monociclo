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
 * Arquivo: zero_extend.v
 * Descrição: Extensor de Zero. Converte o imediato de 16 bits para 32 bits,
 * preenchendo os bits superiores com zero (usado em operações lógicas como ANDI/ORI).
 */

module zero_extend (
    input  wire [15:0] in,  // Entrada de 16 bits
    output wire [31:0] out  // Saída de 32 bits
);

// Concatena 16 bits zero à esquerda com os 16 bits da entrada
assign out = {16'h0000, in};

endmodule