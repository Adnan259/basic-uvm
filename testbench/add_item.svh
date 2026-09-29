// =============================================================================
// File    : add_item.svh
// Purpose : TRANSACTION (sequence item) - the "order slip".
//           Holds DATA only. No timing, no signals, no clock.
// =============================================================================
class add_item extends uvm_sequence_item;

  // 'rand' -> randomize() will choose values. These are the INPUTS we send.
  rand bit [`ADD_WIDTH-1:0] a;
  rand bit [`ADD_WIDTH-1:0] b;

  // NOT rand -> this is the DUT OUTPUT. The monitor fills it in.
  bit [`ADD_WIDTH:0] sum;

  // Register this class with the UVM factory (needed for type_id::create).
  // Transactions are OBJECTS -> use uvm_object_utils.
  `uvm_object_utils(add_item)

  // Object constructor: only a name (objects have no parent).
  function new(string name = "add_item");
    super.new(name);            // always call the parent constructor first
  endfunction

  // Handy one-line string for log messages.
  virtual function string convert2string();
    return $sformatf("a=%0d b=%0d sum=%0d", a, b, sum);
  endfunction

endclass


// -----------------------------------------------------------------------------
// A child transaction used to demonstrate FACTORY OVERRIDE.
// It only produces "corner" values (0 or max). The corner test swaps this in
// for add_item WITHOUT editing the sequence, driver or env.
// -----------------------------------------------------------------------------
class add_corner_item extends add_item;
  `uvm_object_utils(add_corner_item)

  // Each input is either all-zeros or all-ones (max value).
  constraint c_corner {
    a inside {0, {`ADD_WIDTH{1'b1}}};
    b inside {0, {`ADD_WIDTH{1'b1}}};
  }

  function new(string name = "add_corner_item");
    super.new(name);
  endfunction
endclass
