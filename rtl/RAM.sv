 /* 
 * If load is asserted, the value of the register selected by
 * address is set to in; Otherwise, the value does not change.
 * The value of the selected register is emitted by out.
 */

module RAM #(parameter REG_W = 16, ADD_W = 3)(
    input clk,
    input logic [REG_W - 1 :0] in,
    input logic load,
    input logic[(ADD_W - 1):0] address,
    output logic[REG_W - 1 :0] out
);

localparam REG_N = 2**ADD_W;

logic[REG_W - 1:0] registers[REG_N - 1 :0];

initial begin  
    for (int i = 0; i < REG_N - 1; i++) begin  
        registers[i] = REG_W'(0); // Set each register to 0  
    end  
end  

always_ff @(posedge clk) begin
    if (load) begin
        registers[address] <= in;
    end
end

assign out = registers[address];

endmodule