//created by jiemin on 20150910
//asynchronous fifo -- test program class Environment
//---------------------------------------------------------
//modifications
//@0911 wrdrv changed to drv, rddrv changed to mon
//@0917 typedef changed, use new interfaces
//---------------------------------------------------------
typedef virtual async_fifo_wr_if.TEST vfifo_if_wr;  //modified by jiemin on 0917
typedef virtual async_fifo_rd_if.TEST vfifo_if_rd;  //modified by jiemin on 0917
typedef logic [7:0] data_t;                     //modified by jiemin on 0917, make it more readable

//include files
`include "async_fifo_test_tranx.sv"
`include "async_fifo_test_cfg.sv"
`include "async_fifo_test_drv.sv"
`include "async_fifo_test_mon.sv"
`include "async_fifo_test_scb.sv"
`include "async_fifo_test_gen.sv"

class Environment;

  //properties
  //transactors
  Generator gen;
  Driver drv;     //modified by 0911
  Monitor mon;     //modified by 0911
  Scoreboard scb;

  //mailboxes and queues
  mailbox #(Tranx) gen2drv;  //a mailbox used to issue a write transaction
  mailbox #(Tranx) gen2mon;  //a mailbox used to issue a read transaction
  mailbox #(data_t) mon2scb;   //a mailbox used to send the read data to the scoreboard
  data_t drv2scb[$]; //a queue used to send the write data to the scoreboard

  //configuration
  Config cfg;

  //virtual interfaces
  vfifo_if_wr fifo_if_wr;   //modified on 0914
  vfifo_if_rd fifo_if_rd;   //modified on 0914

  //other variables
  /*int dwidth;*/

  //constructor
  function new(vfifo_if_wr fifo_if_wr, vfifo_if_rd fifo_if_rd); //modified on 0914
    this.fifo_if_wr = fifo_if_wr;
    this.fifo_if_rd = fifo_if_rd;
    /*this.dwidth = dwidth;*/
  endfunction

  //methods
  extern virtual function void gen_cfg();
  extern virtual function void build();
  extern virtual task run();
  extern virtual function void wrap_up();
endclass

//methods definition
function void Environment::gen_cfg();
  //generate configuration
  cfg = new();
  if(!cfg.randomize())
    $display("@time %4t  Configuration Randomization Has Failed", $time);
  else
  begin
    $display("@time %4t  Configuration Randomization Done", $time);
    cfg.display();
  end
endfunction

function void Environment::build();
  //build up the mailboxes here
  gen2drv = new();
  gen2mon = new();
  mon2scb = new();
  //build up the transactors here
  gen = new(gen2drv, gen2mon, cfg);
  drv = new(fifo_if_wr, gen2drv, drv2scb); //pass interface by using modports
  mon = new(fifo_if_rd, gen2mon, mon2scb); //pass interface by using modports
  scb = new(drv2scb, mon2scb, cfg); //the scoreboard need to know how many data are transferred
  $display("@time %4t  Environment Built Successfully", $time);
endfunction

task Environment::run();
  //get things working here
  fork
    gen.run();
//    drv.run();
//    mon.run();
//    scb.run();
  join
endtask

function void Environment::wrap_up();
  //don't know exactly what to do here
  $display("@time %4t  Test Wrapping Up", $time);
  //display the result from the scoreboard
  $display("Good Count = %0d  <-->  Bad Count = %0d", cfg.good_count, cfg.bad_count);
endfunction
