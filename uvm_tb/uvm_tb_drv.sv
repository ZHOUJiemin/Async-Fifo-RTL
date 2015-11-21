//first created by jiemin on 2015/11/19
//uvm testbench driver
//intended to be used in the verification of async_fifo_top.v(dut)
//by using uvm
//Date          Author        Description
//2015/11/19    ZHOU Jiemin   First created
//2015/11/20    ZHOU Jiemin   Syntax error fixed

//source code starts here---------------------------------------------
//need to be parameterised with the trans type because of the use of seq_item_port
class trans_driver extends uvm_driver #(trans);
  //first thing to do: register with the uvm factory
  `uvm_component_utils(trans_driver)

  //declare virtual interface, which is necessary to connect the testbench to the dut
  //the handler will be created here, while the content will depend on the config database and the parent class, ie: the agent
  virtual async_fifo_if vif;

  //a mailbox to inidicate that a pop cmd has been issued
  mailbox #(trans) read_cmd_sent = new(1);

  //constructor
  function new(string name, uvm_component parent);
    //this is the bottom of the whole hierarchy
    //so no components of lower level to be created here
    super.new(name, parent);
  endfunction

  //this will be called by the parent components
  function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    //get configuration from the configure database
    //get virtual interface
    if(!uvm_config_db#(virtual async_fifo_if)::get(this, "", "interface", vif))
      `uvm_fatal("NG_IF", {"virtual interface must be set for: ", get_full_name(), ".vif"})
    `uvm_info(get_full_name(), "Build stage complete.", UVM_LOW)
  endfunction

  virtual task run_phase(uvm_phase phase);
    fork
      reset();          //this is not to reset, but to monitor the reset signal
      get_and_drive();  //if not reset, do get and drive
      send_back();      //get the read data and send it back to the sequencer
    join
  endtask

  virtual task reset();
    forever begin
      //blocked until reset_L went to low
      @(negedge vif.reset_L)
      `uvm_info(get_type_name(), "Resetting signals.", UVM_LOW)
      vif.push <= 1'b 0;
      vif.wrdata <= 'b 0;
      vif.pop <= 1'b 0;
    end
  endtask

  virtual task get_and_drive();
    //declare a transaction
    trans tx;
    forever begin
      //if not reset
      if(vif.reset_L)
      begin
        seq_item_port.get_next_item(tx);    //get transaction from sequencer
        if(tx.trans_type == WRITE)          //if tx is a write transaction
          push_tx(tx);                      //drive transaction on pin level
        else                                //if tx is a read transaction
          pop_tx(tx);                       //drive transaction on pin level
        seq_item_port.item_done();          //notify the completion of the item
      end
    end
  endtask

  virtual task push_tx(trans tx);
    repeat(tx.delay)
      @ vif.wrcb;
    vif.wrcb.push <= 1'b 1;
    //wait until full flag is de-asserted
    while(vif.wrcb.full)
      @ vif.wrcb;
    //if not full, transaction is done at the current cycle
    vif.wrcb.push <= 1'b 0;
    `uvm_info(get_type_name(), $sformatf("Push Data In: %0h @ %0t", vif.wrcb.wrdata, $time), UVM_LOW)
  endtask

  virtual task pop_tx(trans tx);
    repeat(tx.delay)
      @ vif.rdcb;
    vif.rdcb.pop <= 1'b 1;
    //wait until empty flag is deasserted
    while(vrif.rdcb.empty)
      @ vif.rdcb;
    //if not empty, transaction will be done at the current cycle
    //then it is OK to deassert the pop signal
    vif.rdcb.pop <= 1'b 0;
    read_cmd_sent.put(tx);
  endtask

  virtual task send_back();
    trans tx;
    forever begin
      read_cmd_sent.get(tx);
      @ vif.rdcb;
      `uvm_info(get_type_name(), $sformatf("Popped Data Out: %0h @ %0t", vif.rdcb.rddata, $time), UVM_LOW)
      tx.rddata = vif.rdcb.rddata;
      //put the item back to the sequencer
      seq_item_port.put(tx);
    end
  endtask

endclass
