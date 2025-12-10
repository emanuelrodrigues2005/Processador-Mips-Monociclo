/*
 * mips_tb.v
 * Testbench abrangente para validação do processador MIPS completo
 * Arquitetura de Computadores - UFRPE 2025.2
 */

`timescale 1ns / 1ps // Define a unidade de tempo e precisão da simulação

module mips_tb;

    // Declaração dos sinais de interface
    reg  clk;           // Sinal de clock
    reg  reset;         // Sinal de reset
    wire [31:0] pc_out; // Saída do PC
    wire [31:0] alu_result;   // Resultado da ULA
    wire [31:0] mem_data_out; // Dado lido da memória de dados
    wire [31:0] i_mem_out;    // Instrução lida da memória de instruções

    // Instância do módulo principal (Device Under Test)
    main_mips DUT (
        .clk        (clk),
        .reset      (reset),
        .pc_out     (pc_out),
        .alu_result (alu_result),
        .d_mem_out  (mem_data_out),
        .i_mem_out  (i_mem_out)
    );

    // Geração do clock com alternância a cada 10ns
    initial begin
        clk = 0;
        forever #10 clk = ~clk;
    end

    // Bloco de estimulação e controle da simulação
    initial begin
        $dumpfile("mips_tb.vcd"); // Define o arquivo de saída para waveform
        $dumpvars(0, mips_tb);    // Registra todas as variáveis do testbench

        // Sequência de Reset
        reset = 1;
        repeat(2) @(posedge clk);
        reset = 0;
        
        // Aguarda estabilização e imprime o estado inicial (PC = 0)
        // antes de o clock avançar e alterar o PC.
        #1; 
        print_status(); 

        // Executa ciclos para as demais instruções
        repeat(200) begin 
            @(posedge clk); // Aguarda borda de subida (PC avança)
            #1;             // Pequeno delay para estabilização dos sinais
            print_status(); // Chama função de debug
        end

        $display("\n=== Fim da simulacao ===");
        $finish;
    end

    // -------------------------------------------------------------------------
    // TAREFA DE DEBUG: Imprime o estado detalhado do processador
    // -------------------------------------------------------------------------
    task print_status;
        
        integer i; // Variável para loop

        // Variáveis locais para decodificação visual
        reg [5:0] opcode;
        reg [5:0] funct;
        reg [4:0] rs, rt, rd;
        reg [31:0] rs_val, rt_val, rd_val;
        reg [8*6-1:0] str_inst; 
        reg [8:0] str_type;

        begin
            // 1. Extração dos Campos da Instrução
            opcode = DUT.w_Instruction[31:26];
            funct  = DUT.w_Instruction[5:0];
            rs     = DUT.w_Instruction[25:21];
            rt     = DUT.w_Instruction[20:16];
            rd     = DUT.w_Instruction[15:11]; 
            
            // 2. Leitura Direta do Banco de Registradores
            rs_val = DUT.Register_File.registers[rs];
            rt_val = DUT.Register_File.registers[rt];
            rd_val = DUT.Register_File.registers[rd]; 

            // 3. Decodificação do Mnemônico
            if (opcode == 0) begin
                str_type = "R-Type";
                case (funct)
                    // Aritmética e Lógica Básica
                    6'h20: str_inst = "ADD";  6'h21: str_inst = "ADDU";
                    6'h22: str_inst = "SUB";  6'h23: str_inst = "SUBU";
                    6'h24: str_inst = "AND";  6'h25: str_inst = "OR";
                    6'h26: str_inst = "XOR";  6'h27: str_inst = "NOR";
                    
                    // Comparação
                    6'h2A: str_inst = "SLT";  6'h2B: str_inst = "SLTU";
                    
                    // Shifts Constantes
                    6'h00: str_inst = "SLL";
                    6'h02: str_inst = "SRL";
                    6'h03: str_inst = "SRA"; 
                    
                    // Shifts Variáveis (Adicionados para corrigir R-UNK)
                    6'h04: str_inst = "SLLV"; 
                    6'h06: str_inst = "SRLV"; 
                    6'h07: str_inst = "SRAV";

                    6'h08: str_inst = "JR";
                    default: str_inst = "R-UNK";
                endcase
            end else if (opcode == 2 || opcode == 3) begin
                str_type = "J-Type";
                case (opcode)
                    6'h02: str_inst = "J";    6'h03: str_inst = "JAL";
                    default: str_inst = "J-UNK";
                endcase
            end else begin
                str_type = "I-Type";
                case (opcode)
                    // Aritmética Imediata
                    6'h08: str_inst = "ADDI"; 6'h09: str_inst = "ADDIU";
                    
                    // Lógica Imediata (Adicionados XORI)
                    6'h0C: str_inst = "ANDI"; 6'h0D: str_inst = "ORI";
                    6'h0E: str_inst = "XORI"; 
                    
                    // Comparação Imediata (Adicionados SLTI/U)
                    6'h0A: str_inst = "SLTI"; 
                    6'h0B: str_inst = "SLTIU";

                    // Load/Store e Branch
                    6'h0F: str_inst = "LUI";  
                    6'h23: str_inst = "LW";   6'h2B: str_inst = "SW";   
                    6'h04: str_inst = "BEQ";  6'h05: str_inst = "BNE";
                    default: str_inst = "I-UNK";
                endcase
            end
				
				// Dump do Banco de Registradores
            $display("================================================================================================\n");
            $display("| BANCO DE REGISTRADORES (Estado Atual):                                                       |");
            
            for (i = 0; i < 32; i = i + 1) begin
                if ((i % 4) == 0) $write("\n| ");
                $write("$%02d: %h  ", i, DUT.Register_File.registers[i]);
            end
            $write("\n");
            $display("------------------------------------------------------------------------------------------------");
				
				
            // 4. Impressão do Painel de Debug Formatado
            $display("| PC       | INSTR (Hex) | TIPO   | RS ($%02d) Val      | RT ($%02d) Val      | RD ($%02d) Val      |", rs, rt, rd);
            $display("| %h | %h  | %s | [%02d] = 0x%h | [%02d] = 0x%h | [%02d] = 0x%h |", 
                     pc_out, DUT.w_Instruction, str_inst, rs, rs_val, rt, rt_val, rd, rd_val);
            
            // Dados Imediatos
            $display("------------------------------------------------------------------------------------------------");
            $display("| IMMEDIATE DATA (Para I-Type/Offset):                                                         |");
            $display("| Raw (16b): 0x%h | Extended (32b): 0x%h (Dec: %0d) | ImmSrc: %b                     |", 
                     DUT.w_Instruction[15:0], DUT.w_Immediate, $signed(DUT.w_Immediate), DUT.c_ImmSrc);

            // Sinais de Controle
            $display("------------------------------------------------------------------------------------------------");
            $display("| CONTROL SIGNALS:                                                                             |");
            $display("| RegDst: %b | ALUSrc: %b | MemToReg: %b | RegWrite: %b | MemRead: %b | MemWrite: %b             |",
                     DUT.c_RegDst, DUT.c_ALUSrc, DUT.c_MemToReg, DUT.c_RegWrite, DUT.c_MemRead, DUT.c_MemWrite);
            $display("| Branch: %b | B.Not : %b | Jump    : %b | JumpReg : %b                                      |",
                     DUT.c_Branch, DUT.c_BranchNot, DUT.c_Jump, DUT.c_JumpReg);
            $display("| ALU Ctrl: %b      | ZeroFlag: %b                                                            |", 
                     DUT.w_ALU_Control_Signal, DUT.w_Zero_Flag); 
				$display("================================================================================================\n");
            

        end
    endtask

    // Segurança: finaliza a simulação após tempo limite caso entre em loop infinito
    initial #1430 $finish;

endmodule
