/**
 * control.v
 * Unidade de Controle Principal do MIPS Monociclo.
 * Responsável por decodificar o Opcode e gerar sinais para os MUXes e Memórias.
 */
module control (
    input  wire [5:0] opcode,  // Bits 31-26 da instrução [cite: 87]
    input  wire [5:0] funct,   // Bits 5-0 (Necessário apenas para identificar JR)
    
    // Sinais de Saída para o Datapath
    output reg [1:0] RegDst,   // 00=rt, 01=rd, 10=$31 (para JAL)
    output reg [2:0] MemToReg, // 00=ULA, 01=Mem, 10=PC+4 (para JAL)
    output reg [1:0] ALUOp,    // 00=Add/LW/SW, 01=Branch, 10=R-Type
    output reg       ALUSrc,   // 0=RegB, 1=Imediato
    output reg       RegWrite, // Habilita escrita no banco de registradores
    output reg       MemRead,  // Habilita leitura da memória de dados
    output reg       MemWrite, // Habilita escrita na memória de dados
    output reg       Branch,   // Sinal para BEQ
    output reg       BranchNot,// Sinal para BNE [cite: 101]
    output reg       Jump,     // Sinal para J e JAL
    output reg       JumpReg   // Sinal exclusivo para JR (Jump Register)
);

    // Definição dos Opcodes 
    localparam R_TYPE = 6'b000000;
    localparam LW     = 6'b100011; // I.10 [cite: 101]
    localparam SW     = 6'b101011; // I.11 [cite: 102]
    localparam BEQ    = 6'b000100; // I.5
    localparam BNE    = 6'b000101; // I.6
    localparam ADDI   = 6'b001000; // I.1
    localparam ANDI   = 6'b001100; // I.2
    localparam J      = 6'b000010; // J.1 
    localparam JAL    = 6'b000011; // J.2
    
    // Funct específico para JR (R-Type)
    localparam FUNCT_JR = 6'b001000; // R.15 [cite: 94]

    always @(*) begin
        // 1. Resetar todos os sinais para 0 (evita latches e estados indefinidos)
        RegDst   = 2'b00;
        MemToReg = 3'b000;
        ALUOp    = 2'b00;
        ALUSrc   = 0;
        RegWrite = 0;
        MemRead  = 0;
        MemWrite = 0;
        Branch   = 0;
        BranchNot= 0;
        Jump     = 0;
        JumpReg  = 0;

        // 2. Decodificação baseada no Opcode
        case (opcode)
            R_TYPE: begin
                // Verifica se é JR (Jump Register)
                if (funct == FUNCT_JR) begin
                    JumpReg = 1; // Ativa sinal para pular para valor do registrador
                    // JR não escreve em reg e não usa ULA padrão
					 end 
                else begin
                    RegDst   = 2'b01; // Destino é rd (bits 15-11)
                    RegWrite = 1;     // Escreve no registrador
                    ALUOp    = 2'b10; // Instrui ALU_Ctrl a olhar o campo Funct
                    MemToReg = 3'b000;
                end
            end

            LW: begin
                ALUSrc   = 1;     // Usa Imediato (endereço + offset)
                MemToReg = 3'b001; // Dado vem da Memória
                RegWrite = 1;     // Escreve no Rt
                MemRead  = 1;     // Habilita leitura da RAM
                ALUOp    = 2'b00; // ALU deve somar
            end

            SW: begin
                ALUSrc   = 1;     // Usa Imediato (endereço + offset)
                MemWrite = 1;     // Habilita escrita na RAM
                ALUOp    = 2'b00; // ALU deve somar
                // RegWrite=0 (não escreve em registrador)
            end

            BEQ: begin
                Branch   = 1;     // Sinaliza Branch Equal
                ALUOp    = 2'b01; // ALU deve subtrair para comparar
                // RegWrite=0
            end
            
            BNE: begin
                BranchNot = 1;    // Sinaliza Branch Not Equal
                ALUOp     = 2'b01; // ALU deve subtrair para comparar
            end

            ADDI: begin
                ALUSrc   = 1;     // Usa Imediato
                RegWrite = 1;     // Escreve no Rt
                ALUOp    = 2'b00; // Soma
            end
            
            // Tratamento simplificado para ANDI, ORI, XORI (Tipo I Lógicos)
            // Normalmente requerem ALUOp específico, aqui generalizado:
            ANDI: begin 
					ALUSrc=1;
					RegWrite=1;
					ALUOp=2'b11;
				end // Requer ajuste no ALU Ctrl se implementar full

            J: begin
                Jump = 1; // Ativa lógica de Jump incondicional
            end

            JAL: begin
                Jump     = 1;
                RegDst   = 2'b10; // Destino forçado para $31 ($ra)
                MemToReg = 3'b010; // Dado a escrever é PC+4 (Link)
                RegWrite = 1;     // Habilita escrita
            end
            
            default: begin
                // Mantém tudo zero por segurança
            end
        endcase
    end
endmodule