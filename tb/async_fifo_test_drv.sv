//created by jiemin on 20150910
//asynchronous fifo -- test program class Driver
class Driver;
  //properties
  //virtual interface
  vfifo_if_wr fifo_if;
  //mailboxes and queue
  mailbox #(Tranx) gen2drv; //gen2drv
  mailbox #(data_t) drv2scb;

  //transaction
  Tranx tranx;
  int interval;
  int dataintranx;          //data number in one transaction
  data_t write_data[];         //dynamic array, allocate memory for it before using it

  //other variables
  int tranxid;
  int remain;
  int wr_success;

  function new(vfifo_if_wr fifo_if,
               mailbox #(Tranx) gen2drv,
               mailbox #(data_t) drv2scb);
    this.fifo_if = fifo_if;
    this.gen2drv = gen2drv;
    this.drv2scb = drv2scb;
    wr_success = 0;
    tranxid = 0;
  endfunction

  virtual task send(input int interval, ref data_t write_data[]);
    repeat(interval)  //wait for several cycles before transfer
      @(fifo_if.wrcb) $display("@time %4t  Write Idle Cycle", $time);
    foreach(write_data[i])
    begin
      @(fifo_if.wrcb)
      begin
        //if last transaction is successful, display it
        if(wr_success)
        begin
          wr_success = 0;
          $display("@time %4t  Data is Pushed In, Data = 0x%2x", $time, write_data[i-1]);
        end
        //do this transaction
        //if full flag is asserted
        while(fifo_if.wrcb.full)
        begin
          //fifo_if.wrcb.push <= 1'b 0;
          wr_success = 0;
          $display("@time %4t  FIFO is Full, Failed to Issue a Push Command", $time);
          $display("@time %4t  Wait for 1 WrClk Cycle", $time);
          @(fifo_if.wrcb);
        end
        fifo_if.wrcb.push <= 1'b 1;
        fifo_if.wrcb.wdata <= write_data[i];
        wr_success = 1;
        $display("@time %4t  Issued a Push Command", $time);
      end
    end
  endtask

  virtual task run();
    $display ("@time %4t  Running Transactor: Driver", $time);
    do begin
    gen2drv.get(tranx);             //get the transaction from the mailbox
    $display("WR_TRANX_ID %0d", tranxid++ );
//    tranx.display;
    interval = tranx.interval;      //get interval
    dataintranx = tranx.datanum;    //get number of data
    write_data = new [dataintranx];  //allocate memory
    foreach(write_data[i])           //randomize data
    begin
      write_data[i] = $urandom_range(0,255);
      drv2scb.put(write_data[i]);   //send the data to scoreboard
    end
    send(interval, write_data);
    $display("@time %4t  Write Transaction: Pushed %0d Data Out", $time, dataintranx);
    end while(tranx.remain > tranx.datanum); //if there are still data to send
  endtask

endclass
