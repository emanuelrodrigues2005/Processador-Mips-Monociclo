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
 * Arquivo: alu_ctrl.v
 * Descrição: Unidade de Controle da ULA. Decodifica os sinais ALUOp (da unidade principal)
 * e o campo Funct da instrução para selecionar a operação exata da ULA.
 */

module alu_ctrl (
    input [3:0] ALUOp,        // Código de operação vindo da unidade de controle principal
    input [5:0] Funct,        // Campo funct da instrução (bits 5-0)
    output reg [3:0] ALUControl // Código de operação enviado para a ULA
);

// Definição dos códigos funct para instruções tipo R
localparam FUNCT_ADD  = 6'b100000; // ADD
localparam FUNCT_SUB  = 6'b100010; // SUB
localparam FUNCT_AND  = 6'b100100; // AND
localparam FUNCT_OR   = 6'b100101; // OR
localparam FUNCT_XOR  = 6'b100110; // XOR
localparam FUNCT_NOR  = 6'b100111; // NOR
localparam FUNCT_SLT  = 6'b101010; // SLT
localparam FUNCT_SLTU = 6'b101011; // SLTU
localparam FUNCT_SLL  = 6'b000000; // SLL
localparam FUNCT_SRL  = 6'b000010; // SRL
localparam FUNCT_SRA  = 6'b000011; // SRA
localparam FUNCT_SLLV = 6'b000100; // SLLV
localparam FUNCT_SRLV = 6'b000110; // SRLV
localparam FUNCT_SRAV = 6'b000111; // SRAV

// Bloco always para definição da operação da ULA
always @(*) begin
    case (ALUOp)
        4'b0000: ALUControl = 4'b0010; // LW/SW/ADDI -> ADD
        4'b0001: ALUControl = 4'b0110; // BEQ/BNE -> SUB

        4'b0010: begin // Tipo R -> verifica funct
            case (Funct)
                FUNCT_ADD:  ALUControl = 4'b0010; // ADD
                FUNCT_SUB:  ALUControl = 4'b0110; // SUB
                FUNCT_AND:  ALUControl = 4'b0000; // AND
                FUNCT_OR:   ALUControl = 4'b0001; // OR
                FUNCT_XOR:  ALUControl = 4'b0100; // XOR
                FUNCT_NOR:  ALUControl = 4'b1100; // NOR
                FUNCT_SLT:  ALUControl = 4'b0111; // SLT
                FUNCT_SLTU: ALUControl = 4'b1001; // SLTU
                FUNCT_SLL:  ALUControl = 4'b1110; // SLL
                FUNCT_SLLV: ALUControl = 4'b0011; // SLLV
                FUNCT_SRL:  ALUControl = 4'b1111; // SRL
                FUNCT_SRLV: ALUControl = 4'b0101; // SRLV
                FUNCT_SRA:  ALUControl = 4'b1011; // SRA
                FUNCT_SRAV: ALUControl = 4'b1000; // SRAV
                default:    ALUControl = 4'b0000; // Padrão: AND
            endcase
        end

        // Instruções tipo I com operação imediata
        4'b0011: ALUControl = 4'b0000; // ANDI -> AND
        4'b0100: ALUControl = 4'b0001; // ORI  -> OR
        4'b0101: ALUControl = 4'b0100; // XORI -> XOR
        4'b0110: ALUControl = 4'b0111; // SLTI -> SLT
        4'b0111: ALUControl = 4'b1010; // LUI  -> LUI
        4'b1000: ALUControl = 4'b1001; // SLTIU -> SLTU

        default: ALUControl = 4'b0000; // Padrão: AND
    endcase
end

endmodule