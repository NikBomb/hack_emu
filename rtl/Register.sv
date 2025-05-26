module Register #(parameter WIDTH = 16)(
    input logic clk,
    input logic load,
    input logic  [WIDTH - 1 : 0]  in,
    output logic [WIDTH - 1 : 0] out
);

logic [WIDTH - 1 : 0] memory;

initial begin  
    memory = WIDTH'(0);  
end  

always @(posedge clk) begin
    if (load) begin
        memory <= in;
    end
end

assign out = memory;

endmodule