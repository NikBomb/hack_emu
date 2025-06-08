module CPU_tb();  
  
  // Module signals 
  //Inputs
  logic clk;  
  logic[15:0] inM;
  logic[15:0] instruction;
  logic reset;
  
  //Outputs 
  logic[15:0] outM;   
  logic writeM;       
  logic[14:0] addressM;
  logic[14:0] pc;      

  // Outputs to be loaded 

  logic[15:0] outM_exp;   
  logic writeM_exp;       
  logic[14:0] addressM_exp;
  logic[14:0] pc_exp;
  logic[15:0] dreg_exp;    

  logic [95:0] testvectors[0:91]; // array of testvectors
  logic [31:0] vectornum, errors, testnum;
  // Instantiate the module under test (DUT)  
  CPU dut(  
    .clock(clk),  
    .inM(inM),
    .instruction(instruction), 
    .reset(reset),  
    .outM(outM),
    .writeM(writeM),
    .addressM(addressM),
    .pc(pc)  
  );  
  
  initial begin  
    clk = 1;
    inM = 16'b0; instruction = 16'b0; reset = 0;
    outM_exp = 16'b0; writeM_exp = 0; addressM_exp= 15'b0; pc_exp = 15'b0;  
    $dumpfile("CPU.vcd");  
    $dumpvars(0, CPU_tb); 
    $readmemb("../tb/CPU.tv", testvectors, 0, 91);
    vectornum = 0; errors = 0; testnum = 0;
  end  
  

  always begin
    #4; // Do not have inputs changing right on clock edge
  
    inM = testvectors[vectornum][95:80];
    instruction = testvectors[vectornum][79:64];
    reset = testvectors[vectornum][63];
    
    #1;
    clk = ~clk; // 10ns clock period (5ns high, 5ns low) 
    dreg_exp = testvectors[vectornum][15:0];
    pc_exp = testvectors[vectornum][30:16];
    addressM_exp = testvectors[vectornum][45:31];
    writeM_exp = testvectors[vectornum][46];
    outM_exp = testvectors[vectornum][62:47];
    if (testvectors[vectornum] === 96'bx) begin
      $display("%d tests completed with %d errors", vectornum, errors);
      $finish;
    end
    //#1; // Artificial Delay to let the DUT run.
    if ((writeM != writeM_exp || addressM != addressM_exp ||
        pc != pc_exp)  && ~clk) begin
      $display ("Test: %d", {testnum});
      $display ("CLK: %b", {clk});
      
      $display("Error: inputs : inM | instruction | reset  = %b | %b | %b ", inM, instruction, reset );
      $display("  ouputs      :  write_M | addressM | pc =   %b | %b | %b", writeM, addressM, pc);
      $display("  expected    :  write_M | addressM | pc =   %b | %b | %b", writeM_exp, addressM_exp, pc_exp);
      
      errors = errors + 1;
    end
    vectornum = vectornum + 1;
    testnum = testnum + 1;
  end

endmodule  