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
  int rd_success;

  //methods
  function new(vfifo_if_rd fifo_if,
               mailbox #(Tranx) gen2mon,
               mailbox #(data_t) mon2scb);  //fixed a bug on 0917
    this.fifo_if = fifo_if;
    this.gen2mon = gen2mon;
    this.mon2scb = mon2scb;
    rd_success = 0;
  endfunction

  virtual task receive(input int interval, ref data_t read_data[]);
    repeat(interval)
      @(fifo_if.rdcb) $display("@time %4t  Read Idle Cycle", $time);
    for(int i =0; i< read_data.size(); i++)
    begin
      @(fifo_if.rdcb)
      begin
        //if last transaction is successful, display it
        if(rd_success)
        begin
          read_data[i-1] = fifo_if.rdcb.rdata;   //store read data in the array
          rd_success = 0;
          $display("@time %4t  Data Popped Out, Data = 0x%02x", $time, read_data[i-1]);
        end
        //do this transaction
        //if empty flag is asserted
        while(fifo_if.rdcb.empty)
        begin
          //fifo_if.rdcb.pop <= 1'b 0;
          rd_success = 0;
          $display("@time %4t  FIFO is Empty, Failed to Issue a Pop Command", $time);
          $display("@time %4t  Wait for 1 RdClk Cycle", $time);
          @(fifo_if.rdcb);
        end
        fifo_if.rdcb.pop <= 1'b 1;
        rd_success = 1;
        $display("@time %4t  Issued a Pop Command", $time);
      end
    end
  endtask

  virtual task run();
    $display ("@%4t  Running Transactor: Monitor", $time);
    do begin
      gen2mon.get(tranx);             //get transaction information
      $display("RD_TRANX_ID %0d", tranxid++ );
      tranx.display;
      interval = tranx.interval;
      dataintranx = tranx.datanum;
      read_data = new[dataintranx];   //allocate memory
      receive(interval, read_data);   //receive data
      foreach(read_data[i])
        mon2scb.put(read_data[i]);   //send data to scoreboard
    end while(tranx.remain >= tranx.datanum);
  endtask

endclass
