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
 * Arquivo: control.v
 * Descrição: Unidade de Controle Principal. Decodifica o Opcode (bits 31-26) e gera
 * os sinais de controle para multiplexadores, memórias e ULA.
 */

module control (
    input  wire [5:0] opcode,   // Opcode da instrução (bits 31-26)
    input  wire [5:0] funct,    // Campo funct para instruções tipo R (bits 5-0)
    
    output reg [1:0] RegDst,    // Seleção do registrador de destino
    output reg [2:0] MemToReg,  // Seleção da origem do dado para escrita no registrador
    output reg [3:0] ALUOp,     // Código da operação da ULA
    output reg       ALUSrc,    // Seleção da entrada B da ULA (registrador ou imediato)
    output reg       RegWrite,  // Habilita escrita no banco de registradores
    output reg       MemRead,   // Habilita leitura da memória de dados
    output reg       MemWrite,  // Habilita escrita na memória de dados
    output reg       Branch,    // Indica instrução de branch (BEQ)
    output reg       BranchNot, // Indica instrução de branch negado (BNE)
    output reg       Jump,      // Indica instrução de jump (J)
    output reg       JumpReg,   // Indica jump para registrador (JR)
    output reg       ImmSrc     // Seleção do tipo de extensão do imediato (zero ou sinal)
);

// Definição dos opcodes
localparam R_TYPE = 6'b000000; // Tipo R
localparam LW     = 6'b100011; // Load Word
localparam SW     = 6'b101011; // Store Word
localparam BEQ    = 6'b000100; // Branch on Equal
localparam BNE    = 6'b000101; // Branch on Not Equal
localparam ADDI   = 6'b001000; // Add Immediate
localparam ANDI   = 6'b001100; // AND Immediate
localparam ORI    = 6'b001101; // OR Immediate
localparam XORI   = 6'b001110; // XOR Immediate
localparam SLTI   = 6'b001010; // Set Less Than Immediate
localparam SLTIU  = 6'b001011; // Set Less Than Immediate Unsigned
localparam LUI    = 6'b001111; // Load Upper Immediate
localparam J      = 6'b000010; // Jump
localparam JAL    = 6'b000011; // Jump and Link

localparam FUNCT_JR = 6'b001000; // Código de Jump Register (JR)

// Bloco always para definição dos sinais de controle
always @(*) begin
    // Inicialização dos sinais com valores padrão
    RegDst   = 2'b00;   // Registrador de destino padrão (rt)
    MemToReg = 3'b000;  // Origem do dado padrão (ULA)
    ALUOp    = 4'b0000;  // Operação padrão (ADD)
    ALUSrc   = 0;       // Entrada B da ULA é do registrador
    RegWrite = 0;       // Não escreve no banco de registradores
    MemRead  = 0;       // Não lê da memória
    MemWrite = 0;       // Não escreve na memória
    Branch   = 0;       // Não é branch
    BranchNot= 0;       // Não é branch negado
    Jump     = 0;       // Não é jump
    JumpReg  = 0;       // Não é jump para registrador
    ImmSrc   = 0;       // Usa extensão de sinal por padrão

    // Case principal baseado no opcode
    case (opcode)
        R_TYPE: begin
            if (funct == FUNCT_JR) begin
                JumpReg = 1; // Ativa jump para registrador
            end 
            else begin
                RegDst   = 2'b01; // Registrador rd é destino
                RegWrite = 1;     // Habilita escrita
                ALUOp    = 4'b0010; // Indica tipo R (usa funct)
                MemToReg = 3'b000; // Dado vem da ULA
            end
        end

        LW: begin
            ALUSrc   = 1;     // Usa imediato
            MemToReg = 3'b001; // Dado vem da memória
            RegWrite = 1;     // Habilita escrita
            MemRead  = 1;     // Habilita leitura da memória
            ALUOp    = 4'b0000; // Operação ADD
        end

        SW: begin
            ALUSrc   = 1;     // Usa imediato
            MemWrite = 1;     // Habilita escrita na memória
            ALUOp    = 4'b0000; // Operação ADD
        end

        BEQ: begin
            Branch   = 1;     // Ativa branch
            ALUOp    = 4'b0001; // Operação SUB
        end
        
        BNE: begin
            BranchNot = 1;    // Ativa branch negado
            ALUOp     = 4'b0001; // Operação SUB
        end

        ADDI: begin
            ALUSrc   = 1;     // Usa imediato
            RegWrite = 1;     // Habilita escrita
            ALUOp    = 4'b0000; // Operação ADD
        end
        
        ANDI: begin 
            ALUSrc   = 1;     // Usa imediato
            RegWrite = 1;     // Habilita escrita
            ALUOp    = 3'b011; // Operação AND
            ImmSrc   = 1;     // Usa extensão de zero
        end
				
        ORI: begin
            ALUSrc   = 1;     // Usa imediato
            RegWrite = 1;     // Habilita escrita
            ALUOp    = 4'b0100; // Operação OR
            ImmSrc   = 1;     // Usa extensão de zero
        end
				
        XORI: begin
            ALUSrc   = 1;     // Usa imediato
            RegWrite = 1;     // Habilita escrita
            ALUOp    = 4'b0101; // Operação XOR
            ImmSrc   = 1;     // Usa extensão de zero
        end
				
        SLTI: begin
            ALUSrc   = 1;     // Usa imediato
            RegWrite = 1;     // Habilita escrita
            ALUOp    = 4'b0110; // Operação SLT
            ImmSrc   = 0;     // Usa extensão de sinal
        end
				
        SLTIU: begin
            ALUSrc   = 1;     // Usa imediato
            RegWrite = 1;     // Habilita escrita
            ALUOp    = 4'b1000; // Operação SLTU
            ImmSrc   = 0;     // Usa extensão de sinal
        end

        LUI: begin
            ALUSrc   = 1;     // Usa imediato
            RegWrite = 1;     // Habilita escrita
            ALUOp    = 4'b0111; // Operação LUI
        end

        J: begin
            Jump = 1;         // Ativa jump
        end

        JAL: begin
            Jump     = 1;     // Ativa jump
            RegDst   = 2'b10; // Registrador $31 é destino
            MemToReg = 3'b010; // Dado vem de PC+4
            RegWrite = 1;     // Habilita escrita
        end
            
        default: begin
            // Para instruções desconhecidas, todos os sinais permanecem em seus valores padrão (zeros).
            // ATENÇÃO: Isso pode causar comportamento inesperado se um opcode não suportado for fornecido.
        end
    endcase
end

endmodule