//created by jiemin on 20150911
//asynchronous fifo -- test program class Monitor
class Monitor;
  //properties
  //interface
  vfifo_if_rd fifo_if;

  //mailboxes and queues
  mailbox #(Tranx) gen2mon;
  mailbox #(data_t) mon2scb;

  //transactions
  Tranx tranx;
  int interval;
  int dataintranx;
  data_t read_data[];

  //other variables
  int tranxid;
  int remain;

  //methods
  function new(vfifo_if_rd fifo_if,
               mailbox #(Tranx) gen2mon,
               mailbox #(data_t) mon2scb);  //fixed a bug on 0917
    this.fifo_if = fifo_if;
    this.gen2mon = gen2mon;
    this.mon2scb = mon2scb;
  endfunction

  virtual task receive(input int interval, ref data_t read_data[]);
    event rd_cmd_issued;
    event rd_data_getone;
    event rd_data_getall;

    repeat(interval)
      @(fifo_if.rdcb);
      //$display("@time %4t  Read Idle Cycle", $time);

    fork//start three threads
    //thread1 issue a new transaction for specified times
    begin
      for(int i = 0; i< read_data.size(); i++)
      begin
        fifo_if.rdcb.pop <= 1'b 1;
        $display("@time %4t  Assert Pop Signal", $time);
        -> rd_cmd_issued;
        @(fifo_if.rdcb);
        wait(rd_data_getone.triggered);
      end
      //stop transaction
      wait(rd_data_getall.triggered);
      fifo_if.rdcb.pop <= 1'b 0;
    end

    //thread2 detects whether the last transaction is successful
    begin
      for(int i = 0; i< read_data.size(); i++)
      begin
        wait(rd_cmd_issued.triggered);
        @(fifo_if.rdcb);
        //if empty flag is asserted, keep looping
        while(fifo_if.rdcb.empty)
        begin
          $display("@time %4t  FIFO is Empty, Pop Command is Invalid", $time);
          $display("@time %4t  Wait for 1 RdClk Cycle", $time);
          @(fifo_if.rdcb);
        end
        -> rd_data_getone;
      end
      -> rd_data_getall;
    end

    //thread3 detects whether the last read data is acquired, if it is, display it
    for(int i = 0; i< read_data.size(); i++)
    begin
      wait(rd_data_getone.triggered);
      @(fifo_if.rdcb);
      read_data[i] = fifo_if.rdcb.rdata;   //store read data in the array
      $display("@time %4t  Data Popped Out, Data = 0x%02x", $time, read_data[i]);
    end

    join
  endtask

  virtual task run();
    $display ("@%4t  Running Transactor: Monitor", $time);
    //reset signals
    fifo_if.rdcb.pop <= 1'b 0;
    //begin transaction
    do begin
      gen2mon.get(tranx);             //get transaction information
      $display("RD_TRANX_ID %0d", tranxid++ );
//      tranx.display;
      interval = tranx.interval;
      dataintranx = tranx.datanum;
      read_data = new[dataintranx];   //allocate memory
      receive(interval, read_data);   //receive data
      foreach(read_data[i])
        mon2scb.put(read_data[i]);   //send data to scoreboard
      $display("@time %4t  Read Transaction: Popped %0d Data Out", $time, dataintranx);
    end while(tranx.remain > tranx.datanum);
  endtask

endclass
