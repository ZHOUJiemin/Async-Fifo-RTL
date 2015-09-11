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

modport drv_mp(clocking wrcb_tb);   //modified on 0911
modport mon_mp(clocking rdcb_tb);   //change rddrv to mon

endinterface
