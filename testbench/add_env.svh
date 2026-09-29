// =============================================================================
// File    : add_env.svh
// Purpose : ENVIRONMENT - container for agent(s) + scoreboard (+ coverage).
//           Wires the monitor's analysis port to the scoreboard.
// =============================================================================
class add_env extends uvm_env;
  `uvm_component_utils(add_env)

  add_agent      agt;
  add_scoreboard sb;

  function new(string name, uvm_component parent);
    super.new(name, parent);
  endfunction

  virtual function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    agt = add_agent     ::type_id::create("agt", this);
    sb  = add_scoreboard::type_id::create("sb",  this);
  endfunction

  // monitor.ap  --->  scoreboard.imp
  virtual function void connect_phase(uvm_phase phase);
    super.connect_phase(phase);
    agt.mon.ap.connect(sb.imp);
  endfunction
endclass
