module PC_tb();  
  
  reg clk;  
  reg [15:0] in;
  reg inc;  
  reg load;
  reg reset;
  wire [15:0] out;
  reg  [15:0] out_exp;
  reg  [34:0] testvectors[0:29]; // array of testvectors
  reg  [31:0] vectornum, errors, testnum;
  // Instantiate the module under test (DUT)  
  PC dut(  
    .clk(clk),  
    .in(in),
    .inc(inc), 
    .load(load),
    .reset(reset),  
    .out(out)  
  );  
  
  initial begin  
    clk = 1;
    in = 16'b0;inc = 0; load = 0; reset = 0; out_exp=16'b0; 
    $dumpfile("PC.vcd");  
    $dumpvars(0, PC_tb); 
    $readmemb("../tb/PC.tv", testvectors, 0, 29);
    vectornum = 0; errors = 0; testnum = 0;  
  end  
  

  always begin
    #4; // Do not have inputs changing right on clock edge
    in = testvectors[vectornum][34:19];
    reset = testvectors[vectornum][18];
    load = testvectors[vectornum][17];
    inc = testvectors[vectornum][16]; 
    
    #1;
    clk = ~clk; // 10ns clock period (5ns high, 5ns low) 
    out_exp = testvectors[vectornum][15:0];
    if (testvectors[vectornum] === 35'bx) begin
      $display("%d tests completed with %d errors", vectornum, errors);
      $finish;
    end
    #1; // Artificial Delay to let the DUT run.
    if (out !== out_exp && clk) begin
      $display ("Test: %d", {testnum});
      $display ("CLK: %b", {clk});
      
      $display("Error: inputs = %b", {in, inc, reset, load} );
      $display("  ouputs = %b (%b expected)", out, out_exp);
      errors = errors + 1;
    end
    vectornum = vectornum + 1;
    testnum = testnum + 1;
  end

endmodule  