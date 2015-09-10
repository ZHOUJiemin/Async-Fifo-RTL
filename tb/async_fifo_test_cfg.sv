//created by jiemin on 20150910
//asynchronous fifo -- test program class Config
class Config;

  //properties
  rand int totaldatanum;

  int good_count;
  int bad_count;

  contraint total_data_num{
    datatopush >= 0;
    datatopush <= 30;
  }

  //methods
  function new();
    good_count = 0; //initialize the scoreboard
    bad_count = 0;
  endfunction

  virtual function void display();
    $display("%0d data to be transferred by using the asynchronous FIFO", totaldatanum);
  endfunction

endclass
