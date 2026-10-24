interface FIFO_if (input bit clk);
parameter FIFO_WIDTH = 16;
parameter FIFO_DEPTH = 8;

logic [FIFO_WIDTH-1:0] data_in;
logic rst_n;
logic wr_en;
logic rd_en;

logic [FIFO_WIDTH-1:0] data_out;
logic wr_ack;
logic overflow;
logic full, empty, almostfull, almostempty, underflow;
 
modport DUT (
input clk, rst_n, data_in, wr_en, rd_en,
output data_out, wr_ack, overflow, full, empty, almostfull, almostempty, underflow
);

modport TB (
input clk, data_out, wr_ack, overflow, full, empty, almostfull, almostempty, underflow,
output  rst_n, data_in, wr_en, rd_en    
);

modport monitor(
input  data_out, wr_ack, overflow, full, empty, almostfull, almostempty, underflow, clk, rst_n, data_in, wr_en, rd_en
);

  // For assertions
modport assertions (
input data_out, wr_ack, overflow, full, empty, almostfull, almostempty, underflow,
           clk, rst_n, data_in, wr_en, rd_en
  );
endinterface