//created by jiemin on 20150910
//asynchronous fifo -- test program class Tranx
class Tranx;
  //properties
  rand int datanum;
  rand int interval;

  int wr_rd; //0 for write and 1 for read
  int remain; //remaining data

  contraint data_num_in_one_trasaction{   //number of data is limited
    datanum > 0;
    datanum <= remain;
  }

  constraint transaction_interval{
    interval > 0;
    interval < 10;
  }

  //methods
  function new(int remain, int wr_rd);
    this.remain = remain;
    this.wr_rd = wr_rd;
  endfunction

endclass
