// =============================================================================
// File    : add_seq.svh
// Purpose : SEQUENCE - decides WHAT transactions to send and HOW MANY.
//           A sequence is an OBJECT (created, runs, finishes).
//           Its main code lives in body(), which UVM calls on seq.start().
// =============================================================================
class add_seq extends uvm_sequence #(add_item);
  `uvm_object_utils(add_seq)

  int unsigned num_txn = 20;    // default number of transactions

  function new(string name = "add_seq");
    super.new(name);
  endfunction

  virtual task body();
    // Allow overriding the count from the command line: +NUM_TXN=100
    void'($value$plusargs("NUM_TXN=%d", num_txn));

    repeat (num_txn) begin
      // create() (not new) -> the factory can swap in add_corner_item.
      req = add_item::type_id::create("req");

      start_item(req);          // wait until the driver is ready for an item
      if (!req.randomize())     // pick random a, b (late randomization)
        `uvm_error("SEQ", "randomize() failed")
      finish_item(req);         // hand item to driver, wait for item_done()
    end
  endtask
endclass
