/**
 * alu_ctrl.v
 * brief Controlador da ULA (ALU Control) para MIPS Monociclo
 * Decodifica ALUOp (2 bits) + Funct (6 bits) -> ALUControl (4 bits)
 */

module alu_ctrl (
    input [1:0] ALUOp,       // Vem da Unidade de Controle principal
    input [5:0] Funct,       // Campo funct da instrução (bits 5-0)
    output reg [3:0] ALUControl // Comando para a ULA
);

// Definições dos códigos de operação
localparam R_TYPE = 2'b10;     // ALUOp para instruções do tipo R

// Instruções tipo R - campo Funct
localparam FUNCT_ADD  = 6'b100000;
localparam FUNCT_SUB  = 6'b100010;
localparam FUNCT_AND  = 6'b100100;
localparam FUNCT_OR   = 6'b100101;
localparam FUNCT_XOR  = 6'b100110;
localparam FUNCT_NOR  = 6'b100111;
localparam FUNCT_SLT  = 6'b101010;
localparam FUNCT_SLTU = 6'b101011;
localparam FUNCT_SLL  = 6'b000000;  
localparam FUNCT_SRL  = 6'b000010;
localparam FUNCT_SRA  = 6'b000011;
localparam FUNCT_SLLV = 6'b000100;
localparam FUNCT_SRLV = 6'b000110;
localparam FUNCT_SRAV = 6'b000111;
localparam FUNCT_JR   = 6'b001000;

// Lógica combinacional
always @(*) begin
    case (ALUOp)
        2'b00: ALUControl = 4'b0010; // LW/SW -> ADD (cálculo de endereço)
        2'b01: ALUControl = 4'b0110; // BEQ/BNE -> SUB (comparação)
        
        2'b10: begin // Tipo R - olha o Funct
            case (Funct)
                FUNCT_ADD:  ALUControl = 4'b0010; // ADD
                FUNCT_SUB:  ALUControl = 4'b0110; // SUB
                FUNCT_AND:  ALUControl = 4'b0000; // AND
                FUNCT_OR:   ALUControl = 4'b0001; // OR
                FUNCT_XOR:  ALUControl = 4'b0111; // XOR
                FUNCT_NOR:  ALUControl = 4'b1100; // NOR
                FUNCT_SLT:  ALUControl = 4'b0111; // SLT (signed)
                FUNCT_SLTU: ALUControl = 4'b0111; // SLTU (unsigned) - tratar na ULA
                // DESLOCAMENTOS: requerem tratamento especial no datapath
                FUNCT_SLL:  ALUControl = 4'b1110; // SLL (shift left logical)
                FUNCT_SRL:  ALUControl = 4'b1111; // SRL (shift right logical)
                FUNCT_SRA:  ALUControl = 4'b1011; // SRA (shift right arithmetic)
                // JR não usa ULA diretamente, é tratado no controle do PC
                default:    ALUControl = 4'b0000; // Operação segura padrão
            endcase
        end
        
        default: ALUControl = 4'b0000; // Operação segura
    endcase
end

endmodule
