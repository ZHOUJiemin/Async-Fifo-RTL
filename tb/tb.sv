//created by jiemin on 20150909
//asynchronous fifo -- systemverilog testbench

//time unit and time precision
timeunit 1ns;
timeprecision 1ps;

//include files
`include "async_fifo_top.v"
`include "async_fifo_if.sv"
`include "async_fifo_test.sv"

module tb;

//parameters
parameter DEPTH = 16;
parameter PTRWIDTH = 4;
parameter DWIDTH = 8;

parameter RDHALFCYCLE = 10; //read clock cycle 20ns
parameter RDCYCLE = 2*RDHALFCYCLE;
parameter WRHALFCYCLE = 15; //write clock cycle 30ns
parameter WRCYCLE = 2*WRHALFCYCLE;
parameter WRCLKSTART = 50;  //start the write clock from time 50
parameter RDCLKSTART = 60;  //start the read clock from time 60

//variables
bit wclk;
bit rclk;

//instantiation
//interface
async_fifo_wr_if fifo_if_drv (
    .wclk(wclk)
  );

async_fifo_rd_if fifo_if_mon (
    .rclk(rclk)
  );

//dut
async_fifo_top #(DEPTH, PTRWIDTH, DWIDTH) fifo (
    .wclk(fifo_if_drv.wclk),
    .push(fifo_if_drv.push),
    .wdata(fifo_if_drv.wdata),
    .full(fifo_if_drv.full),
    .rclk(fifo_if_mon.rclk),
    .pop(fifo_if_mon.pop),
    .rdata(fifo_if_mon.rdata),
    .empty(fifo_if_mon.empty),
    .reset_L(fifo_if_drv.reset_L)
  );

//test program
async_fifo_test #(DEPTH, PTRWIDTH, DWIDTH) test(
    .fifo_if_drv(fifo_if_drv),
    .fifo_if_mon(fifo_if_mon)
  );

//clock generator
initial
begin
wclk = 0;
#WRCLKSTART
forever #WRHALFCYCLE wclk = ~wclk;
end

initial
begin
rclk = 0;
#RDCLKSTART
forever #RDHALFCYCLE rclk = ~rclk;
end

endmodule
