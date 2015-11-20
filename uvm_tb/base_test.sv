//first created by jiemin on 2015/11/19
//uvm testbench base test
//intended to be used in the verification of async_fifo_top.v(dut)
//by using uvm
//Date          Author        Description
//2015/11/19    ZHOU Jiemin   First created
//2015/11/20    ZHOU Jiemin   Syntax error fixed

//source code starts here---------------------------------------------
class base_test extends uvm_test;
  //first thing to do: register with the uvm factory
  `uvm_component_utils(base_test)

  //child components
  trans_env env;

  //heirarchy printer
  uvm_table_printer printer;

  //constructor
  function new(string name, uvm_component parent);
    super.new(name, parent);
  endfunction

  //build phase
  virtual function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    env = trans_env::type_id::create("trans_env", this);
    //printer should also be built by using a new function
    printer = new();
    printer.knobs.depth = -1; //print everything
  endfunction

  virtual task run_phase(uvm_phase phase);
//    phase.phase_done.set_drain_time(this, 1500);

    base_sequence wr_seq;
    base_sequence rd_seq;
    phase.raise_objection(this);
    wr_seq = base_sequence::type_id::create("write_sequence");
    rd_seq = base_sequence::type_id::create("read_sequence");
    //should be done cocurrently
    wr_seq.start(env.wr_agt.sqr);
    rd_seq.start(env.rd_agt.sqr);
    phase.drop_objection(this);
  endtask

  //end of elaboration phase
  virtual function void end_of_elaboration_phase(uvm_phase phase);
    //sprint is just like print, except it returns the string rather than displays it
    `uvm_info(get_type_name(), $sformatf("Printing the test topology :\n%s", this.sprint(printer)),UVM_LOW)
  endfunction
endclass
