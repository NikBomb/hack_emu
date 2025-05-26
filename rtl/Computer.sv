`include "ROM.sv"
`include "CPU.sv"
`include "Memory.sv"

`define computer 1

module Computer(
    input logic clk,
    input logic reset,
    input logic[15:0] keyboard,
    output logic [15:0] screen_out [0:8191] 
);


logic[15:0] instruction /*verilator public*/;
logic [14:0] pc /*verilator public*/;
logic writeM /*verilator public*/;
logic[14:0] addressM /*verilator public*/;
logic[15:0] inM /*verilator public*/;
logic[15:0] outM /*verilator public*/;


ROM rom(
  .address(pc),
  .data(instruction)  
);

CPU cpu(.clock(clk),
        .inM(inM),
        .instruction(instruction),
        .reset(reset),
        .outM(outM),
        .writeM(writeM),
        .addressM(addressM),
        .pc(pc));

Memory mem(.clk(clk),
           .in(outM),
           .address(addressM),
           .load(writeM),
           .keyboard(keyboard),
           .out(inM),
           .screen_out(screen_out));
endmodule 