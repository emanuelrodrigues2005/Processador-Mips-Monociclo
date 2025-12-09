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
 * Arquivo: regfile.v
 * Descrição: Banco de Registradores. Contém 32 registradores de 32 bits ($0-$31).
 * Possui duas portas de leitura e uma porta de escrita controlada por sinal.
 */

module regfile (
    input wire clk,                          // Sinal de clock
    input wire reset,                        // Sinal de reset
    input wire reg_write_en,                 // Habilitação de escrita no banco
    input wire [4:0] read_reg1,              // Endereço do registrador 1 para leitura
    input wire [4:0] read_reg2,              // Endereço do registrador 2 para leitura
    input wire [4:0] write_reg,              // Endereço do registrador para escrita
    input wire [31:0] write_data,            // Dado a ser escrito
    output wire [31:0] read_data1,           // Dado lido do registrador 1
    output wire [31:0] read_data2            // Dado lido do registrador 2
);

// Declaração do banco de registradores (32 registradores de 32 bits)
reg [31:0] registers [31:0];

// Índice para loops
integer i;

// Leitura assíncrona do registrador 1
// Se o endereço for 0, retorna 0 (registrador s0 é sempre zero)
assign read_data1 = (read_reg1 == 0) ? 32'b0 : registers[read_reg1];

// Leitura assíncrona do registrador 2
// Se o endereço for 0, retorna 0 (registrador s0 é sempre zero)
assign read_data2 = (read_reg2 == 0) ? 32'b0 : registers[read_reg2];

// Bloco always para escrita síncrona e reset
always @(posedge clk or posedge reset) begin
    if (reset) begin
        // Em caso de reset, zera todos os registradores
        for (i = 0; i < 32; i = i + 1) begin
            registers[i] <= 32'b0;
        end
    end
    else begin
        // Escrita síncrona, somente se habilitada e o registrador não for o s0
        if (reg_write_en && write_reg != 0) begin
            registers[write_reg] <= write_data;
        end
    end
end

endmodule