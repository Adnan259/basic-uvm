// =============================================================================
// File    : add_agent.svh
// Purpose : AGENT - groups sequencer + driver + monitor for ONE interface.
//
//   ACTIVE  agent : sequencer + driver + monitor  (drives the DUT)
//   PASSIVE agent : monitor only                  (just observes)
// =============================================================================

// The sequencer needs no custom code, so a typedef is enough.
typedef uvm_sequencer #(add_item) add_sequencer;

class add_agent extends uvm_agent;
  `uvm_component_utils(add_agent)

  add_sequencer sqr;
  add_driver    drv;
  add_monitor   mon;

  function new(string name, uvm_component parent);
    super.new(name, parent);
  endfunction

  // BUILD: create children. Monitor always; sqr+drv only if ACTIVE.
  // (is_active defaults to UVM_ACTIVE; can be changed via config_db.)
  virtual function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    mon = add_monitor::type_id::create("mon", this);
    if (get_is_active() == UVM_ACTIVE) begin
      sqr = add_sequencer::type_id::create("sqr", this);
      drv = add_driver   ::type_id::create("drv", this);
    end
  endfunction

  // CONNECT: plug the driver into the sequencer so items can flow.
  virtual function void connect_phase(uvm_phase phase);
    super.connect_phase(phase);
    if (get_is_active() == UVM_ACTIVE)
      drv.seq_item_port.connect(sqr.seq_item_export);
  endfunction
endclass
