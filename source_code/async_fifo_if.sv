//created by jiemin on 20150910
//asynchronous fifo -- interface
interface async_fifo_if#(parameter DWIDTH = 8)(input bit wclk, rclk);
  logic push;
  logic [DWIDTH-1:0] wdata;
  logic full;
  logic pop;
  logic [DWIDTH-1:0] rdata;
  logic empty;
  bit reset_L;

clocking wrcb @(posedge wclk);
  output push;
  output wdata;
  input full;
endclocking

clocking rdcb @(posedge rclk);
  output pop;
  input rdata;
  input empty;
endclocking

modport dut(input push,             //added on 0914
            input wdata,
            output full,
            input pop,
            output rdata,
            output empty,
            input reset_L);

modport test(output push,           //added on 0914
             output wdata,
             input full,
             output pop,
             input rdata,
             input empty,
             output reset_L);

modport drv_mp(clocking wrcb);   //modified on 0914
modport mon_mp(clocking rdcb);   //change rddrv to mon

endinterface
