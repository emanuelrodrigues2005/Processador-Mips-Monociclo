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
 * Arquivo: pc.v
 * Descrição: Program Counter (Contador de Programa). Registrador síncrono que 
 * armazena o endereço da instrução atual e atualiza na borda de clock.
 */

module pc (
    input wire clk,        // Sinal de clock
    input wire reset,      // Sinal de reset
    input wire [31:0] nextPc, // Próximo valor do PC
    output reg [31:0] pc   // Valor atual do PC
);

// Bloco always para atualizar o PC
always @(posedge clk or posedge reset) begin
    if (reset) begin
        pc <= 32'b0; // Zera o PC quando reset está ativo
    end else begin 
        pc <= nextPc; // Atualiza o PC com o próximo valor
    end
end

endmodule