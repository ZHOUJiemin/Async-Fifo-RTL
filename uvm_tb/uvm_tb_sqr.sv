//first created by jiemin on 2015/11/19
//uvm testbench sequencer
//intended to be used in the verification of async_fifo_top.v(dut)
//by using uvm
//Date          Author        Description
//2015/11/19    ZHOU Jiemin   First created

//source code starts here---------------------------------------------
class trans_sequencer extends uvm_sequencer #(trans);
  //first thing to do: register with the uvm factory
  `uvm_component_utils(trans_sequencer)

  //sequencer may be the easiest, the simpliest class in uvm
  //no changes need to be made
  //constructor
  function new(string name, uvm_component parent);
    super.new(name, parent);
  endfunction

endclass
