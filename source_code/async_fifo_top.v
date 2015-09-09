//created by jiemin on 20150908
//asynchronous fifo -- top module
`include "controller_wr.v"
`include "controller_rd.v"

module async_fifo_top#(parameter DEPTH = 16,
                       parameter PTRWIDTH = 4,
                       parameter DWIDTH = 8)
                      (input wclk,
                       input push,
                       input [DWIDTH-1:0] wdata,
                       output full,
                       input rclk,
                       input pop,
                       output reg [DWIDTH-1:0] rdata,
                       output empty,
                       input reset_L);

//variables, signals declaration
wire [PTRWIDTH:0] wrptr_gray; //pointers have one more bit
wire [PTRWIDTH:0] rdptr_gray;
wire [PTRWIDTH:0] wrptr_bin;
wire [PTRWIDTH:0] rdptr_bin;

//continuous assignment
assign wrptr_gray = bin2gray_wr(wrptr_bin);
assign rdptr_gray = bin2gray_rd(rdptr_bin);

//memory declaration(instantiation)
reg [DWIDTH-1:0] mem [0:DEPTH-1];

//instantiation
controller_wr #(PTRWIDTH) ctrl_wr(
  .wclk(wclk),
  .reset_L(reset_L),
  .push(push),
  .full(full),
  .wrptr_bin(wrptr_bin),  //modified on 0909 wrptr_gray->wrptr_bin
  .rdptr_gray(rdptr_gray)
  );

controller_rd #(PTRWIDTH) ctrl_rd(
  .rclk(rclk),
  .reset_L(reset_L),
  .pop(pop),
  .empty(empty),
  .rdptr_bin(rdptr_bin),  //modified on 0909 rdptr_gray->rdptr_bin
  .wrptr_gray(wrptr_gray)
  );

//functions and tasks
function [PTRWIDTH:0] bin2gray_wr(input [PTRWIDTH:0] binary);
integer i;
begin
<<<<<<< HEAD
  for(i=0; i<PTRWIDTH-1; i=i+1)
=======
  for(i=0; i<PTRWIDTH; i=i+1) //modified on 0909, sovled the "MSB is unknown" problem
  //for(i=0; i<PTRWIDTH-1; i=i+1)
>>>>>>> master
    bin2gray_wr[i] = binary[i]^binary[i+1];
  bin2gray_wr[PTRWIDTH] = binary[PTRWIDTH];
end
endfunction

function [PTRWIDTH:0] bin2gray_rd(input [PTRWIDTH:0] binary);
integer i;
begin
<<<<<<< HEAD
  for(i=0; i<PTRWIDTH-1; i=i+1)
=======
  for(i=0; i<PTRWIDTH; i=i+1) //modified on 0909, sovled the "MSB is unknown" problem
  //for(i=0; i<PTRWIDTH-1; i=i+1)
>>>>>>> master
    bin2gray_rd[i] = binary[i]^binary[i+1];
  bin2gray_rd[PTRWIDTH] = binary[PTRWIDTH];
end
endfunction

//process
  always@(*)
  begin
    if(push && !full) //ok to write
      mem[wrptr_bin] = wdata;
  end

  always@(*)
  begin
    if(pop && !empty) //ok to read
      rdata = mem[rdptr_bin];
  end

endmodule
