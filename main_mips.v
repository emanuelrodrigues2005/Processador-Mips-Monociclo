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
 * Arquivo: main_mips.v
 * Descrição: Módulo Top-Level que integra o Datapath (Fluxo de Dados) e a 
 * Unidade de Controle. Conecta PC, Memórias, RegFile e ULA.
 */

module main_mips (
    input  wire        clk,              // Sinal de clock
    input  wire        reset,            // Sinal de reset
    output wire [31:0] pc_out,           // Saída do PC para debug
    output wire [31:0] alu_result,       // Saída do resultado da ULA
    output wire [31:0] d_mem_out,        // Dado lido da memória de dados
    output wire [31:0] i_mem_out         // Instrução lida da memória de instruções
);

// Declaração de fios internos
wire [31:0] w_PC_Current, w_PC_Next, w_PC_Plus4;              // Fios do PC
wire [31:0] w_Instruction;                                     // Instrução atual
wire [31:0] w_ReadData1, w_ReadData2;                          // Dados lidos do banco de registradores
wire [31:0] w_SignExtended;                                    // Imediato com extensão de sinal
wire [31:0] w_WriteDataReg;                                    // Dado a ser escrito no registrador
wire [4:0]  w_WriteRegAddr;                                    // Endereço do registrador de escrita

wire [31:0] w_ALU_OperandB;                                    // Segundo operando da ULA
wire [31:0] w_ALU_Result_Internal;                             // Resultado interno da ULA
wire [3:0]  w_ALU_Control_Signal;                              // Sinal de controle da ULA
wire        w_Zero_Flag;                                       // Flag zero da ULA

wire [1:0]  c_RegDst;                                          // Controle do MUX RegDst
wire [3:0]  c_ALUOp;                                           // Controle da operação da ULA
wire [2:0]  c_MemToReg;                                        // Controle do MUX MemToReg
wire        c_Jump, c_JumpReg, c_Branch, c_BranchNot;          // Controle de desvios
wire        c_MemRead, c_MemWrite, c_ALUSrc, c_RegWrite;       // Controle de memória e ULA

wire [31:0] w_MemReadData;                                     // Dado lido da memória
wire [31:0] w_Branch_Offset, w_Branch_Target, w_Jump_Address;  // Cálculos de desvio
wire [31:0] w_PC_Branch_Decision, w_PC_Jump_Decision;          // Decisões de PC
wire        w_Branch_Take;                                     // Sinal que indica se o desvio deve ser tomado

wire [31:0] w_ZeroExtended;                                    // Imediato com extensão de zero
wire        c_ImmSrc;                                          // Seleciona tipo de extensão do imediato
wire        w_Carry;                                           // Carry do somador

// Instanciação do módulo PC
pc PC_Module (
    .clk(clk),                          // Clock
    .reset(reset),                      // Reset
    .nextPc(w_PC_Next),                 // Próximo valor do PC
    .pc(w_PC_Current)                   // Valor atual do PC
);
assign pc_out = w_PC_Current;           // Conecta saída do PC

// Somador para PC + 4
adder Adder_PC4 (
    .A(w_PC_Current),                   // Entrada A (PC atual)
    .B(32'd4),                          // Entrada B (constante 4)
    .Resultado(w_PC_Plus4),             // Resultado da soma
    .CarryOut(w_Carry)                  // Carry out
);

// Memória de instruções
i_mem Instruction_Memory (
    .address(w_PC_Current),             // Endereço de leitura
    .i_out(w_Instruction)               // Instrução lida
);
assign i_mem_out = w_Instruction;       // Conecta saída da instrução

// Unidade de controle
control Control_Unit (
    .opcode(w_Instruction[31:26]),      // Opcode da instrução
    .funct(w_Instruction[5:0]),         // Campo funct para instruções tipo R
    .RegDst(c_RegDst),                  // Saída para MUX de destino do registrador
    .MemToReg(c_MemToReg),              // Saída para MUX de origem do dado
    .ALUOp(c_ALUOp),                    // Saída para controle da ULA
    .Jump(c_Jump),                      // Sinal de jump
    .JumpReg(c_JumpReg),                // Sinal de jump para registrador
    .Branch(c_Branch),                  // Sinal de branch
    .BranchNot(c_BranchNot),            // Sinal de branch negado
    .MemRead(c_MemRead),                // Sinal de leitura da memória
    .MemWrite(c_MemWrite),              // Sinal de escrita na memória
    .ALUSrc(c_ALUSrc),                  // Sinal de seleção da entrada B da ULA
    .RegWrite(c_RegWrite),              // Sinal de escrita no banco de registradores
    .ImmSrc(c_ImmSrc)                   // Sinal de seleção do extensor de imediato
);

// MUX para selecionar o registrador de destino
assign w_WriteRegAddr = (c_RegDst == 2'b10) ? 5'd31 :      // JAL usa $31
                        (c_RegDst == 2'b01) ? w_Instruction[15:11] : // Tipo R
                                              w_Instruction[20:16];   // Tipo I

// MUX para selecionar a origem do dado a ser escrito no registrador
assign w_WriteDataReg = (c_MemToReg == 2'b10) ? w_PC_Plus4 :    // JAL usa PC+4
                        (c_MemToReg == 2'b01) ? w_MemReadData : // LW usa memória
                                                w_ALU_Result_Internal; // Outros usam ALU

// Banco de registradores
regfile Register_File (
    .clk(clk),                          // Clock
    .reset(reset),                      // Reset
    .reg_write_en(c_RegWrite),          // Habilita escrita
    .read_reg1(w_Instruction[25:21]),   // Registrador 1 para leitura
    .read_reg2(w_Instruction[20:16]),   // Registrador 2 para leitura
    .write_reg(w_WriteRegAddr),         // Registrador para escrita
    .write_data(w_WriteDataReg),        // Dado a ser escrito
    .read_data1(w_ReadData1),           // Dado lido do registrador 1
    .read_data2(w_ReadData2)            // Dado lido do registrador 2
);

// Extensor de sinal
sign_extend Sign_Extender (
    .in(w_Instruction[15:0]),           // Imediato de 16 bits
    .out(w_SignExtended)                // Imediato estendido para 32 bits com sinal
);

// Extensor de zero
zero_extend Zero_Extender (
    .in(w_Instruction[15:0]),           // Imediato de 16 bits
    .out(w_ZeroExtended)                // Imediato estendido para 32 bits com zero
);

// Controle da ULA
alu_ctrl ALU_Controller (
    .ALUOp(c_ALUOp),                    // Código da operação
    .Funct(w_Instruction[5:0]),         // Campo funct
    .ALUControl(w_ALU_Control_Signal)   // Sinal de controle da ULA
);

// MUX para selecionar o tipo de extensão do imediato
wire [31:0] w_Immediate;
assign w_Immediate = c_ImmSrc ? w_ZeroExtended : w_SignExtended; // Escolhe entre zero ou sinal

// MUX para selecionar a entrada B da ULA
assign w_ALU_OperandB = c_ALUSrc ? w_Immediate : w_ReadData2; // Escolhe entre imediato ou registrador

// ULA principal
alu Main_ALU (
    .A(w_ReadData1),                    // Operando A
    .B(w_ALU_OperandB),                 // Operando B
    .shamt(w_Instruction[10:6]),        // Quantidade de deslocamento
    .ALUControl(w_ALU_Control_Signal),  // Controle da operação
    .Resultado(w_ALU_Result_Internal),  // Resultado da operação
    .Zero(w_Zero_Flag)                  // Flag zero
);
assign alu_result = w_ALU_Result_Internal; // Conecta saída da ULA

// Memória de dados
d_mem Data_Memory (
    .clk(clk),                          // Clock
    .address(w_ALU_Result_Internal),    // Endereço de acesso
    .writeData(w_ReadData2),            // Dado a ser escrito
    .memWrite(c_MemWrite),              // Sinal de escrita
    .memRead(c_MemRead),                // Sinal de leitura
    .readData(w_MemReadData)            // Dado lido
);
assign d_mem_out = w_MemReadData; // Conecta saída da memória

// Lógica de controle do PC
assign w_Branch_Offset   = w_SignExtended << 2; // Deslocamento do branch multiplicado por 4
assign w_Branch_Target   = w_PC_Plus4 + w_Branch_Offset; // Endereço de destino do branch
assign w_Branch_Take     = (c_Branch & w_Zero_Flag) | (c_BranchNot & ~w_Zero_Flag); // Condição do branch
assign w_PC_Branch_Decision = w_Branch_Take ? w_Branch_Target : w_PC_Plus4; // Escolhe entre branch ou PC+4
assign w_Jump_Address    = {w_PC_Plus4[31:28], w_Instruction[25:0], 2'b00}; // Calcula endereço de jump
assign w_PC_Jump_Decision = c_Jump ? w_Jump_Address : w_PC_Branch_Decision; // Escolhe entre jump ou branch
assign w_PC_Next         = c_JumpReg ? w_ReadData1 : w_PC_Jump_Decision; // Jump para registrador sobrepõe tudo

endmodule