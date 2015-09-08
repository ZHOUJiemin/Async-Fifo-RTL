//created by jiemin on 20150908
//asynchronous fifo -- top module
`include "controller_wr.v"
`include "controller_rd.v"

module async_fifo_top#(parameter DEPTH = 16,
                       parameter PTRWIDTH = 4,
                       parameter DWIDTH = 8)
                      (input wclk,
                       input push,
                       input [WIDTH-1:0] wdata,
                       output full,
                       input rclk,
                       input pop,
                       output reg [WIDTH-1:0] rdata,
                       output empty,
                       input reset_L);

//variables, signals declaration
wire [PTRWIDTH:0] wrptr_gray; //pointers have one more bit
wire [PTRWIDTH:0] rdptr_gray;
wire [PTRWIDTH:0] wrptr_bin;
wire [PTRWIDTH:0] rdptr_bin;

//continuous assignment
assign wrptr_gray = bin2gray(wrptr_bin);
assign rdptr_gray = bin2gray(rdptr_bin);

//memory declaration(instantiation)
reg [WIDTH-1:0] mem [0:DEPTH-1];

//instantiation
controller_wr ctrl_wr #(PTRWIDTH)(
  .wclk(wclk),
  .reset_L(reset_L),
  .push(push),
  .full(full),
  .wrptr_bin(wrptr_gray),
  .rdptr_gray(rdptr_gray)
  );

controller_rd ctrl_rd #(PTRWIDTH)(
  .rclk(rclk),
  .reset_L(reset_L),
  .pop(pop),
  .empty(empty),
  .rdptr_bin(rdptr_gray),
  .wrptr_gray(wrptr_gray)
  );

//functions and tasks
automatic function [PTRWIDTH:0] bin2gray(input [PTRWIDTH:0] binary);
  int i;
  for(i=0; i<PTRWIDTH-1; i++)
    bin2gray[i] = binary[i]^binary[i+1];
  bin2gray[PTRWIDTH] = binary[PTRWIDTH];
endfunction

//process
  always(*)
  begin
    if(push && !full) //ok to write
      mem[wrptr_bin] = wdata;
  end

  always(*)
  begin
    if(pop && !empty) //ok to read
      rdata = mem[rdptr_bin];
  end

endmodule
