//created by jiemin on 20150910
//asynchronous fifo -- interface

//big change on 0917, build two interfaces rather than one
//write interface, put reset_L signal here
//to make this case as simple as it can be, stop using a parameterized interface, instead restrict the bus width to 8bit
interface async_fifo_wr_if(input bit wclk);
  logic push;
  logic [7:0] wdata;
  logic full;
  bit reset_L;

clocking wrcb @(posedge wclk);
  output push;
  output wdata;
  input full;
endclocking
modport TEST(clocking wrcb, output reset_L);   //modified on 1009
endinterface

interface async_fifo_rd_if(input bit rclk);
  logic pop;
  logic [7:0] rdata;
  logic empty;

clocking rdcb @(posedge rclk);
  output pop;
  input rdata;
  input empty;
endclocking
modport TEST(clocking rdcb);   //modified on 1009
endinterface

//removed by jiemin on 0917
/*modport dut(input push,             //added on 0914
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
             output reset_L);*/
