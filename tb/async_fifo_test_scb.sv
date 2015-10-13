//created by jiemin on 20150910
//asynchronous fifo -- test program class Scoreboard
class Scoreboard;
//properties
//Config
Config cfg;

//mailboxes and queues
mailbox #(data_t) mon2scb;
data_t drv2scb[$];

//other variables
data_t read_data;
data_t write_data;
int total;

//methods
function new(ref data_t drv2scb[$], input mailbox #(data_t) mon2scb, Config cfg);
  this.drv2scb = drv2scb;
  this.mon2scb = mon2scb;
  this.cfg = cfg;
  total = 0;
endfunction

virtual task run();
  $display ("@%4t  Running Transactor: Scoreboard", $time);
  while (total < cfg.totaldatanum)
  begin
    mon2scb.get(read_data);         //wait until there is a read_data
    while(!drv2scb.size())
      wait(100ns);
    write_data = drv2scb.pop_front();  //get the write data
    if(read_data == write_data)
    begin
      $display("Correct! Write Data = 0x%02x, Read Data = 0x%02x", write_data, read_data);
      cfg.good_count++;
    end
    else
    begin
      $display("Error! Write Data = 0x%02x, Read Data = 0x%02x", write_data, read_data);
      cfg.bad_count++;
    end
    total++;
  end
endtask

endclass
