module ALU_tb();  
  
  logic clk;  
  logic [15:0] x;
  logic [15:0] y;
  logic zx;
  logic nx;
  logic zy;
  logic ny;
  logic f;
  logic no;
  logic zr;
  logic ng;
  logic zr_exp;
  logic ng_exp;
  logic  [15:0] out;
  logic  [15:0] out_exp;
  logic  [55:0] testvectors[0:35]; // array of testvectors
  logic  [31:0] vectornum, errors, testnum;
  // Instantiate the module under test (DUT)  
  ALU dut(  
    .x(x),
    .y(y),
    .zx(zx),
    .nx(nx),
    .zy(zy),
    .ny(ny),
    .f(f),
    .no(no),
    .zr(zr),
    .ng(ng),
    .out(out)    
  );  
  
  initial begin  
    x = 16'b0; y = 16'b0; zx = 0; zy = 0; nx = 0; ny = 0; f =0; no= 0; out_exp = 16'b0; clk=0;
    ng_exp = 0; zr_exp =0; 
    $dumpfile("ALU.vcd");  
    $dumpvars(0, ALU_tb); 
    $readmemb("../tb/ALU.tv", testvectors, 0, 35);
    vectornum = 0; errors = 0; testnum = 0;  
  end  
  

  always begin
    #5
    clk = ~clk;
    ng_exp = testvectors[vectornum][0];
    zr_exp = testvectors[vectornum][1];
    out_exp = testvectors[vectornum][17:2];
    no = testvectors[vectornum][18];
    f = testvectors[vectornum][19];
    ny = testvectors[vectornum][20];
    zy = testvectors[vectornum][21];
    nx = testvectors[vectornum][22];
    zx = testvectors[vectornum][23];
    y = testvectors[vectornum][39:24];
    x = testvectors[vectornum][55:40];
    #1
    
    if (testvectors[vectornum] === 56'bx) begin
      $display("%d tests completed with %d errors", vectornum, errors);
      $finish;
    end
    if (out !== out_exp || ng !== ng_exp || zr !== zr_exp) begin
      $display ("Test: %d", {testnum});
      
      $display("Error: inputs = %b", {x, y, zx, nx, zy, ny, f, no} );
      $display("  ouputs = %b (%b expected)", {out, ng, zr}, {out_exp, ng_exp, zr_exp});
      errors = errors + 1;
    end
    vectornum = vectornum + 1;
    testnum = testnum + 1;
  end

endmodule  