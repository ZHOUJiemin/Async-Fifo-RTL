//first created by jiemin on 2015/11/18
//uvm testbench sequence
//intended to be used in the verification of async_fifo_top.v(dut)
//by using uvm
//Date          Author        Description
//2015/11/18    ZHOU Jiemin   First created

//source code starts here---------------------------------------------
class base_sequence extends uvm_sequence #(trans);
  //first thing to do: register with the uvm factory
  `uvm_object_utils(base_sequence)

  //variables
  int data_num;   //how many data in one transaction

  //constructor
  function new(string name = "trans_sequence");
    super.new(name);
  endfunction

  //this is the part when transactions are generated
  virtual task body();
    //`uvm_do_with{inline constraints}
    //`uvm_do(req)
    //the macros above can be used but is not recommended..?
    trans tx = trans::type_id::create("tx");
    //base sequence will only issue two transactions
    //to write one data
    start_item(tx);
    assert(tx.randomize());
    tx.trans_type = WRITE;
    finish_item(tx);
    //and to read one data
    start_item(tx);
    assert(tx.randomize());
    tx.trans_type = READ;
    finish_item(tx);
  endtask

endclass
