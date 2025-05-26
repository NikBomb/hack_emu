/**
 * A 16-bit counter.
 * if      reset(t): out(t+1) = 0
 * else if load(t):  out(t+1) = in(t)
 * else if inc(t):   out(t+1) = out(t) + 1
 * else              out(t+1) = out(t)
 */

module PC(
    input logic clk,
    input logic[15:0] in,
    input logic inc,
    input logic load,
    input logic reset,
    output logic[15:0] out
);

    logic[15:0] internal_memory = 16'b0;  

    always_ff @(posedge clk) begin
        if (reset)
            internal_memory <= 16'b0;
        else if (load)
            internal_memory <= in;
        else if (inc)
            internal_memory <= internal_memory + 1;
        else
            internal_memory <= internal_memory;
    end

    assign out = internal_memory; 

endmodule