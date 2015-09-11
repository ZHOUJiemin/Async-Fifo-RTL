//created by jiemin on 20150910
//asynchronous fifo -- test program class Driver
class Driver;
  //properties
  //virtual interface
  vfifo_if.wrcb fifo_if;
  //mailboxes and queue
  mailbox #(Tranx) gen2drv; //gen2drv
  data drv2scb[$];

  //transaction
  Tranx tranx;
  int interval;
  int dataintranx;          //data number in one transaction
  data write_data[];         //dynamic array, allocate memory for it before using it

  //other variables
  int remain;

  function new(vfifo_if.drv_mp fifo_if,
               mailbox #(Tranx) gen2drv,
               data drv2scb[$]);
    this.fifo_if = fifo_if;
    this.gen2drv = gen2drv;
    this.drv2scb = drv2scb;
  endfunction

  virtual task send(input int interval, input data write_data[]);
    repeat(interval)  //wait for several cycles before transfer
      @(fifo_if.wrcb);
    foreach(write_data[i])
    begin
      @(fifo_if.wrcb)
        if(fifo_if.wrcb.full)
          $display("@time %4t  FIFO is Full, Failed to Issue a Push Command", $time);
        else
        begin
          fifo_if.wrcb.push <= 1'b 1;
          fifo_if.wrcb.wdata <= write_data[i];
          $display("@time %4t Data = 0x%2x Has Been Pushed Into The FIFO", $time, write_data[i]);
        end
    end
  endtask

  virtual task run();
    do begin
    gen2drv.get(tranx);             //get the transaction from the mailbox
    interval = tranx.interval;      //get interval
    dataintranx = tranx.datanum;    //get number of data
    write_data = new [dataintranx];  //allocate memory
    foreach(write_data[i])           //randomize data
    begin
      write_data[i] = urandom_range(0,255);
      drv2scb.push(write_data[i]);   //send the data to scoreboard
    end
    send(interval, write_data);
    $display("@time %4t,  Write Transaction: Push %0d Data In, Interval %d", $time, dataintranx, Interval);
    end while(tranx.remain > tranx.datanum); //if there are still data to send
  endtask

endclass
