// =============================================================================
// File    : add_pkg.sv
// Purpose : Package that pulls all testbench classes together.
//           ORDER MATTERS: a class must be included before it is used.
// =============================================================================

// Data width for the whole TB. Override from the Makefile: make WIDTH=16
`ifndef ADD_WIDTH
  `define ADD_WIDTH 8
`endif

package add_pkg;
  import uvm_pkg::*;          // UVM base classes
  `include "uvm_macros.svh"   // `uvm_info, `uvm_component_utils, ...

  `include "add_item.svh"        // transaction
  `include "add_seq.svh"         // sequence
  `include "add_driver.svh"      // driver
  `include "add_monitor.svh"     // monitor
  `include "add_scoreboard.svh"  // scoreboard
  `include "add_agent.svh"       // agent (+ sequencer typedef)
  `include "add_env.svh"         // environment
  `include "add_tests.svh"       // tests
endpackage
