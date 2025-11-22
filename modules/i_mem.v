//Módulo da memória de instruções (Comportamento de ROM - Apenas Leitura)
//MEM_SIZE -> Parâmetro que define a quantidade de linhas da memória (padrão 128)
//Entrada: address (endereço de byte vindo do PC)
//Saída: i_out (instrução de 32 bits lida da memória)
module i_mem #(parameter MEM_SIZE = 128)(input wire [31:0] address , output wire [31:0] i_out);
	
	//Declara a matriz de memória: 'MEM_SIZE' linhas, cada uma com 32 bits de largura
	reg [31:0] rom_memory [0:MEM_SIZE-1];
	
	initial begin
		//Carrega o binário do arquivo externo para preencher a memória no início da simulação
		$readmemb("instruction.list", rom_memory);
	end
	
	//A saída recebe o valor lido da memória
	//O endereço é dividido por 4 (descarta bits 0 e 1) para ajustar o endereçamento de Byte para Palavra
	assign i_out = rom_memory[address[31:2]];
endmodule
