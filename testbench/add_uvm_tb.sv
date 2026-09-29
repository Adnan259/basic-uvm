// =============================================================================
// File    : add_uvm_tb.sv
// Purpose : Top MODULE of the UVM testbench (TOP=add_uvm_tb in the Makefile).
//   1. makes clock and reset
//   2. instantiates the interface and the DUT
//   3. puts the interface into config_db (the "notice board")
//   4. reads CLI_TEST_NAME (make TN=...) and starts that UVM test
//
// The package is `included here (the Makefile only compiles interface/,
// source/ and testbench/*.sv; package/ is an include directory).
// =============================================================================
`timescale 1ns/1ps

`include "add_pkg.sv"

module add_uvm_tb;
  import uvm_pkg::*;
  import add_pkg::*;
  `include "uvm_macros.svh"

  localparam int WIDTH = `ADD_WIDTH;

  // ---- 1. Clock (10 ns period) and reset ----
  logic clk = 0;
  always #5 clk = ~clk;

  // ---- 2. Interface + DUT ----
  add_if #(WIDTH) intf (.clk(clk));

  initial begin
    intf.rst_n = 1'b0;          // hold reset for a few cycles
    repeat (3) @(posedge clk);
    intf.rst_n = 1'b1;
  end

  adder #(.WIDTH(WIDTH)) dut (
    .clk   (clk),
    .rst_n (intf.rst_n),
    .valid (intf.valid),
    .a     (intf.a),
    .b     (intf.b),
    .sum   (intf.sum)
  );

  // ---- 3 + 4. Publish interface, pick test from CLI, start UVM ----
  initial begin
    string test_name;

    uvm_config_db#(virtual add_if #(WIDTH))::set(null, "*", "vif", intf);

    // make TN=<name>  ->  --testplusarg CLI_TEST_NAME=<name>
    //   TN=default  -> add_rand_test
    //   TN=rand     -> add_rand_test
    //   TN=corner   -> add_corner_test
    //   TN=<full class name> also works
    if (!$value$plusargs("CLI_TEST_NAME=%s", test_name)) test_name = "default";
    case (test_name)
      "default", "rand" : test_name = "add_rand_test";
      "corner"          : test_name = "add_corner_test";
      default           : ; // use the name exactly as given
    endcase

    `uvm_info("TB_TOP", $sformatf("Running test: %s (WIDTH=%0d)", test_name, WIDTH), UVM_NONE)
    run_test(test_name);
  end
endmodule
