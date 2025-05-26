module ALU(
    input logic[15:0] x,
    input logic[15:0] y,
    input logic zx,
    input logic nx,
    input logic zy,
    input logic ny,
    input logic f,
    input logic no,
    output logic zr,
    output logic ng,
    output logic[15:0] out
);


logic[15:0] alu_tmp;
logic[5:0] control_bits;

always_comb begin : computations
    control_bits = {zx, nx, zy, ny, f, no};
    case (control_bits)
        6'b101010 : alu_tmp = 16'b0;
        6'b111111 : alu_tmp = 16'b1;
        6'b111010 : alu_tmp = 16'b1111111111111111;
        6'b001100 : alu_tmp = x;
        6'b110000 : alu_tmp = y;
        6'b001101 : alu_tmp = ~x;
        6'b110001 : alu_tmp = ~y;
        6'b001111 : alu_tmp = (~x) + 16'b1;
        6'b110011 : alu_tmp = (~y) + 16'b1;
        6'b011111 : alu_tmp = x + 16'b1;
        6'b110111 : alu_tmp = y + 16'b1;
        6'b001110 : alu_tmp = x - 16'b1;
        6'b110010 : alu_tmp = y - 16'b1;
        6'b000010 : alu_tmp = x + y;
        6'b010011 : alu_tmp = x - y;
        6'b000111 : alu_tmp = y - x;
        6'b000000 : alu_tmp = x & y;
        6'b010101 : alu_tmp = x | y;
        default   : alu_tmp = 16'b0;  
    endcase
end

    assign ng = alu_tmp[15];
    assign zr = (16'b0 == alu_tmp) ? 1'b1 : 1'b0;
    assign out = alu_tmp;

endmodule