//first created by jiemin on 2015/11/19
//uvm testbench environment
//intended to be used in the verification of async_fifo_top.v(dut)
//by using uvm
//Date          Author        Description
//2015/11/19    ZHOU Jiemin   First created
//2015/11/20    ZHOU Jiemin   Syntax error fixed

//source code starts here---------------------------------------------
class trans_env extends uvm_env;  //no need to parameterised this class
  //first thing to do: register with the uvm factory
  `uvm_component_utils(trans_env)

  //child components
  trans_agent wr_agt;
  trans_agent rd_agt;
  trans_scb scb;

  //constructor
  function new(string name, uvm_component parent);
    super.new(name, parent);
  endfunction

  //build phase
  virtual function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    //config before building
    uvm_config_db#(int)::set(this, "write_agent", "is_active", UVM_ACTIVE);
    uvm_config_db#(int)::set(this, "read_agent", "is_active", UVM_ACTIVE);
    //create child components
    wr_agt = trans_agent::type_id::create("write_agent", this);
    rd_agt = trans_agent::type_id::create("read_agent", this);
    scb = trans_scb::type_id::create("scoreborad", this);
    `uvm_info(get_full_name(), "Build stage complete.", UVM_LOW);
  endfunction

  //connect phase
  virtual function void connect_phase(uvm_phase phase);
    wr_agt.mon.item_collected_port.connect(scb.push_data_collected.analysis_export);
    rd_agt.mon.item_collected_port.connect(scb.pop_data_collected.analysis_export);
    `uvm_info(get_full_name(), "Connect stage complete.", UVM_LOW);
  endfunction
endclass
