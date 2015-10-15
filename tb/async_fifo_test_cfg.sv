//created by jiemin on 20150910
//asynchronous fifo -- test program class Config
class Config;

  //properties
  rand int totaldatanum;

  int good_count;
  int bad_count;

  constraint total_data_num{
    totaldatanum >= 0;
    totaldatanum <= 30;
//    totaldatanum == 1;  //first test, debug
  }

  //methods
  function new();
    good_count = 0; //initialize the scoreboard
    bad_count = 0;
  endfunction

  virtual function void display();
    $display("@time %4t  %0d data to be transferred by using the asynchronous FIFO",$time, totaldatanum);
  endfunction

endclass
