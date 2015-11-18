//created by jiemin on 20150909
//asynchronous fifo -- systemverilog testbench
//top file

//time unit and time precision
timeunit 1ns;
timeprecision 1ns;

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
async_fifo_wr_if fifo_if_wr (
    .wclk(wclk)
  );

async_fifo_rd_if fifo_if_rd (
    .rclk(rclk)
  );

//dut
async_fifo_top #(DEPTH, PTRWIDTH, DWIDTH) fifo (
    .wclk(fifo_if_wr.wclk),
    .push(fifo_if_wr.push),
    .wdata(fifo_if_wr.wdata),
    .full(fifo_if_wr.full),
    .rclk(fifo_if_rd.rclk),
    .pop(fifo_if_rd.pop),
    .rdata(fifo_if_rd.rdata),
    .empty(fifo_if_rd.empty),
    .reset_L(fifo_if_wr.reset_L)
  );

//test program
async_fifo_test #(DEPTH, PTRWIDTH, DWIDTH) test(
    .fifo_if_wr(fifo_if_wr),
    .fifo_if_rd(fifo_if_rd)
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
