module register_clock_load_tb();  
  
  reg clk;  
  reg [15:0] in;  
  reg load;
  reg[5:0] address;  
  wire [15:0] out;
  reg  [15:0] out_exp;
  reg  [38:0] testvectors[0:318]; // array of testvectors
  reg  [31:0] vectornum, errors, testnum;
  reg compare;
  // Instantiate the module under test (DUT)  
  RAM #(.REG_W(16), .REG_N(64)) dut(  
    .clk(clk),  
    .in(in),  
    .load(load),
    .address(address),  
    .out(out)  
  );  
  
  initial begin  
    clk = 0;
    in = 16'b0;load = 0; out_exp=16'b0; address= 6'b0; 
    $dumpfile("Ram64.vcd");  
    $readmemb("../tb/Ram64.tv", testvectors, 0, 318);
    vectornum = 0; errors = 0; testnum = 0;  
  end  
  

  always begin
    #4; // Do not have inputs changing right on clock edge
    address = testvectors[vectornum][21:16];
    load = testvectors[vectornum][22];
    in = testvectors[vectornum][38:23]; 
    
    #1;
    clk = ~clk; // 10ns clock period (5ns high, 5ns low) 
    out_exp = testvectors[vectornum][15:0];
    if (testvectors[vectornum] === 39'bx) begin
      $display("%d tests completed with %d errors", vectornum, errors);
      $finish;
    end
    #1; // Artificial Delay to let the DUT run.
    if (out !== out_exp && clk) begin
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