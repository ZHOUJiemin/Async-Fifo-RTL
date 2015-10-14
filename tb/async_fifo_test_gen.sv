//created by jiemin on 20150910
//asynchronous fifo -- test program class Generator
class Generator;
  //properties
  //tranx
  Tranx wrtranx;
  Tranx rdtranx;

  //mailboxes
  mailbox #(Tranx) gen2drv;
  mailbox #(Tranx) gen2mon;

  //Configuration
  Config cfg;

  //other variables
  int wr_remain;  //remaining write data
  int rd_remain;  //remaining read data

  //methods
  //constructor
  function new(mailbox #(Tranx) gen2drv,
               mailbox #(Tranx) gen2mon,
               Config cfg);
     this.gen2drv = gen2drv;
     this.gen2mon = gen2mon;
     this.cfg = cfg;
     wr_remain = 0;
     rd_remain = 0;
  endfunction

  virtual task run();
    int write_done = 0;          //variables act as
    int read_done = 0;           //flags for write complete & read complete
    $display ("@time %4t  Running Transactor: Generator", $time);
    wr_remain = cfg.totaldatanum;  //data need to be written
    rd_remain = cfg.totaldatanum;  //data need to be read
    $display ("@time %4t  %0d Data to Write, %0d Data to Read", $time, wr_remain, rd_remain);

    fork                           //start wrdrv and rddrv at the same time
      //generate a write transaction
      while(!write_done)             //if there is still data to write
      begin:wr_tranx_gen
        wrtranx = new(wr_remain);      //limit the number of the data in one transaction
        if(!wrtranx.randomize())
          $display("@time %4t  Write Transaction Randomization Has Failed", $time);
        else
        begin
          $display("@time %4t  A New Write Transaction Has Been Generated", $time);
          wrtranx.display;
          gen2drv.put(wrtranx);            //send this Tranx to wrdrv
          wr_remain = wr_remain - wrtranx.datanum;       //calculate the remaining data number
          $display("@time %4t  Write Remaining %0d", $time, wr_remain);
          if(wr_remain == 0)
            write_done = 1;
//          break;
        end
      end:wr_tranx_gen

      //generate a read transaction
      while(!read_done)
      begin:rd_tranx_gen
        rdtranx = new(rd_remain);
        if(!rdtranx.randomize())
          $display("@time %4t  Read Transaction Randomization Has Failed", $time);
        else
        begin
          $display("@time %4t  A New Read Transaction Has Been Generated", $time);
          rdtranx.display;
          gen2mon.put(rdtranx);            //send this Tranx to rddrv
          rd_remain = rd_remain - rdtranx.datanum;       //calculate the remaining data number
          $display("@time %4t  Read Remaining %0d", $time, rd_remain);
          if(rd_remain == 0)
            read_done = 1;
//            break;
        end
      end:rd_tranx_gen
    join_none
    wait fork;  //wait until all threads to finish
  endtask

endclass
