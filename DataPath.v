module DataPath (
    input reg_select,
    input [31:0] load_data,
    input load_enable,
    input [1:0] opcode,
    output [31:0] out
);
    wire [31:0] A, B;

    RegFile register_file(
        .reg_select(reg_select),
        .load_data(load_data),
        .load_enable(load_enable),
        .A(A),
        .B(B)
    );
    ALU alu(
        .A(A),
	    .B(B),
        .opcode(opcode),
        .out(out)
    );
endmodule