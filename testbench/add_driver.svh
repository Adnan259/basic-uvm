// =============================================================================
// File    : add_driver.svh
// Purpose : DRIVER - converts a transaction into PIN-LEVEL signals.
//           transaction (software)  --->  vif.a / vif.b / vif.valid (hardware)
//
// Loop in run_phase:  GET item -> WAIT clock -> DRIVE pins -> say DONE
// =============================================================================
class add_driver extends uvm_driver #(add_item);
  `uvm_component_utils(add_driver)      // driver is a COMPONENT

  virtual add_if #(`ADD_WIDTH) vif;     // "remote control" to the DUT pins

  // Component constructor: name + parent (builds the hierarchy path).
  function new(string name, uvm_component parent);
    super.new(name, parent);
  endfunction

  // BUILD phase (time 0, function): get the interface handle from config_db.
  virtual function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    if (!uvm_config_db#(virtual add_if #(`ADD_WIDTH))::get(this, "", "vif", vif))
      `uvm_fatal("DRV", "Virtual interface 'vif' not found in config_db")
  endfunction

  // RUN phase (task, consumes time): drive forever.
  virtual task run_phase(uvm_phase phase);
    // Put pins in a known idle state and wait for reset to finish.
    vif.valid <= 1'b0;
    vif.a     <= '0;
    vif.b     <= '0;
    @(posedge vif.rst_n);

    forever begin
      seq_item_port.get_next_item(req);     // 1. GET next item (blocks if none)

      @(posedge vif.clk);                   // 2. WAIT for clock edge
      vif.a     <= req.a;                   // 3. DRIVE pins (non-blocking <=
      vif.b     <= req.b;                   //    avoids races with the DUT)
      vif.valid <= 1'b1;

      @(posedge vif.clk);                   // hold for one cycle, then
      vif.valid <= 1'b0;                    // de-assert valid (idle cycle)

      `uvm_info("DRV", {"Drove: ", req.convert2string()}, UVM_HIGH)
      seq_item_port.item_done();            // 4. tell sequencer "done"
    end
  endtask
endclass
