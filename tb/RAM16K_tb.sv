module RAM16K_tb();  
  
  reg clk;  
  reg [15:0] in;  
  reg load;
  reg  [13:0] address;  
  wire [15:0] out;
  reg  [15:0] out_exp;
  reg  [46:0] testvectors[0:318]; // array of testvectors
  reg  [31:0] vectornum, errors, testnum;
  reg compare;
  // Instantiate the module under test (DUT)  
  RAM #(.REG_W(16), .ADD_W(14)) dut(  
    .clk(clk),  
    .in(in),  
    .load(load),
    .address(address),  
    .out(out)  
  );  
  
  initial begin  
    clk = 1;
    in = 16'b0;load = 0; out_exp=16'b0; address= 6'b0; 
    $dumpfile("Ram16k.vcd");
    $dumpvars(0, RAM16K_tb);
    $readmemb("../tb/Ram16k.tv", testvectors, 0, 318);
    vectornum = 0; errors = 0; testnum = 0;  
  end  
  

  always begin
    #4; // Do not have inputs changing right on clock edge
    address = testvectors[vectornum][29:16];
    load = testvectors[vectornum][30];
    in = testvectors[vectornum][46:31]; 
    
    #1;
    clk = ~clk; // 10ns clock period (5ns high, 5ns low) 
    out_exp = testvectors[vectornum][15:0];
    if (testvectors[vectornum] === 47'bx) begin
      $display("%d tests completed with %d errors", vectornum, errors);
      $finish;
    end
    #1; // Artificial Delay to let the DUT run.
    if (out !== out_exp && ~clk) begin
      $display ("Test: %d", {testnum});
      $display ("CLK: %b", {clk});
      
      $display("Error: inputs = %b", {in, load, address} );
      $display("  ouputs = %b (%b expected)", out, out_exp);
      errors = errors + 1;
    end
    vectornum = vectornum + 1;
    testnum = testnum + 1;
  end

endmodule  