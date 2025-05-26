module ROM #(
    parameter DATA_WIDTH = 16,  // Width of each ROM entry
    parameter ADDR_WIDTH = 15, // Number of address bits (2^ADDR_WIDTH entries)
    parameter ROM_FILE = "program.mem" // File to load ROM contents
) (
    input logic [ADDR_WIDTH-1:0] address,  // Address input
    output logic [DATA_WIDTH-1:0] data    // Data output
);

    // ROM contents
    logic [DATA_WIDTH-1:0] rom [0:(1 << ADDR_WIDTH)-1] /*verilator public*/;

    // Load ROM contents from file
    initial begin
        $readmemb(ROM_FILE, rom);  // Load binary data from the specified file
    end

    // Read logic
    always_comb begin
        data = rom[address];
    end

endmodule