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
 * Arquivo: i_mem.v
 * Descrição: Memória de Instruções (ROM). Lê as instruções a partir de um arquivo
 * externo e fornece o código de máquina de 32 bits baseado no endereço do PC.
 */

module i_mem #(
    parameter MEM_SIZE = 128 // Número de posições de memória (cada uma de 32 bits)
)(
    input wire [31:0] address, // Endereço de entrada (do PC)
    output wire [31:0] i_out   // Instrução de saída
);

// Declaração da memória de instruções (ROM)
reg [31:0] rom_memory [0:MEM_SIZE-1];

// Inicialização da memória com arquivo externo
initial begin
    $readmemb("/home/zauns/Desktop/aoc/Processador-Mips-Monociclo/modules/instruction.list", rom_memory);
end

// Leitura da instrução com base no endereço
// Desloca o endereço 2 bits para direita (divide por 4) para alinhar com palavras de 32 bits
assign i_out = rom_memory[address[31:2]];

endmodule