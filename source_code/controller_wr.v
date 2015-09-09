//created by jiemin on 20150908
//asynchronous fifo -- controller_wr
module controller_wr#(parameter PTRWIDTH = 4)
                     (input wclk,
                      input reset_L,
                      input push,
                      output reg full,
                      output reg [PTRWIDTH:0] wrptr_bin,
                      input [PTRWIDTH:0] rdptr_gray);

//variables declaration
wire [PTRWIDTH:0] rdptr_bin;
reg [PTRWIDTH:0] rdptr_gray_ff1;
reg [PTRWIDTH:0] rdptr_gray_ff2;

//continuous assignment
//signal: rdptr_bin
assign rdptr_bin = gray2bin(rdptr_gray_ff2);

//signal: wrptr_bin
always@(posedge wclk or negedge reset_L)
  if(reset_L == 0)  //if reset is asserted
  begin
    //initialization
    wrptr_bin <= 0;
  end
  else  //if reset is de-asserted
  begin
    if(push && !full) //ok to write
      wrptr_bin <= wrptr_bin + 1; //use binary addition, ignore the carry bit if overflows
    else //no write command or can not be written
      wrptr_bin <= wrptr_bin;
  end

//signal: rdptr_gray_ff1, rdptr_gray_ff2(double latch)
always@(posedge wclk or negedge reset_L)
  if(reset_L == 0)  //if reset is asserted
  begin
    //initialization
    rdptr_gray_ff1 <= 0;
    rdptr_gray_ff2 <= 0;
  end
  else  //if reset is de-asserted
  begin
    rdptr_gray_ff1 <= rdptr_gray;
    rdptr_gray_ff2 <= rdptr_gray_ff1;
  end

//signal:full
always@(*)
  if(reset_L == 0)  //if reset is asserted
    full = 1'b 0;
  else
  begin
    //if((wrptr_bin[PTRWIDTH]^rdptr_bin[PTRWIDTH]) || (wrptr_bin[PTRWIDTH-1:0]==rdptr_bin[PTRWIDTH-1:0]))
    if((wrptr_bin[PTRWIDTH]^rdptr_bin[PTRWIDTH]) && (wrptr_bin[PTRWIDTH-1:0]==rdptr_bin[PTRWIDTH-1:0])) //modified on 0909 bug fixed
      full = 1'b 1;
    else
      full = 1'b 0;
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
