//created by jiemin on 20150910
//asynchronous fifo -- test program class Scoreboard
class Scoreboard;
//properties
//Config
Config cfg;

//mailboxes and queues
mailbox #(data) mon2scb;
data drv2scb[$];

//other variables
data read_data;
data write_data;
int total;

//methods
function new(data drv2scb[$], mailbox #(data) mon2scb, Config cfg);
  this.drv2scb = drv2scb;
  this.mon2scb = mon2scb;
  this.cfg = cfg;
  total = 0;
endfunction

virtual task run();
  while (total < cfg.totaldatanum)
  begin
    mon2scb.get(read_data);         //wait until there is a read_data
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
