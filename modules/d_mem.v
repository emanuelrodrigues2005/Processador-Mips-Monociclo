//Módulo da memória de dados (Comportamento de RAM - Leitura Assíncrona / Escrita Síncrona)
//MAX_SIZE -> Parâmetro que define a quantidade de linhas da memória
//ADDRESS_SIZE -> Tamanho do endereço recebido pela memória RAM
//DATA_SIZE -> Tamanho do dado que será lido e escrito na memória RAM
//Entradas: Clock (clk), address, writeData, memWrite, memRead
//Saída: readData (dado de 32 bits lido da memória ou alta impedância)
module d_mem #(parameter MAX_SIZE = 128, parameter ADDRESS_SIZE = 32, parameter DATA_SIZE = 32)(
	input wire clk,
	input wire [ADDRESS_SIZE-1:0] address, 
	input wire [DATA_SIZE-1:0] writeData,
	input wire memWrite,
	input wire memRead,
	output wire [DATA_SIZE-1:0] readData
);

	//Declara a memória RAM com MAX_SIZE linhas e DATA_SIZE colunas
	reg [DATA_SIZE-1:0] ram_memory [0:MAX_SIZE-1];
	
	//Ternário para alternar entre ações qunado o memRead é true ou false
	assign readData = (memRead) ? ram_memory[address[31:2]] : {DATA_SIZE{1'bz}};
	
	//Bloco de escrita síncrona, a qual ocorre apenas na borda de subida do clock
	always @(posedge clk) begin
		//Se a flag de escrita estiver habilitada, grava o 'writeData' na posição indicada
		if(memWrite) begin
			ram_memory[address[31:2]] <= writeData;
		end
	end
	
	//Zera todas as posições da memória para evitar estados indefinidos ('X')
	integer i;
	initial begin
		for(i = 0; i < MAX_SIZE; i = i + 1) begin
			ram_memory[i] = {DATA_SIZE{1'b0}};
		end
	end
endmodule
