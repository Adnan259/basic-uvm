// =============================================================================
// File    : add_tests.svh
// Purpose : TESTS - choose the scenario. Pick one at run time with
//           make TN=<name>  (see add_uvm_tb.sv for the name mapping)
// =============================================================================

// -----------------------------------------------------------------------------
// Base test: builds the env and runs the default random sequence.
// -----------------------------------------------------------------------------
class add_base_test extends uvm_test;
  `uvm_component_utils(add_base_test)

  add_env env;

  function new(string name, uvm_component parent);
    super.new(name, parent);
  endfunction

  virtual function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    env = add_env::type_id::create("env", this);
  endfunction

  // Print the whole testbench tree - great for learning the hierarchy!
  virtual function void end_of_elaboration_phase(uvm_phase phase);
    uvm_top.print_topology();
  endfunction

  virtual task run_phase(uvm_phase phase);
    add_seq      seq;
    int unsigned repeats = 1;

    // make TR=<n>  ->  --testplusarg CLI_TEST_REPEATS=<n>
    // The whole sequence is run <n> times back-to-back.
    void'($value$plusargs("CLI_TEST_REPEATS=%d", repeats));

    // OBJECTION: "I am busy, don't end the simulation yet."
    // When every objection is dropped, run_phase ends -> report phases run.
    phase.raise_objection(this);
    repeat (repeats) begin
      seq = add_seq::type_id::create("seq");
      seq.start(env.agt.sqr);           // runs seq.body() on our sequencer
    end
    #20;                                // small drain so the last item is seen
    phase.drop_objection(this);
  endtask
endclass

// -----------------------------------------------------------------------------
// Random test: same as base (just a clearer name to run).
// -----------------------------------------------------------------------------
class add_rand_test extends add_base_test;
  `uvm_component_utils(add_rand_test)
  function new(string name, uvm_component parent);
    super.new(name, parent);
  endfunction
endclass

// -----------------------------------------------------------------------------
// Corner test: FACTORY OVERRIDE demo.
// Every add_item::type_id::create() now returns an add_corner_item instead.
// No change needed in the sequence, driver, monitor or env!
// -----------------------------------------------------------------------------
class add_corner_test extends add_base_test;
  `uvm_component_utils(add_corner_test)
  function new(string name, uvm_component parent);
    super.new(name, parent);
  endfunction

  virtual function void build_phase(uvm_phase phase);
    add_item::type_id::set_type_override(add_corner_item::get_type());
    super.build_phase(phase);           // override must be set BEFORE creation
  endfunction
endclass
