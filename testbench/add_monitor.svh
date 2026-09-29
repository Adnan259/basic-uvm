// =============================================================================
// File    : add_monitor.svh
// Purpose : MONITOR - watches the pins and rebuilds transactions.
//           vif signals (hardware)  --->  add_item (software)
//           It NEVER drives anything. Only reads.
//
// Loop in run_phase:  WAIT clock -> if valid: NEW item, COPY pins, SEND
// =============================================================================
class add_monitor extends uvm_monitor;
  `uvm_component_utils(add_monitor)

  virtual add_if #(`ADD_WIDTH) vif;     // "eyes" on the DUT pins
  uvm_analysis_port #(add_item) ap;     // "radio station" to broadcast items

  function new(string name, uvm_component parent);
    super.new(name, parent);
  endfunction

  virtual function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    ap = new("ap", this);               // ports are made with new(), not create()
    if (!uvm_config_db#(virtual add_if #(`ADD_WIDTH))::get(this, "", "vif", vif))
      `uvm_fatal("MON", "Virtual interface 'vif' not found in config_db")
  endfunction

  virtual task run_phase(uvm_phase phase);
    add_item tr;
    forever begin
      @(posedge vif.clk);               // 1. WAIT for clock edge
      if (vif.rst_n && vif.valid) begin // only capture REAL transactions
        // 2. NEW object every time! (reusing one handle would make every
        //    item stored in the scoreboard point to the same data)
        tr = add_item::type_id::create("tr");
        tr.a   = vif.a;                 // 3. COPY pin values into the item
        tr.b   = vif.b;
        tr.sum = vif.sum;
        `uvm_info("MON", {"Saw:   ", tr.convert2string()}, UVM_HIGH)
        ap.write(tr);                   // 4. SEND to everyone connected (0 time)
      end
    end
  endtask
endclass
