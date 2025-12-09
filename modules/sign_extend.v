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
 * Arquivo: sign_extend.v
 * Descrição: Extensor de Sinal. Converte o imediato de 16 bits para 32 bits,
 * replicando o bit de sinal (bit 15) para os bits superiores.
 */

module sign_extend (
    input  wire [15:0] in,  // Entrada de 16 bits
    output wire [31:0] out  // Saída de 32 bits
);

// Replica o bit 15 (sinal) 16 vezes e concatena com os 16 bits da entrada
assign out = {{16{in[15]}}, in};

endmodule