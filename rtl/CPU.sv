`include "ALU.sv"
`include "PC.sv"
//Function: Executes the instruction according to the Hack machine language
//specification. The D and A in the language specification refer to
//CPU-resident registers, while M refers to the memory location
//addressed by A (inM holds the value of this location).
//If the instruction needs to write a value to M, the value is
//placed in outM, the address is placed in addressM, and the writeM
//bit is asserted. (When writeM=0, any value may appear in outM.)
//If reset=1, then the CPU jumps to address 0 (i.e., sets pc=0 in
//the next time unit) rather than to the address resulting from
//executing the current instruction.

module CPU(
    input logic clock,
    input logic[15:0] inM,         // M value input (M = contents of RAM[A])
    input logic[15:0] instruction, // Instruction for execution
    input logic reset,             // Signals whether to restart the current
                                   // program (reset=1) or continue executing
                                   // the current program (reset=0)
    output logic[15:0] outM,       // M Value output  
    output logic writeM,           // write to main memory?
    output logic[14:0] addressM,    // Address of M in data memory
    output logic[14:0] pc          // Address of next instruction
);

    logic [15:0] pcOut;
    logic [15:0] AorM;
    logic lt;
    logic eq;
    logic jmp;
    logic inc;
    logic [15:0] outALU;
    logic loadI;
    logic loadA;
    logic loadD /*verilator public*/;
    logic [15:0] regA = 16'b0 ;
    logic [15:0]  regD = 16'b0 ;
    
        
    ALU ALU_inst(
        .x(regD),
        .y(AorM),
        .zx(instruction[11]),
        .nx(instruction[10]),
        .zy(instruction[9]),
        .ny(instruction[8]),
        .f(instruction[7]),
        .no(instruction[6]),
        .zr(eq),
        .ng(lt),
        .out(outALU)
    );

    PC pc_inst(
        .clk(clock),
        .in(regA),
        .load(jmp),
        .inc(~jmp),
        .reset(reset),
        .out(pcOut)
    );

    
    always_ff @(posedge clock) begin
        if (loadI) regA <= instruction;
        else if (loadA) regA <= outALU;
        else regA <= regA;
    end
    
    always_ff @(posedge clock) begin 
        if (loadD) regD <= outALU;
        else regD <= regD;
    end
    
    assign AorM = (instruction[12]) ? inM : regA;
    assign loadI = ~instruction[15];
    assign loadA = instruction[15] & instruction[5];
    assign loadD = instruction[15] & instruction[4];
    assign writeM = instruction[15] & instruction[3];
    assign jmp = instruction[15] & ((lt & instruction[2]) | (eq & instruction[1]) | ((!(lt|eq)) & instruction[0]));
    assign addressM = regA[14:0];
    assign outM = outALU;
    assign pc = pcOut[14:0];

endmodule