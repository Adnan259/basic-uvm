`timescale 1ns/1ps
// =============================================================================
// File    : add_if.sv
// Purpose : Interface = a "bundle of wires" between the testbench and the DUT.
//
// Why an interface?
//   Classes (driver, monitor) cannot touch module ports directly. They get a
//   *virtual interface* handle (a pointer to this bundle) through config_db,
//   and then read/write signals like  vif.a <= 5;
// =============================================================================
interface add_if #(
  parameter int WIDTH = 8
)(
  input logic clk            // clock comes from tb_top
);
  logic             rst_n;   // active-low reset (driven by tb_top)
  logic             valid;   // 1 = a/b carry a real transaction this cycle
  logic [WIDTH-1:0] a;
  logic [WIDTH-1:0] b;
  logic [WIDTH:0]   sum;     // DUT output
endinterface
