module shift_left_2 ( //entradas e saídas
    input  wire [31:0] in,
    output wire [31:0] out
);
    // move 2 bits para esquerda (multiplica por 4)
    assign out = {in[29:0], 2'b00};
endmodule