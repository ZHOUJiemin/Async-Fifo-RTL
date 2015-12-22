//first created by jiemin on 2015/11/18
//asynchronous fifo transaction
//intended to be used in the verification of async_fifo_top.v(dut)
//by using uvm
//Date          Author        Description
//2015/11/18    ZHOU Jiemin   First created
//2015/11/20    ZHOU Jiemin   Syntax error fixed
//                            Im-parameterised
//source code starts here---------------------------------------------

class trans extends uvm_sequence_item;  //shall be parameterised maybe by using uvm_config_db..?
  //first thing to do: register it with the factory by using uvm macros
  `uvm_object_utils(trans)

  //declare the contents in the transaction
  //random write data with random delay
  rand bit [7:0] wrdata;
  rand int delay;
  //storage for the read data(not random)
  bit [7:0] rddata;
  trans_t trans_type;

  //delay from 0 cycle to 5 cycles
  constraint c_delay{
    delay inside {[0:5]};
  }

  //constructor
  //uvm_sequence_item is derived from uvm_object
  //it will be constructed during run phase
  //a "name" string shall be passed to the constructor to create the object
  //a default name is necessary..?
  function new(string name = "trans");
    super.new(name);
  endfunction

  //other methods
  //ususally a display function is required (for debug?)
  virtual task display_it();
    //write transaction
    if (trans_type == WRITE)
      //display("Write Transaction\nWrite Data = %0h, Delay = %0d Cycles\n", wrdata, delay);
      //use uvm macros!
      `uvm_info("WRTRANS", $sformatf("SFORMAT","Write Transaction\nWrite Data = %0h, Delay = %0d Cycles\n", wrdata, delay) ,UVM_LOW)
    else if(trans_type == READ)
      //display("Read Transaction\nDelay = %0d Cycles\n", delay);
      //use uvm macros!
      `uvm_info("RDTRANS", $sformatf("SFORMAT","Read Transaction\nDelay = %0d Cycles\n", delay), UVM_LOW)
    else
      //this is not supposed to happen
      `uvm_error("NGTRANS", "Wrong Type of Transaction!\n")
  endtask

endclass
