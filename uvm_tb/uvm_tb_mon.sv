//first created by jiemin on 2015/11/19
//uvm testbench monitor
//intended to be used in the verification of async_fifo_top.v(dut)
//by using uvm
//Date          Author        Description
//2015/11/19    ZHOU Jiemin   First created
//2015/11/20    ZHOU Jiemin   Syntax error fixed

//source code starts here---------------------------------------------
class trans_monitor extends uvm_monitor;    //unlike the driver, no need to parameterise it with the trans type
  //first thing to do: register with the uvm factory
  `uvm_component_utils(trans_monitor)

  //string to look up for the specified interface
  //string mon_if_name;
  //declare virtual interface, use the same one as the driver dose
  virtual async_fifo_if vif;

  //collected transaction and cloned transaction
  trans collected_tx;
  trans cloned_tx;
  int collected_data_num = 0;

  //analysis port
  uvm_analysis_port #(trans) item_collected_port;
  //constructor
  function new(string name, uvm_component parent);
    super.new(name, parent);
  endfunction

  virtual function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    //build virtual interface
    /*if(!uvm_config_db#(string)::get(this, "", "mon_if_name", mon_if_name))
      `uvm_fatal("NG_STRING", {"Need interface name for: ", get_full_name(), ".mon_if_name"})
    `uvm_info(get_type_name(), $sformatf("Interface used = %0s", mon_if_name), UVM_LOW)*/
    if(!uvm_config_db#(virtual async_fifo_if)::get(this, "", "async_fifo_if", vif))
      `uvm_fatal("NG_IF", {"Virtual interface must be set for: ", get_full_name(), ".vif"})
    //build analysis port
    //never use a factory create function to build a port
    //use new(name, parent) function to build a port
    item_collected_port = new("item_collected_port", this);
    //build transactions
    collected_tx = trans::type_id::create("collected_tx");
    cloned_tx = trans::type_id::create("cloned_tx");
    //build phase done
    `uvm_info(get_full_name(), "Build stage complete.", UVM_LOW)
  endfunction

  virtual task run_phase(uvm_phase phase);
    fork
      collect_push_data();
      collect_pop_data();
    join
  endtask

  virtual function void report_phase(uvm_phase phase);
    `uvm_info(get_type_name(), $sformatf("Report: Collected Data Number = %0d", collected_data_num), UVM_LOW)
  endfunction

  virtual task collect_push_data();
    forever begin
      while(vif.full)  //if full, wait
        @ vif.wrclk;
      if(vif.push) begin  //if push is asserted
        collected_tx.wrdata = vif.wrdata;
        $cast(cloned_tx, collected_tx.clone());
        item_collected_port.write(cloned_tx);
        collected_data_num ++;
      end
      @ vif.wrclk;
    end
  endtask

  virtual task collect_pop_data();
    forever begin
      while(vif.empty) //if empty, wait
        @ vif.rdclk;
      if(vif.pop) begin//if pop is asserted
        @vif.rdclk;
        collected_tx.rddata = vif.rddata;
        $cast(cloned_tx, collected_tx.clone());
        item_collected_port.write(cloned_tx);
        collected_data_num ++;
      end
    end
  endtask

endclass
