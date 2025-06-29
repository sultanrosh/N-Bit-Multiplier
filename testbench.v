// Code your testbench here
`timescale 1ns/1ps

module NBitMultiplierWithBCD_tb;

  // Parameter for input bit width
  parameter N = 8;

  // Testbench inputs
  reg clk;
  reg reset;
  reg [N-1:0] A;
  reg [N-1:0] B;

  // Outputs from the DUT
  wire [2*N-1:0] bin_product;
  wire [3:0] BCD_0, BCD_1, BCD_2, BCD_3;

  // Instantiate the DUT
  NBitMultiplierWithBCD #(N) dut (
    .clk(clk),
    .reset(reset),
    .A(A),
    .B(B),
    .bin_product(bin_product),
    .BCD_0(BCD_0),
    .BCD_1(BCD_1),
    .BCD_2(BCD_2),
    .BCD_3(BCD_3)
  );

  // Clock generation (10ns period = 100MHz)
  always #5 clk = ~clk;

  // Task to display the BCD output cleanly
  task display_BCD;
    $display("BCD Output: %1d%1d%1d%1d", BCD_3, BCD_2, BCD_1, BCD_0);
  endtask

  initial begin
    // Setup for waveform viewing
    $dumpfile("dump.vcd");
    $dumpvars(0, NBitMultiplierWithBCD_tb);

    // Initial values
    clk = 0;
    reset = 1;
    A = 0;
    B = 0;
    #20;

    // === Test 1: A = 12, B = 11 (Expect 132) ===
    reset = 1;
    A = 8'd12;
    B = 8'd11;
    #20; reset = 0;  // Release reset AFTER setting A and B
    #10;             // Wait one clock edge to latch multiplication

    wait (dut.running == 0);
    #20;
    $display("Test 1: A = 12, B = 11");
    $display("Binary Product: %d", bin_product);
    display_BCD(); // Expect 0132

    // === Test 2: A = 25, B = 4 (Expect 100) ===
    reset = 1;
    A = 8'd25;
    B = 8'd4;
    #20; reset = 0;
    #10;

    wait (dut.running == 0);
    #20;
    $display("Test 2: A = 25, B = 4");
    $display("Binary Product: %d", bin_product);
    display_BCD(); // Expect 0100

    // === Test 3: A = 255, B = 1 (Expect 255) ===
    reset = 1;
    A = 8'd255;
    B = 8'd1;
    #20; reset = 0;
    #10;

    wait (dut.running == 0);
    #20;
    $display("Test 3: A = 255, B = 1");
    $display("Binary Product: %d", bin_product);
    display_BCD(); // Expect 0255

    // === Test 4: A = 0, B = 128 (Expect 0) ===
    reset = 1;
    A = 8'd0;
    B = 8'd128;
    #20; reset = 0;
    #10;

    wait (dut.running == 0);
    #20;
    $display("Test 4: A = 0, B = 128");
    $display("Binary Product: %d", bin_product);
    display_BCD(); // Expect 0000

    // Done
    $display("All tests complete.");
    $finish;
  end

endmodule
