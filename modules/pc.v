//Módulo do Program Counter
//Entradas: clock (clk), reset (assíncrono), nextPc (32 bits)
//Saídas: pc (reg de 32 bits)
module pc (input wire clk, input wire reset, input wire [31:0] nextPc, output reg [31:0] pc);
	// Atualiza PC na borda de subida do clock ou quando reset sobe
	always @(posedge clk or posedge reset) begin
		if(reset) begin
			// Se reset estiver em nível alto, zera o PC
			pc <= 32'b0;
		end else begin 
			// Caso contrário, PC recebe o próximo endereço calculado externamente
			pc <= nextPc;
		end
	end
endmodule
