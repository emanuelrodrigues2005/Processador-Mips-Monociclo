module sign_extend (
    input  wire [15:0] in,  // in com 16 bits
    output wire [31:0] out  // out com 32 bits
);

    // concatena 16 "clones" do bit de sinal (que é o bit 15) com o in original
    assign out = {{16{in[15]}}, in};

endmodule