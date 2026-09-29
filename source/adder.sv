`timescale 1ns/1ps
// =============================================================================
// File    : adder.sv
// Purpose : DUT (Design Under Test) - a simple parameterized adder.
//
//   sum = a + b   (combinational, result appears immediately)
//
// Parameter:
//   WIDTH : bit width of inputs a and b. Output sum is WIDTH+1 bits so the
//           carry is never lost (e.g. WIDTH=8 -> 255+255 = 510 needs 9 bits).
//
// 'valid' tells the testbench WHEN a, b hold a real transaction
// (real protocols like AXI/APB always have such a signal).
// =============================================================================
module adder #(
  parameter int WIDTH = 8
)(
  input  logic             clk,
  input  logic             rst_n,
  input  logic             valid,
  input  logic [WIDTH-1:0] a,
  input  logic [WIDTH-1:0] b,
  output logic [WIDTH:0]   sum      // WIDTH+1 bits (includes carry)
);

  // Pure combinational add. clk/rst_n are unused here but kept so the port
  // list looks like a real synchronous block (exercise: make it registered).
  assign sum = a + b;

endmodule
