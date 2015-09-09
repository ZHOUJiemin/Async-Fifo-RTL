//created by jiemin on 20150908
//asynchronous fifo -- controller_rd
module controller_rd#(parameter PTRWIDTH = 4)
                     (input rclk,
                      input reset_L,
                      input pop,
                      output reg empty,
                      output reg [PTRWIDTH:0] rdptr_bin,
                      input [PTRWIDTH:0] wrptr_gray);

//variables declaration
wire [PTRWIDTH:0] wrptr_bin;
reg [PTRWIDTH:0] wrptr_gray_ff1;
reg [PTRWIDTH:0] wrptr_gray_ff2;

//continuous assignment
//signal: wrptr_bin
assign wrptr_bin = gray2bin(wrptr_gray_ff2);

//signal: rdptr_bin
always@(posedge rclk or negedge reset_L)
  if(reset_L == 0)  //if reset is asserted
  begin
    //initialization
    rdptr_bin <= 0;
  end
  else  //if reset is de-asserted
  begin
    if(pop && !empty) //ok to read
      rdptr_bin <= rdptr_bin + 1; //use binary addition, ignore the carry bit if overflows
    else //no read command or can not be written
      rdptr_bin <= rdptr_bin;
  end

//signal: wrptr_gray_ff1, wrptr_gray_ff2(double latch)
always@(posedge rclk or negedge reset_L)
  if(reset_L == 0)  //if reset is asserted
  begin
    //initialization
    wrptr_gray_ff1 <= 0;
    wrptr_gray_ff2 <= 0;
  end
  else  //if reset is de-asserted
  begin
    wrptr_gray_ff1 <= wrptr_gray;
    wrptr_gray_ff2 <= wrptr_gray_ff1;
  end

//signal:empty
always@(*)
  if(reset_L == 0)  //if reset is asserted
    empty = 1'b 1;  //modified by jiemin on 0909, reset value for empty is 1
  else
  begin
    if(wrptr_bin == rdptr_bin)
      empty = 1'b 1;
    else
      empty = 1'b 0;
  end

//functions and tasks
function [PTRWIDTH:0] gray2bin(input [PTRWIDTH:0] graycode);
integer i;
begin
  gray2bin[PTRWIDTH] = graycode[PTRWIDTH];
<<<<<<< HEAD
  for(i=PTRWIDTH-1; i>0; i=i-1)
=======
  for(i=PTRWIDTH-1; i>=0; i=i-1)  //modified on 0909, solved the "LSB is unknown" problem
  //for(i=PTRWIDTH-1; i>0; i=i-1)
>>>>>>> master
    gray2bin[i] = gray2bin[i+1] ^ graycode[i];
end
endfunction

endmodule
