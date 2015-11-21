//first created by jiemin on 2015/11/19
//uvm testbench agent
//intended to be used in the verification of async_fifo_top.v(dut)
//by using uvm
//Date          Author        Description
//2015/11/19    ZHOU Jiemin   First created
//2015/11/20    ZHOU Jiemin   Syntax error fixed

//source code starts here---------------------------------------------
class trans_agent extends uvm_agent;  //no need to parameterised this class
  //the first thing to do: register with the uvm factory
  `uvm_component_utils(trans_agent)

  //child components
  trans_driver drv;
  trans_monitor mon;
  trans_sequencer sqr;

  //agent type
  protected uvm_active_passive_enum is_active = UVM_ACTIVE;

  //constructor
  function new(string name, uvm_component parent);
    super.new(name, parent);
  endfunction

  //build phase
  virtual function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    uvm_config_db #(uvm_active_passive_enum)::get(this, "", "is_active", is_active);
    if(is_active == UVM_ACTIVE) begin
      sqr = trans_sequencer::type_id::create("trans_sequencer", this);
      drv = trans_driver::type_id::create("trans_driver", this);
    end
    mon = trans_monitor::type_id::create("trans_monitor", this);
    `uvm_info(get_full_name(), "Build stage complete.", UVM_LOW)
  endfunction

  //connect phase
  virtual function void connect_phase(uvm_phase phase);
    if(is_active == UVM_ACTIVE)
      //no need to create a seq_item_port in your driver class or sequencer class, there is already one in the uvm_driver class
      drv.seq_item_port.connect(sqr.seq_item_export);
    `uvm_info(get_full_name(), "Connect stage complete.", UVM_LOW)
  endfunction

endclass
