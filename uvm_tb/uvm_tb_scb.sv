//first created by jiemin on 2015/11/19
//uvm testbench scoreborad
//intended to be used in the verification of async_fifo_top.v(dut)
//by using uvm
//Date          Author        Description
//2015/11/19    ZHOU Jiemin   First created
//2015/11/20    ZHOU Jiemin   Syntax error fixed

//source code starts here---------------------------------------------
class trans_scb extends uvm_scoreboard;
  //first thing to do: register with the uvm factory
  `uvm_component_utils(trans_scb)

  //analysis port
  uvm_tlm_analysis_fifo #(trans) push_data_collected;
  uvm_tlm_analysis_fifo #(trans) pop_data_collected;

  //transactions
  trans push_data;
  trans pop_data;

  //constructor
  function new(string name, uvm_component parent);
    super.new(name, parent);
  endfunction

  //build phase
  virtual function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    push_data_collected = new("push_data_collected", this);
    pop_data_collected = new("pop_data_collected", this);
    push_data = trans::type_id::create("push_data");
    pop_data = trans::type_id::create("pop_data");
    `uvm_info(get_full_name(), "Build stage complete.", UVM_LOW);
  endfunction

  //run phase
  virtual task run_phase(uvm_phase phase);
    watcher();
  endtask

  virtual task watcher();
    forever begin
      push_data_collected.get(push_data);
      pop_data_collected.get(pop_data);
      compare_data();
    end
  endtask

  virtual task compare_data();
    if (push_data.wrdata == pop_data.rddata)
      `uvm_info(get_type_name(), $sformatf("Compare OK! Write Data = %0h, Read Data = %0h", push_data.wrdata, pop_data.rddata), UVM_LOW)
    else
      `uvm_error(get_type_name(), $sformatf("Compare NG! Write Data = %0h, Read Data = %0h", push_data.wrdata, pop_data.rddata))
  endtask
endclass
