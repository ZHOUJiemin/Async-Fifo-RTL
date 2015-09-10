//created by jiemin on 20150910
//asynchronous fifo -- test program class Generator
`define WRITE 0
`define READ 1
class Generator;
  //properties
  //tranx
  Tranx wrtranx;
  Tranx rdtranx;

  //mailboxes
  mailbox #(Tranx) gen2wrdrv;
  mailbox #(Tranx) gen2rddrv;

  //Configuration
  Config cfg;

  //other variables
  int wr_remain;  //remaining write data
  int rd_remain;  //remaining read data

  //methods
  //constructor
  function new(mailbox #(Tranx) gen2wrdrv,
               mailbox #(Tranx) gen2rddrv,
               Config cfg);
     this.gen2wrdrv = gen2wrdrv;
     this.gen2rddrv = gen2rddrv;
     this.cfg = cfg;
     wr_remain = 0;
     rd_remain = 0;
  endfunction

  virtual task void run();
    wr_remain = cfg.totaldatanum;  //data need to be written
    rd_remain = cfg.totaldatanum;  //data need to be read
    while(wr_remain || rd_remain)  //when there is still data to transfer
    fork                           //start wrdrv and rddrv at the same time
      //generate a write transaction
      if(wr_remain)
      begin:wr_tranx_gen
        wrtranx = new(wr_remain, WRITE);      //limit the number of the data in one transaction
        if(!wrtranx.randomize())
          $display("@time %4t  Write Transaction Randomization Has Failed", $time);
        else
        begin
          $display("@time %4t  A New Write Transaction Has Been Generated", $time);
          gen2wrdrv.push(wrtranx);            //send this Tranx to wrdrv
          wr_remain =- wrtranx.datanum;       //calculate the remaining data number
        end
      end:wr_tranx_gen

      //generate a read transaction
      if(rd_remain)
      begin:rd_tranx_gen
        rdtranx = new(rd_remain, READ);
        if(!rdtranx.randomize())
          $display("@time %4t  Read Transaction Randomization Has Failed", $time);
        else
        begin
          $display("@time %4t  A New Read Transaction Has Been Generated", $time);
          gen2rddrv.push(rdtranx);            //send this Tranx to rddrv
          rd_remain =- rdtranx.datanum;       //calculate the remaining data number
        end
      end:rd_tranx_gen
    join_none
    wait fork;  //wait until all threads to finish
  endtask

endclass
