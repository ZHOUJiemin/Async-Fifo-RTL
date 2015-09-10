//created by jiemin on 20150910
//asynchronous fifo -- test program class Driver
class Driver;
  //properties
  //virtual interface
  vfifo_if fifo_if;
  //mailboxes
  mailbox #(Tranx) gen2drv; //gen2wrdrv, gen2rddrv
  //data
  data test_data[];         //dynamic array, allocate memory for it before using it
  //other variables
  int wr_rd;  //transaction type
  int remain; //data
  function new(vfifo_if fifo_if,
               mailbox #(Tranx) gen2drv,
               data drv2scb[$]);
  
  endfunction

endclass
