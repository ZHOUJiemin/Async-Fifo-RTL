//created by jiemin on 20150910
//asynchronous fifo -- test program
//modified by jiemin on 20151009 added virtual interface declaration

program automatic async_fifo_test #(parameter DEPTH = 16,
                                    parameter PTRWIDTH = 4,
                                    parameter DWIDTH = 8)
                                   (async_fifo_wr_if.TEST fifo_if_wr,
                                    async_fifo_rd_if.TEST fifo_if_rd);
//include files
`include "async_fifo_test_env.sv"

//virtual interface
virtual interface async_fifo_wr_if.TEST virtual_fifo_if_wr;
virtual interface async_fifo_rd_if.TEST virtual_fifo_if_rd;

//environment
Environment env;

//start test
initial
begin
  $display("@time %4t  Simulation Start", $time);
  virtual_fifo_if_wr = fifo_if_wr;
  virtual_fifo_if_rd = fifo_if_rd;
  env = new(virtual_fifo_if_wr, virtual_fifo_if_rd);
  virtual_fifo_if_wr.reset_L = 0;
  #100
  virtual_fifo_if_wr.reset_L = 1;  //release reset_L
  $display("@time %4t  Reset Released", $time);
  env.gen_cfg();
  env.build();
  env.run();
  env.wrap_up();
  $display("@time %4t  Simulation Finished", $time);
end

endprogram
