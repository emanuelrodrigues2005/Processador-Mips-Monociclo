module regfile ( //entradas e saídas do módulo
    input wire clk,
    input wire reset,
    input wire reg_write_en, //sinal pra escrita
    input wire [4:0] read_reg1, //reg1 pra ler
    input wire [4:0] read_reg2, //reg2 "    "
    input wire [4:0] write_reg, // reg pra escrever
    input wire [31:0] write_data, //dado pra escrever
    output wire [31:0] read_data1, //dado lido reg1
    output wire [31:0] read_data2 //dado lido reg2
);

    reg [31:0] registers [31:0]; //32 registradores de 32 bits
    integer i;

    // leitura assíncrona (se for reg 0, sai 0)
    // para endereço = 0, retorna 0. Se não, retorna o valor do registrador
    assign read_data1 = (read_reg1 == 0) ? 32'b0 : registers[read_reg1];
    assign read_data2 = (read_reg2 == 0) ? 32'b0 : registers[read_reg2];

    // escrita síncrona (pega o detalhe)
    always @(posedge clk or posedge reset) begin
        if (reset) begin
            for (i = 0; i < 32; i = i + 1) begin
                registers[i] <= 32'b0;
            end
        end
        else if (reg_write_en && write_reg != 0) begin
            registers[write_reg] <= write_data;
        end
    end
endmodule