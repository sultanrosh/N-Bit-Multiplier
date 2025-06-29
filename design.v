// ================================
// Module: NBitMultiplierWithBCD
// Purpose: Multiply two N-bit numbers and convert the binary result to BCD using the Double Dabble method
// ================================

module NBitMultiplierWithBCD #(
  parameter N = 8                      // Parameter to set the bit-width of inputs A and B
)(
  input wire clk,                      // Clock signal for synchronous logic
  input wire reset,                    // Reset signal to initialize/clear state
  input wire [N-1:0] A,                // First input operand (N-bit wide)
  input wire [N-1:0] B,                // Second input operand (N-bit wide)
  output reg [2*N-1:0] bin_product,    // Binary product output (2N-bit wide, since A * B can be up to 2N bits)
  output reg [3:0] BCD_0,              // Least significant BCD digit (units)
  output reg [3:0] BCD_1,              // Tens place BCD digit
  output reg [3:0] BCD_2,              // Hundreds place BCD digit
  output reg [3:0] BCD_3               // Thousands place BCD digit (more than enough for 8-bit inputs)
);

  localparam ADD_THREE = 4'b0011;            // Constant value 3 used in Double Dabble correction step
  localparam PRODUCT_WIDTH = 2 * N;          // Width of the binary product

  // Internal registers for BCD conversion using Double Dabble
  reg [PRODUCT_WIDTH-1:0] shift_reg;         // Shift register holding binary product during conversion
  reg [3:0] bcd_array [3:0];                 // Array of 4 BCD digits (each 4 bits wide)

  reg [7:0] count;                           // Counter to keep track of how many bits have been processed
  reg running;                               // Flag to control whether Double Dabble is currently running

  // ========================================
  // Step 1: Compute binary product on clock edge
  // ========================================
  always @(posedge clk or posedge reset) begin
    if (reset) begin
      bin_product <= 0;                      // Clear binary product on reset
      running <= 0;                          // Stop conversion process
      count <= 0;                            // Reset count
      BCD_0 <= 0; BCD_1 <= 0; BCD_2 <= 0; BCD_3 <= 0; // Clear BCD outputs
    end else begin
      bin_product <= A * B;                  // Perform multiplication
      running <= 1;                          // Start the Double Dabble conversion
      count <= 0;                            // Start bit counter at 0
      shift_reg <= A * B;                    // Load product into shift register for conversion
      bcd_array[0] <= 0;                     // Clear all BCD digits
      bcd_array[1] <= 0;
      bcd_array[2] <= 0;
      bcd_array[3] <= 0;
    end
  end

  // ========================================
  // Step 2: Double Dabble algorithm
  // Shifts and corrects BCD digits over multiple cycles
  // ========================================
  always @(posedge clk) begin
    if (running) begin
      // --------- Correction Step: Add 3 to any BCD digit ≥ 5 ---------
      integer i;
      for (i = 0; i < 4; i = i + 1) begin
        if (bcd_array[i] >= 5)               // If BCD digit ≥ 5
          bcd_array[i] <= bcd_array[i] + ADD_THREE; // Add 3 to fix invalid BCD range
      end

      // --------- Shifting Step: Shift all digits and bring in new bit ---------
      bcd_array[3] <= {bcd_array[3][2:0], bcd_array[2][3]};          // Shift BCD_3 left, pull in MSB of BCD_2
      bcd_array[2] <= {bcd_array[2][2:0], bcd_array[1][3]};          // Shift BCD_2 left, pull in MSB of BCD_1
      bcd_array[1] <= {bcd_array[1][2:0], bcd_array[0][3]};          // Shift BCD_1 left, pull in MSB of BCD_0
      bcd_array[0] <= {bcd_array[0][2:0], shift_reg[PRODUCT_WIDTH-1]}; // Shift BCD_0 left, pull in MSB of shift_reg

      shift_reg <= {shift_reg[PRODUCT_WIDTH-2:0], 1'b0};             // Shift binary product left by 1, drop MSB, add 0 to LSB

      count <= count + 1;                                           // Increment bit count

      // --------- Termination condition ---------
      if (count == PRODUCT_WIDTH - 1) begin                         // All bits have been shifted
        running <= 0;                                               // Stop conversion
        // Assign final BCD digits to output
        BCD_0 <= bcd_array[0];
        BCD_1 <= bcd_array[1];
        BCD_2 <= bcd_array[2];
        BCD_3 <= bcd_array[3];
      end
    end
  end

endmodule




/*
module NBitMultiplierWithBCD(
  input clk,
  input reset,
  input wire[N-1:0] A,
  input wire[N-1:0] B,
  output wire[2*N-1:0] bin_product,
  output reg[3:0] BCD_0,
  output reg[3:0] BCD_1,
  output reg[3:0] BCD_2,
  output reg[3:0] BCD_3
);
  
  
