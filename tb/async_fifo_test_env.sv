//created by jiemin on 20150910
//asynchronous fifo -- test program class Environment
typedef virtual async_fifo_if vfifo_if;
//include files
`include "async_fifo_test_drv.sv"
`include "async_fifo_test_scb.sv"
class Environment;

  //properties
  //transactors
  Driver wrdrv;
  Driver rddrv;
  Scoreboard scb;
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

endfunction

function void Environment::build();

endfunction

function void Environment::run();

endfunction

function void Environment::wrap();

endfunction
