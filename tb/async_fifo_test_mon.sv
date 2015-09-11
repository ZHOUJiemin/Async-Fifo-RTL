//created by jiemin on 20150911
//asynchronous fifo -- test program class Monitor
class Monitor;
  //properties
  //interface
  vfifo_if.rdcb fifo_if;

  //mailboxes and queues
  mailbox #(Tranx) gen2mon;
  mailbox #(data) mon2scb;

  //transactions
  Tranx tranx;
  int interval;
  int dataintranx;
  data read_data[];

  //other variables
  int remain;

  //methods
  function new(vfifo_if.rdcb fifo_if,
               mailbox #(Tranx) gen2mon,
               mailbox #(Tranx) mon2scb);
    this.fifo_if = fifo_if;
    this.gen2mon = gen2mon;
    this.mon2scb = mon2scb;
  endfunction

  virtual task receive(input int interval, output data read_data[]);
    repeat(interval)
      @(fifo_if.rdcb)
    foreach(read_data[i])
    begin
      @(fifo.rdcb)
      
    end
  endtask

  virtual task run();
    do begin
      gen2mon.get(tranx);             //get transaction information
      interval = tranx.interval;
      dataintranx = tranx.datanum;
      read_data = new[dataintranx];   //allocate memory
      receive(interval, read_data);   //receive data
      foreach(read_data[i])
        mon2scb.push(read_data[i]);   //send data to scoreboard
    end while(tranx.remain > tranx.datanum);
  endtask

endclass
