//created by jiemin on 20150910
//asynchronous fifo -- test program class Tranx
class Tranx;
  //properties
  rand int datanum;
  rand int interval;

  int remain; //remaining data

  constraint data_num_in_one_trasaction{   //number of data is limited
    datanum > 0;
    datanum <= remain;
  }

  constraint transaction_interval{
    interval > 0;
    interval < 10;
  }

  //methods
  function new(int remain);
    this.remain = remain;
  endfunction

  function void display();
    $display("@time %4t  After %0d cycles, Will Transfer %0d Data",$time, interval, datanum);
  endfunction
endclass
