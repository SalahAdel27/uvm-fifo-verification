module fifo_top;
  import uvm_pkg::*;
  import shared_pkg::*;
  import fifo_test_pkg::*;
  `include "uvm_macros.svh"

  // Clock Generation
  bit clk;

  initial begin
    clk = 0;
    forever #5 clk = ~clk;
  end

  // Interface Instantiation
  FIFO_if fifo_vif (clk);

  // DUT Instantiation
  FIFO DUT (
    .clk(fifo_vif.clk),
    .rst_n(fifo_vif.rst_n),
    .wr_en(fifo_vif.wr_en),
    .rd_en(fifo_vif.rd_en),  // Corrected typo from rd_vif to rd_en
    .data_in(fifo_vif.data_in),
    .data_out(fifo_vif.data_out),
    .wr_ack(fifo_vif.wr_ack),
    .overflow(fifo_vif.overflow),
    .full(fifo_vif.full),
    .empty(fifo_vif.empty),
    .almostfull(fifo_vif.almostfull),
    .almostempty(fifo_vif.almostempty),
    .underflow(fifo_vif.underflow)
  );

  // Bind Assertions Module to DUT
  bind FIFO fifo_assertions fifo_assertions_inst (
  .clk(clk), 
  .rst_n(rst_n), 
  .wr_en(wr_en), 
  .rd_en(rd_en),
  .full(full), 
  .empty(empty), 
  .almostfull(almostfull), 
  .almostempty(almostempty),
  .wr_ack(wr_ack), 
  .overflow(overflow), 
  .underflow(underflow),
  .count(count), 
  .wr_ptr(wr_ptr), 
  .rd_ptr(rd_ptr)
);

  // Testbench Setup & Test Execution
  initial begin
    uvm_config_db #(virtual FIFO_if)::set(null, "*", "FIFO_IF", fifo_vif);
    run_test("fifo_test");
  end

endmodule : fifo_top