//created by jiemin on 20150910
//asynchronous fifo -- test program class Environment
typedef virtual async_fifo_if vfifo_if;
typedef logic [7:0] data;

//include files
`include "async_fifo_test_tranx.sv"
`include "async_fifo_test_cfg.sv"
`include "async_fifo_test_drv.sv"
`include "async_fifo_test_scb.sv"
`include "async_fifo_test_gen.sv"

class Environment;

  //properties
  //transactors
  Generator gen;
  Driver wrdrv;
  Driver rddrv;
  Scoreboard scb;

  //mailboxes and queues
  mailbox #(Tranx) gen2wrdrv;  //a mailbox used to issue a write transaction
  mailbox #(Tranx) gen2rddrv;  //a mailbox used to issue a read transaction
  mailbox #(data) rddrv2scb;   //a mailbox used to send the read data to the scoreboard
  data wrdrv2scb[$]; //a queue used to send the write data to the scoreboard

  //configuration
  Config cfg;

  //virtual interfaces
  vfifo_if fifo_if;

  //constructor
  function new(vfifo_if fifo_if);
    this.fifo_if = fifo_if;
  endfunction

  //methods
  extern virtual function void gen_cfg();
  extern virtual function void build();
  extern virtual function void run();
  extern virtual function void wrap();
endclass

//methods definition
function void Environment::gen_cfg();
  //generate configuration
  cfg = new();
  if(!cfg.randomize())
    $display("@time %4t  Configuration Randomization Has Failed");
  else
  begin
    $display("@time %4t  Configuration Randomization Done");
    cfg.display();
  end
endfunction

function void Environment::build();
  //build up the mailboxes here
  gen2wrdrv = new();
  gen2rddrv = new();
  rddrv2scb = new();
  //build up the transactors here
  gen = new(gen2wrdrv, gen2rddrv, cfg);
  wrdrv = new(fifo_if.wrdrv_mp, gen2wrdrv, wrdrv2scb); //pass interface by using modports
  rddrv = new(fifo_if.rddrv_mp, gen2rddrv, rddrv2scb); //pass interface by using modports
  scb = new(wrdrv2scb, rddrv2scb, cfg); //the scoreboard need to know how many data are transferred
endfunction

function void Environment::run();
  //get things working here
  fork
    gen.run();
    wrdrv.run();
    rddrv.run();
    scb.run();
  join
endfunction

function void Environment::wrap();
  //don't know exactly what to do here
  $display("@time %4t  Test Wrapping Up");
  //display the result from the scoreboard
  $display("Good Count = %0d  <-->  Bad Count = %0d", cfg.good_count, cfg.bad_count);
endfunction
