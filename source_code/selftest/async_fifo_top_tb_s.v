//created by jiemin on 20150909
//asynchronous fifo -- self-test testbench
module async_fifo_top_tb_s;

//time unit and time precision
`timescale 1ns/1ps

//parameters
parameter RDHALFCYCLE = 10; //read clock cycle 20ns
parameter RDCYCLE = 2*RDHALFCYCLE;
parameter WRHALFCYCLE = 15; //write clock cycle 30ns
parameter WRCYCLE = 2*WRHALFCYCLE;

parameter DEPTH = 16;       //fifo depth 16
parameter PTRWIDTH = 4;     //ptr width 5 bit [4:0]
parameter DWIDTH = 8;       //data width 8 bit [7:0]

parameter DELAY = 1;        //delay 1ns

//variables
reg wclk;
reg rclk;
reg reset_L;
reg push;
reg pop;
reg [DWIDTH-1:0] wdata;
wire [DWIDTH-1:0] rdata;
wire full;
wire empty;

integer fp;

reg wr_success;
reg rd_success;

//clock generation
initial
begin
  wclk = 0;
  #10
  forever #WRHALFCYCLE wclk = ~wclk;
end

initial
begin
  rclk = 0;
  #10
  forever #RDHALFCYCLE rclk = ~rclk;
end

//instantiation
async_fifo_top #(DEPTH, PTRWIDTH, DWIDTH) dut
                (.wclk(wclk),
                 .push(push),
                 .wdata(wdata),
                 .full(full),
                 .rclk(rclk),
                 .pop(pop),
                 .rdata(rdata),
                 .empty(empty),
                 .reset_L(reset_L));

//functions and tasks
//keep writing until full, then wait until the fifo can be written again
task write_fifo();
begin
  repeat(16)
  begin
    @(posedge wclk)
    begin
    //for debug
    /*$display("rdptr_bin = %4b, wrptr_bin = %4b, rdptr_gray = %4b, wrptr_gray = %4b",
              async_fifo_top_tb_s.dut.rdptr_bin,
              async_fifo_top_tb_s.dut.wrptr_bin,
              async_fifo_top_tb_s.dut.rdptr_gray,
              async_fifo_top_tb_s.dut.wrptr_gray);
    if(full)
      $display("FIFO state is FULL!");
    if(empty)
      $display("FIFO state is EMPTY!");*/
    //$display("rdptr_bin = %4b, wrptr_bin = %4b", async_fifo_top_tb_s.dut.ctrl_rd.wrptr_bin, async_fifo_top_tb_s.dut.ctrl_wr.rdptr_bin);
    if(wr_success)
    begin
      wr_success = ~wr_success;
      $display("@time = %0t  Push Data In Successfully, Data = 0x%02x", $time, wdata);
    end
    if(!full)  //if not full
    begin
      push <= #DELAY 1; //push request
      wdata <= #DELAY ($urandom_range(0,15));  //write data
      wr_success <= 1;
      $display("@time = %0t  Sent a Push Request", $time);
    end
    else  //if full
    begin
      wr_success <= 0;
      $display("@time = %0t  Push Data In Failed, FIFO is full!", $time, wdata);
    end
    end
  end
end
endtask

//keep reading until empty, then wait until the fifo can be read again
task read_fifo();
begin
  repeat(16)
  begin
    @(posedge rclk)
    begin
      //for debug
      /*$display("rdptr_bin = %4b, wrptr_bin = %4b, rdptr_gray = %4b, wrptr_gray = %4b",
                async_fifo_top_tb_s.dut.rdptr_bin,
                async_fifo_top_tb_s.dut.wrptr_bin,
                async_fifo_top_tb_s.dut.rdptr_gray,
                async_fifo_top_tb_s.dut.wrptr_gray);
      if(full)
        $display("FIFO state is FULL!");
      if(empty)
        $display("FIFO state is EMPTY!");*/
      //$display("rdptr_bin = %4b, wrptr_bin = %4b", async_fifo_top_tb_s.dut.ctrl_rd.wrptr_bin, async_fifo_top_tb_s.dut.ctrl_wr.rdptr_bin);
      if(rd_success)
      begin
        rd_success = ~rd_success;
        $display("@time = %0t  Pop Data Out Successfully, Data = 0x%02x", $time, rdata);
      end
      if(!empty)  //if not empty
      begin
        pop <= #DELAY 1;  //pop request
        rd_success <= 1;
        $display("@time = %0t  Sent a Pop Request", $time);
      end
      else  //if empty
      begin
        rd_success <= 0;
        $display( "@time = %0t  Pop Data Out Failed, FIFO is empty", $time);
      end
    end
  end
end
endtask

//signal driving process
initial
begin
  //create log file
//  fp = $fopen("async_fifo_top_test.log","w+");
  $display("----------Start Simulation----------");
  $display("@time = %0t  Signal Initialization", $time);
  //initialization
  reset_L = 0;  //assert reset
  push = 0;
  pop = 0;
  wdata = 0;
  wr_success = 0;
  rd_success = 0;
  #100          //start simulation at time 100ns
  reset_L = 1;
  $display("@time = %0t  Released Reset and Start Driving Signals", $time);
  //start to read when empty
  fork
  read_fifo();
  write_fifo();
  join
  $display( "@time = %0t  Simulation Finished", $time);
  #100 $finish;  //terminate the test after 100ns
end

endmodule
