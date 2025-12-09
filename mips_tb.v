/*
 * mips_tb.v
 * Testbench para validação da Etapa 1 (zero-extend) – com debug completo
 * Arquitetura de Computadores - UFRPE 2025.2
 */

`timescale 1ns / 1ps // Define a unidade de tempo e precisão da simulação

module mips_tb; // Módulo de teste do processador MIPS

    // Declaração dos sinais de entrada e saída
    reg  clk; // Sinal de clock
    reg  reset; // Sinal de reset
    wire [31:0] pc_out; // Saída do PC
    wire [31:0] alu_result; // Resultado da ULA
    wire [31:0] mem_data_out; // Dado lido da memória de dados
    wire [31:0] i_mem_out; // Instrução lida da memória de instruções

    // Instância do módulo principal (Device Under Test)
    main_mips DUT (
        .clk        (clk), // Conecta o clock
        .reset      (reset), // Conecta o reset
        .pc_out     (pc_out), // Conecta a saída do PC
        .alu_result (alu_result), // Conecta o resultado da ULA
        .d_mem_out  (mem_data_out), // Conecta a saída da memória de dados
        .i_mem_out  (i_mem_out) // Conecta a saída da memória de instruções
    );

    // Geração do clock com alternância a cada 10ns
    initial begin
        clk = 0; // Inicializa o clock em 0
        forever #10 clk = ~clk; // Inverte o clock a cada 10ns
    end

    // Bloco de estimulação e controle da simulação
    initial begin
        $dumpfile("mips_tb.vcd"); // Define o arquivo de saída para waveform
        $dumpvars(0, mips_tb); // Registra todas as variáveis do testbench

        reset = 1; // Ativa o reset
        repeat(2) @(posedge clk); // Aguarda 2 ciclos de clock
        reset = 0; // Desativa o reset

        // Executa 40 ciclos de clock para simular instruções
        repeat(40) begin 
            @(posedge clk); // Aguarda borda de subida do clock
            #1; // Pequeno atraso para estabilização
            print_status(); // Chama função para imprimir estado
        end

        $display("\n=== Fim da simulacao ==="); // Mensagem de fim
        $finish; // Finaliza a simulação
    end

    // Tarefa para imprimir o estado atual do processador
    task print_status;
        integer  i; // Índice para loop
        reg[31:0] imm16; // Valor do campo imediato de 16 bits
        reg[31:0] imm_ext; // Valor do imediato estendido
        begin
            imm16   = DUT.w_Instruction[15:0]; // Extrai imediato da instrução
            imm_ext = DUT.w_Immediate; // Obtém imediato estendido
            $display("------------------------------------------------");
            $display("Tempo=%0t | PC=%h | Instr=%h", $time, pc_out, DUT.i_mem_out); // PC e instrução
            $display("Imediato=%h  estendido=%h  (ImmSrc=%b)", imm16, imm_ext, DUT.c_ImmSrc); // Imediato
            
            // Informações de escrita
            $display("REG_WR: En=%b  Addr=%2d  Data=%h", DUT.c_RegWrite, DUT.w_WriteRegAddr, DUT.w_WriteDataReg); // Registrador
            $display("MEM_WR: En=%b  Addr=%h  Data=%h", DUT.c_MemWrite, alu_result, DUT.w_ReadData2); // Memória
            
            // Resultados da ULA e memória
            $display("ALU_Res=%h  Mem_Read=%h", alu_result, mem_data_out);
            
            // Imprime todos os registradores
            $display("Banco de Registradores (Completo):");
            for (i = 0; i < 32; i = i + 1) begin
                $display("  x%2d: %h", i, DUT.Register_File.registers[i]); // Valor de cada registrador
            end
        end
    endtask

    // Segurança: finaliza a simulação após 2000ns
    initial #2000 $finish;

endmodule