module MUX (
    input select,
    input [31:0] A, B,
    output [31:0] out
);
    assign out = select ? B : A;
endmodule