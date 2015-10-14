//created by jiemin on 20150910
//asynchronous fifo -- test program class Scoreboard
class Scoreboard;
//properties
//Config
Config cfg;

//mailboxes and queues
mailbox #(data_t) mon2scb;
mailbox #(data_t) drv2scb;

//other variables
data_t read_data;
data_t write_data;
int total;

//methods
function new(input mailbox #(data_t) drv2scb, mailbox #(data_t) mon2scb, Config cfg);
  this.drv2scb = drv2scb;
  this.mon2scb = mon2scb;
  this.cfg = cfg;
  total = 0;
endfunction

virtual task run();
  $display ("@time %4t  Running Transactor: Scoreboard", $time);
  while (total < cfg.totaldatanum)
  begin
    mon2scb.get(read_data);         //wait until there is a read_data
    /*fork:debug
      begin
        while(!drv2scb.size())
        begin
          $display("@time %4t  size = %0d", $time, drv2scb.size());
          # 30ns;
        end
      end
      begin
        # 1us
        $display("@time %4t  No write data", $time);
      end
    join_any:debug
    disable debug;*/
    drv2scb.get(write_data);  //get the write data
    if(read_data == write_data)
    begin
      $display("@time %4t  Correct! Write Data = 0x%02x, Read Data = 0x%02x", $time, write_data, read_data);
      cfg.good_count++;
    end
    else
    begin
      $display("@time %4t  Error! Write Data = 0x%02x, Read Data = 0x%02x", $time, write_data, read_data);
      cfg.bad_count++;
    end
    total++;
  end
endtask

endclass
