/**
 * main_mips.v
 * Módulo Top-Level do Processador MIPS Monociclo.
 * Integra PC, Memórias, ULA, RegFile e Controle.
 */
module main_mips (
    input  wire clk,
    input  wire reset,
    
    // Saídas de visualização (conforme especificado no PDF [cite: 212])
    output wire [31:0] pc_out,      // Valor atual do PC
    output wire [31:0] alu_result,  // Resultado da ULA
    output wire [31:0] d_mem_out    // Dado lido da memória (se houver)
);

    // 1. Declaração de Fios (Interconexões)

    
    // PC e Instrução
    wire [31:0] w_PC_Current, w_PC_Next, w_PC_Plus4;
    wire [31:0] w_Instruction;
    
    // Decodificação e Registradores
    wire [31:0] w_ReadData1, w_ReadData2;
    wire [31:0] w_SignExtended;
    wire [31:0] w_WriteDataReg;
    wire [4:0]  w_WriteRegAddr;
    
    // ULA (ALU)
    wire [31:0] w_ALU_OperandB;
    wire [31:0] w_ALU_Result_Internal;
    wire [3:0]  w_ALU_Control_Signal;
    wire        w_Zero_Flag;
    
    // Controle
    wire [1:0]  c_RegDst, c_MemToReg, c_ALUOp;
    wire        c_Jump, c_JumpReg, c_Branch, c_BranchNot;
    wire        c_MemRead, c_MemWrite, c_ALUSrc, c_RegWrite;
    
    // Memória de Dados
    wire [31:0] w_MemReadData;
    
    // Lógica de Branch e Jump
    wire [31:0] w_Branch_Offset;
    wire [31:0] w_Branch_Target;
    wire [31:0] w_Jump_Address;
    wire [31:0] w_PC_Branch_Decision;
    wire [31:0] w_PC_Jump_Decision;
    wire        w_Branch_Take; // 1 se o branch deve ser tomado

    // 2. Instanciação dos Módulos
    // --- Estágio: Instruction Fetch (Busca) ---
    
    // 2.1. Program Counter (PC) 
    pc PC_Module (
        .clk(clk), 
        .reset(reset), 
        .nextPc(w_PC_Next), 
        .pc(w_PC_Current)
    );
    assign pc_out = w_PC_Current; // Saída para debug

    // 2.2. Somador PC + 4 
    adder Adder_PC4 (
        .A(w_PC_Current), 
        .B(32'd4), // Constante 4
        .Resultado(w_PC_Plus4)
    );

    // 2.3. Memória de Instruções 
    i_mem Instruction_Memory (
        .address(w_PC_Current), 
        .i_out(w_Instruction)
    );

    // --- Estágio: Instruction Decode (Decodificação) ---

    // 2.4. Unidade de Controle [cite: 189]
    control Control_Unit (
        .opcode(w_Instruction[31:26]),
        .funct(w_Instruction[5:0]), // Necessário para detectar JR
        .RegDst(c_RegDst),
        .MemToReg(c_MemToReg),
        .ALUOp(c_ALUOp),
        .Jump(c_Jump),
        .JumpReg(c_JumpReg),
        .Branch(c_Branch),
        .BranchNot(c_BranchNot),
        .MemRead(c_MemRead),
        .MemWrite(c_MemWrite),
        .ALUSrc(c_ALUSrc),
        .RegWrite(c_RegWrite)
    );

    // 2.5. Banco de Registradores [cite: 51]
    // MUX para definir o registrador de escrita (RegDst expandido para JAL)
    assign w_WriteRegAddr = (c_RegDst == 2'b10) ? 5'd31 :              // JAL: Escreve no $31 ($ra)
                            (c_RegDst == 2'b01) ? w_Instruction[15:11] : // R-Type: Escreve no Rd
                                                  w_Instruction[20:16];  // I-Type: Escreve no Rt

    // MUX para definir o DADO de escrita (MemToReg expandido para JAL)
    assign w_WriteDataReg = (c_MemToReg == 2'b10) ? w_PC_Plus4 :    // JAL: Guarda PC+4 (Link)
                            (c_MemToReg == 2'b01) ? w_MemReadData : // LW: Guarda dado da memória
                                                    w_ALU_Result_Internal; // R/I: Guarda resultado ULA

    regfile Register_File (
        .clk(clk),
        .reset(reset),
        .reg_write_en(c_RegWrite),
        .read_reg1(w_Instruction[25:21]), // Rs
        .read_reg2(w_Instruction[20:16]), // Rt
        .write_reg(w_WriteRegAddr),
        .write_data(w_WriteDataReg),
        .read_data1(w_ReadData1),
        .read_data2(w_ReadData2)
    );

    // 2.6. Extensor de Sinal (Sign Extend) [cite: 48]
    sign_extend Sign_Extender (
        .in(w_Instruction[15:0]),
        .out(w_SignExtended)
    );

    // --- Estágio: Execution (Execução) ---

    // 2.7. Controle da ULA [cite: 26]
    alu_ctrl ALU_Controller (
        .ALUOp(c_ALUOp),
        .Funct(w_Instruction[5:0]),
        .ALUControl(w_ALU_Control_Signal)
    );

    // 2.8. MUX da Entrada B da ULA (ALUSrc)
    // Se ALUSrc=1 (LW, SW, ADDI), usa imediato estendido. Se 0, usa Rt.
    assign w_ALU_OperandB = (c_ALUSrc) ? w_SignExtended : w_ReadData2;

    // 2.9. Unidade Lógica Aritmética (ULA) [cite: 3]
    alu Main_ALU (
        .A(w_ReadData1), 
        .B(w_ALU_OperandB), 
        .shamt(w_Instruction[10:6]), // **CRÍTICO:** Conexão do shamt para shifts
        .ALUControl(w_ALU_Control_Signal), 
        .Resultado(w_ALU_Result_Internal), 
        .Zero(w_Zero_Flag)
    );
    assign alu_result = w_ALU_Result_Internal; // Saída para debug

    // --- Estágio: Memory Access (Memória) ---

    // 2.10. Memória de Dados [cite: 218]
    d_mem Data_Memory (
        .clk(clk),
        .address(w_ALU_Result_Internal),
        .writeData(w_ReadData2), // Em SW, o dado vem de Rt
        .memWrite(c_MemWrite),
        .memRead(c_MemRead),
        .readData(w_MemReadData)
    );
    assign d_mem_out = w_MemReadData; // Saída para debug

    // ==========================================
    // 3. Lógica do Próximo PC (Branch e Jump)
    // ==========================================

    // A. Cálculo do endereço de Branch
    // Offset = Imediato estendido deslocado 2 bits à esquerda
    assign w_Branch_Offset = w_SignExtended << 2; 

    // Somador do Branch: PC+4 + Offset
    adder Adder_Branch (
        .A(w_PC_Plus4),
        .B(w_Branch_Offset),
        .Resultado(w_Branch_Target)
    );

    // B. Decisão de Tomar ou não o Branch (BEQ ou BNE)
    assign w_Branch_Take = (c_Branch & w_Zero_Flag) | (c_BranchNot & ~w_Zero_Flag);

    // MUX do Branch: Se tomar branch, vai para Branch_Target, senão PC+4
    assign w_PC_Branch_Decision = (w_Branch_Take) ? w_Branch_Target : w_PC_Plus4;

    // C. Cálculo do endereço de Jump (J e JAL) 
    // {PC[31:28], instrução[25:0], 00}
    assign w_Jump_Address = { w_PC_Plus4[31:28], w_Instruction[25:0], 2'b00 };

    // MUX do Jump: Se for Jump, vai para Jump_Address
    assign w_PC_Jump_Decision = (c_Jump) ? w_Jump_Address : w_PC_Branch_Decision;

    // D. MUX do JR (Jump Register)
    // Se for JR, o PC recebe o valor do registrador Rs (ReadData1). Senão, segue lógica anterior.
    assign w_PC_Next = (c_JumpReg) ? w_ReadData1 : w_PC_Jump_Decision;

endmodule