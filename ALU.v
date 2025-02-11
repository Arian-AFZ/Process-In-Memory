module ALU (
    input [31:0] A,
    input [31:0] B,
    input [1:0] opcode,
    output [31:0] out
);
    assign out[31:0] = (opcode == 2'b00) ? (A + B) : 32'bz;
    assign out[31:0] = (opcode == 2'b01) ? (A - B) : 32'bz;
    assign out[31:0] = (opcode == 2'b10) ? (A & B) : 32'bz;
    assign out[31:0] = (opcode == 2'b11) ? (A | B) : 32'bz;
endmodule