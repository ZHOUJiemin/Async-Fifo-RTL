//first created by jiemin on 2015/11/18
//uvm testbench package
//intended to be used in the verification of async_fifo_top.v(dut)
//by using uvm
//Date          Author        Description
//2015/11/18    ZHOU Jiemin   First created
//2015/11/20    ZHOU Jiemin   Removed the inclusion of the interface in the package
//                            Added typedef
//source code starts here---------------------------------------------
`ifndef TB_PKG
`define TB_PKG

`include "uvm_macros.svh"

package tb_pkg;

  //uvm_pkg should be import here in spite of that it will be
  //import again in the tb_top, because the files included below
  //also need to refer to the contents in the uvm package
  import uvm_pkg::*;

  //typedef
  typedef enum{WRITE, READ} trans_t;

  //when including the files, attentions must be paid to the order of the files
  //uvm objects (uvm sequence item)
  `include "trans.sv"
  `include "base_seq.sv"
  //uvm components (hierarchical structrue)
  `include "uvm_tb_sqr.sv"
  `include "uvm_tb_drv.sv"
  `include "uvm_tb_mon.sv"
  `include "uvm_tb_agt.sv"
  `include "uvm_tb_scb.sv"
  `include "uvm_tb_env.sv"
  //uvm test
  `include "base_test.sv"

endpackage

`endif
