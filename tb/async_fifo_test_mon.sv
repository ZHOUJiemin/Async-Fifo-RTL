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
    int rd_success;
    rd_success = 0;
    repeat(interval)
      @(fifo_if.rdcb);
      //  $display("@time %4t  Read Idle Cycle", $time);
    for(int i =0; i<= read_data.size(); i++)  //not good!
    begin
      @(fifo_if.rdcb)
      begin
        //if last transaction is successful, display it
        //quite tedious, not good! not good!
        if(rd_success)
        begin
          rd_success = 0;
          read_data[i-1] = fifo_if.rdcb.rdata;   //store read data in the array
          $display("@time %4t  Data Popped Out, Data = 0x%02x", $time, read_data[i-1]);
        end
        //do this transaction
        //if empty flag is asserted
        if(i < read_data.size()) //not good!
        begin:current_transaction
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
        end:current_transaction
      end
    end
    //stop transaction
    fifo_if.rdcb.pop <= 1'b 0;
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
