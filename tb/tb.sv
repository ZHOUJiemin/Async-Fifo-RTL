//created by jiemin on 20150909
//asynchronous fifo -- systemverilog testbench
<<<<<<< HEAD
module tb;
=======

//include files
`include "async_fifo_top.v"
`include "async_fifo_if.sv"
`include "async_fifo_test.sv"

module tb;
//time unit and time precision
timeunit 1ns;
timeprecision 1ps;

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
async_fifo_if #(.DWIDTH(DWIDTH)) fifo_if (
    .wclk(wclk),
    .rclk(rclk)
  );

//dut
async_fifo_top #(DEPTH, PTRWIDTH, DWIDTH) fifo (
    .wclk(fifo_if.wclk),
    .push(fifo_if.push),
    .wdata(fifo_if.wdata),
    .full(fifo_if.full),
    .rclk(fifo_if.rclk),
    .pop(fifo_if.pop),
    .rdata(fifo_if.rdata),
    .empty(fifo_if.empty),
    .reset_L(fifo_if.reset_L)
  );

//test program
async_fifo_test #(DEPTH, PTRWIDTH, DWIDTH) test(
    .fifo_if(fifo_if)
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
>>>>>>> master

endmodule
