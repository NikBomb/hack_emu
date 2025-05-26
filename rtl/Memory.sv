module Memory(
    input logic clk,
    input logic [15:0] in,
    input logic [14:0] address,
    input logic load,
    input logic [15:0] keyboard,
    output logic [15:0] out,
    output logic [15:0] screen_out [0:8191]  // Output for the entire screen memory
);

 // Memory banks
logic [15:0] ram[0:16383];       // 16Kb RAM (0 to 16383)
logic [15:0] screen[0:8191];     // 8Kb memory (16384 to 24575)
logic [15:0] kbr;

logic loadRAM = ~address[14] & load;  // Load into RAM if address[15] == 0
logic loadScreen = address[14] & load; // Load into screen if address[15] == 1

initial begin
    for (int i = 0; i < 16384; i++) begin
        ram[i] = 16'b0;  // Initialize RAM to 0
    end
    for (int i = 0; i < 8192; i++) begin
        screen[i] = 16'b0;  // Initialize Screen to 0
    end
    kbr = 16'b0;
end

// Write to RAM
always_ff @(posedge clk) begin
    if (loadRAM) begin
        ram[address[13:0]] <= in;  // Write to RAM
    end
end
// Write to Screen
always_ff @(posedge clk) begin
    if (loadScreen) begin
        screen[address[12:0]] <= in;  // Write to screen
    end
end

//Write to Keyboard

always_ff @(posedge clk) begin    
    kbr <= keyboard;  // Always write to Keyboard
end


// Read logic
    always_comb begin
        if (address[14]) begin
            if (address[13:0] == 8192) begin
                out = kbr;  // Read from keyboard at address 24576
            end else begin
                out = screen[address[12:0]];  // Read from screen
            end
        end else begin
            out = ram[address[13:0]];  // Read from RAM
        end
    end

assign screen_out = screen;
endmodule