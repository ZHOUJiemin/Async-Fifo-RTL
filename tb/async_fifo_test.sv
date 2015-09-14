//created by jiemin on 20150910
//asynchronous fifo -- test program

program automatic async_fifo_test #(parameter DEPTH = 16,
                                    parameter PTRWIDTH = 4,
                                    parameter DWIDTH = 8)
                                   (async_fifo_if fifo_if);
//include files
`include "async_fifo_test_env.sv"

//environment
Environment env;

//start test
initial
begin
  $display("@time %4t  Simulation Start", $time);
  env = new(fifo_if);
  fifo_if.reset_L = 0;
  #100
  fifo_if.reset_L = 1;  //release reset_L
  $display("@time %4t  Reset Released", $time);
  env.gen_cfg();
  env.build();
  env.run();
  env.wrap_up();
  $display("@time %4t  Simulation Finished", $time);
end

endprogram
