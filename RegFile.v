module RegFile (
    input reg_select,
    input [31:0] load_data,
    input load_enable,
    output reg [31:0]  A,
    output reg [31:0]  B
);
    always @(posedge load_enable) begin
        if (reg_select)
            B = load_data;
        else
            A = load_data;
    end
endmodule