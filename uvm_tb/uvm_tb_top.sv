//first created by jiemin on 2015/11/19
//uvm testbench top
//intended to be used in the verification of async_fifo_top.v(dut)
//by using uvm
//Date          Author        Description
//2015/11/19    ZHOU Jiemin   First created
//2015/11/20    ZHOU Jiemin   Add the inclusion of the interface
//                            Syntax error fixed
//source code starts here---------------------------------------------
`include "uvm_tb_pkg.sv"

//include interfaces
`include "async_fifo_if.sv"

module uvm_tb_top;
  //the first thing to do is to specify the time unit and time precision
  timeunit 1ns;
  timeprecision 1ps;

  //import and include all the necessary files and packages here
  //the tb_pkg is a package where all the agent, driver, monitor, etc. are included
  import uvm_pkg::*;
  import tb_pkg::*;


  //parameters defined here
  //things like clock period, bus width, etc. should be parameterised
  parameter WR_CLK_HALF_CYCLE = 20;
  parameter RD_CLK_HALF_CYCLE = 25;
  parameter DEPTH = 16;
  parameter PTRWIDTH = 4;
  parameter DWIDTH = 8;

  //clock and reset signals declared here
  bit wr_clk;
  bit rd_clk;
  bit reset_L;

  //now, generate the clock signals
  //the reset signal can wait, we can do that after the test has started
  initial begin
    wr_clk = 0;
    forever
    # WR_CLK_HALF_CYCLE wr_clk = ~ wr_clk;
  end

  initial begin
    rd_clk = 0;
    forever
    # RD_CLK_HALF_CYCLE rd_clk = ~ rd_clk;
  end

  //interface instantiation
  async_fifo_if intf(.wrclk(wr_clk),
                     .rdclk(rd_clk),
                     .reset_L(reset_L));

  //dut instantiation
  async_fifo_top #(.DEPTH(DEPTH),
                   .PTRWIDTH(PTRWIDTH),
                   .DWIDTH(DWIDTH))
              dut(.wclk(intf.wrclk),
                  .push(intf.push),
                  .wdata(intf.wrdata),
                  .full(intf.full),
                  .rclk(intf.rdclk),
                  .pop(intf.pop),
                  .rdata(intf.rddata),
                  .empty(intf.empty),
                  .reset_L(intf.reset_L));

  //reset generator
  initial begin
    reset_L = 0;
    #50 reset_L = 1;
  end

  //you don't need to instantiate the test
  //instead, you call the run_test() function to execute the test
  //this works because you have included the test files and they are derived from the uvm_test class
  initial begin
    //dumpfile
    $dumpfile("uvm_tb.vcd");
    //dumps all the signals in the top and below
    $dumpvar(0, top);
    $dumpon;

    //put the interface into the resource database
    uvm_config_db#(virtual async_fifo_if)::set(uvm_root::get(), "*", "interface", intf);

    //this is the function to start everything
    run_test();
    $dumpoff;
  end

endmodule
