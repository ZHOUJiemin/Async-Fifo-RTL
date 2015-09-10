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

clocking wrcb_tb @(posedge wclk);
  output push;
  output wdata;
  input full;
endclocking

clocking rdcb_tb @(posedge rclk);
  output pop;
  input rdata;
  input empty;
endclocking

modport wrdrv_mp(clocking wrcb_tb);
modport rddrv_mp(clocking rdcb_tb);

endinterface
