//first created by jiemin on 2015/11/18
//asynchronous fifo interface
//intended to be used in the verification of async_fifo_top.v(dut)
//by using uvm
//Date          Author        Description
//2015/11/18    ZHOU Jiemin   First created

//source code starts here---------------------------------------------

interface async_fifo_if #(parameter DWIDTH = 8)
                         (input bit wrclk,
                          input bit rdclk,
                          input bit reset_L);
  //write interface
  logic push;
  logic full;
  logic [DWIDTH-1:0] wrdata;
  //read interface
  logic pop;
  logic empty;
  logic [DWIDTH-1:0] rddata;

  //write clocking block
  clocking wrcb @(posedge wrclk);
    output push;
    input full;
    output wrdata;
  endclocking

  //write modport for testbench
  modport wrmp (clocking wrcb);

  //read clocking block
  clocking rdcb @(posedge rdclk);
    output pop;
    input empty;
    input rddata;
  endclocking

  //read modport for testbench
  modport rdmp (clocking rdcb);

endinterface
