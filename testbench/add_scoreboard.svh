// =============================================================================
// File    : add_scoreboard.svh
// Purpose : SCOREBOARD - decides PASS / FAIL.
//           It receives items from the monitor through an analysis imp.
//           Every ap.write(tr) in the monitor automatically calls write(tr) here.
// =============================================================================
class add_scoreboard extends uvm_scoreboard;
  `uvm_component_utils(add_scoreboard)

  // Receiver end of the monitor's analysis port.
  uvm_analysis_imp #(add_item, add_scoreboard) imp;

  int unsigned n_pass = 0;
  int unsigned n_fail = 0;

  function new(string name, uvm_component parent);
    super.new(name, parent);
  endfunction

  virtual function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    imp = new("imp", this);
  endfunction

  // Called automatically for every item the monitor broadcasts.
  // Must be a FUNCTION (zero time) so the monitor is never blocked.
  virtual function void write(add_item tr);
    bit [`ADD_WIDTH:0] expected;
    expected = tr.a + tr.b;             // reference model (golden answer)

    if (tr.sum === expected) begin      // === also catches X/Z
      n_pass++;
      `uvm_info("SB", {"PASS: ", tr.convert2string()}, UVM_MEDIUM)
    end else begin
      n_fail++;
      `uvm_error("SB", $sformatf("FAIL: %s (expected sum=%0d)",
                                 tr.convert2string(), expected))
    end
  endfunction

  // REPORT phase: runs once at the end of simulation.
  virtual function void report_phase(uvm_phase phase);
    `uvm_info("SB", $sformatf("Checked %0d items: %0d PASS, %0d FAIL",
                              n_pass + n_fail, n_pass, n_fail), UVM_NONE)
    if (n_pass + n_fail == 0)
      `uvm_error("SB", "No transactions were checked!")
  endfunction
endclass
