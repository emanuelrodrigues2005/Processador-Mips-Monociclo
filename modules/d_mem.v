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
 * Arquivo: d_mem.v
 * Descrição: Memória de Dados (RAM). Permite leitura assíncrona e escrita síncrona
 * de dados de 32 bits, utilizada pelas instruções LW e SW.
 */

module d_mem #(
    parameter MAX_SIZE = 128,              // Número máximo de posições da memória
    parameter ADDRESS_SIZE = 32,           // Tamanho do endereço em bits
    parameter DATA_SIZE = 32               // Tamanho dos dados em bits
)(
    input wire clk,                        // Sinal de clock
    input wire [ADDRESS_SIZE-1:0] address, // Endereço de acesso
    input wire [DATA_SIZE-1:0] writeData,  // Dado a ser escrito
    input wire memWrite,                   // Sinal de escrita na memória
    input wire memRead,                    // Sinal de leitura da memória
    output wire [DATA_SIZE-1:0] readData   // Dado lido da memória
);

// Declaração da memória RAM (array de registros de 32 bits)
reg [DATA_SIZE-1:0] ram_memory [0:MAX_SIZE-1];

// Leitura assíncrona
// Desloca o endereço 2 bits para direita (divide por 4) para alinhar com palavras de 32 bits
assign readData = (memRead) ? ram_memory[address[31:2]] : {DATA_SIZE{1'bz}}; // Retorna dado ou alta impedância

// Bloco always para escrita síncrona
always @(posedge clk) begin
    if (memWrite) begin
        ram_memory[address[31:2]] <= writeData; // Escreve dado no endereço alinhado
    end
end

// Inicialização da memória
integer i;
initial begin
    for (i = 0; i < MAX_SIZE; i = i + 1) begin
        ram_memory[i] = {DATA_SIZE{1'b0}}; // Zera todas as posições da memória
    end
end

endmodule