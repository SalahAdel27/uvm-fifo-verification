import uvm_pkg::*;
`include "uvm_macros.svh"
import shared_pkg::*;

module fifo_assertions(
  input logic                     clk,
  input logic                     rst_n,
  input logic                     wr_en,
  input logic                     rd_en,
  input logic                     full,
  input logic                     empty,
  input logic                     almostfull,
  input logic                     almostempty,
  input logic                     wr_ack,
  input logic                     overflow,
  input logic                     underflow,
  input logic [MAX_FIFO_ADDR:0]   count,
  input logic [MAX_FIFO_ADDR-1:0] wr_ptr,
  input logic [MAX_FIFO_ADDR-1:0] rd_ptr
);

  // A deferred assertion's action block must be ONE subroutine call, so the uvm_error macro
  function void flag_err(string msg);
    `uvm_error("FIFO_ASS", msg)
  endfunction

  
  always_comb begin
    if (rst_n) begin
      a_full:   assert final (full        == (count == FIFO_DEPTH))     else flag_err("a_full: full != (count == FIFO_DEPTH)");
      a_empty:  assert final (empty       == (count == 0))              else flag_err("a_empty: empty != (count == 0)");
      a_afull:  assert final (almostfull  == (count == FIFO_DEPTH-1))   else flag_err("a_afull: almostfull != (count == FIFO_DEPTH-1)");
      a_aempty: assert final (almostempty == (count == 1))              else flag_err("a_aempty: almostempty != (count == 1)");
    end
  end

  c_full:   cover property (@(posedge clk) disable iff (!rst_n) (full        && count == FIFO_DEPTH));
  c_empty:  cover property (@(posedge clk) disable iff (!rst_n) (empty       && count == 0));
  c_afull:  cover property (@(posedge clk) disable iff (!rst_n) (almostfull  && count == FIFO_DEPTH-1));
  c_aempty: cover property (@(posedge clk) disable iff (!rst_n) (almostempty && count == 1));

  //////////////////////////////////////// clocked assertions /////////////////////////////////////////

  // Assertion 1: reset clears pointers, counter, acknowledge and error flags
  property reset_clear_p;
    @(posedge clk) (!rst_n) |-> (wr_ptr == 0 && rd_ptr == 0 && count == 0 && empty && !full &&
                                 !wr_ack && !overflow && !underflow);
  endproperty
  a_reset_clear: assert property (reset_clear_p) else flag_err("Assertion failed: reset_clear");
  c_reset_clear: cover  property (reset_clear_p);

  // Assertion 2: a successful write is acknowledged
  property wr_ack_p;
    @(posedge clk) disable iff (!rst_n)
      ((wr_en && !full) |=> wr_ack);
  endproperty
  a_wr_ack: assert property (wr_ack_p) else flag_err("Assertion failed: wr_ack after a successful write");
  c_wr_ack: cover  property (wr_ack_p);

  // Assertion 3: when FIFO is full, wr_ack should be 0
  property full_no_ack_p;
    @(posedge clk) disable iff (!rst_n)
      (full |=> !wr_ack);
  endproperty
  a_full_no_ack: assert property (full_no_ack_p) else flag_err("Assertion failed: full_no_ack");
  c_full_no_ack: cover  property (full_no_ack_p);

  // Assertion 4: read on an empty FIFO raises underflow
  property empty_underflow_p;
    @(posedge clk) disable iff (!rst_n)
      ((empty && rd_en) |=> underflow);
  endproperty
  a_empty_underflow: assert property (empty_underflow_p) else flag_err("Assertion failed: empty_underflow");
  c_empty_underflow: cover  property (empty_underflow_p);

  // Assertion 5: write on a full FIFO raises overflow
  property overflow_condition_p;
    @(posedge clk) disable iff (!rst_n)
      ((full && wr_en) |=> overflow);
  endproperty
  a_overflow_condition: assert property (overflow_condition_p) else flag_err("Assertion failed: overflow_condition");
  c_overflow_condition: cover  property (overflow_condition_p);

  // Assertion 6: write pointer wraps around to 0 after the last location
  property wr_ptr_wrap_p;
    @(posedge clk) disable iff (!rst_n)
      ((wr_en && !full && wr_ptr == FIFO_DEPTH-1) |=> (wr_ptr == 0));
  endproperty
  a_wr_ptr_wrap: assert property (wr_ptr_wrap_p) else flag_err("Assertion failed: wr_ptr wrap-around");
  c_wr_ptr_wrap: cover  property (wr_ptr_wrap_p);

  // Assertion 7: read pointer wraps around to 0 after the last location
  property rd_ptr_wrap_p;
    @(posedge clk) disable iff (!rst_n)
      ((rd_en && !empty && rd_ptr == FIFO_DEPTH-1) |=> (rd_ptr == 0));
  endproperty
  a_rd_ptr_wrap: assert property (rd_ptr_wrap_p) else flag_err("Assertion failed: rd_ptr wrap-around");
  c_rd_ptr_wrap: cover  property (rd_ptr_wrap_p);

  // Assertion 8: thresholds - counter and pointers never leave their legal range
  property count_range_p;
    @(posedge clk) disable iff (!rst_n) (count <= FIFO_DEPTH);
  endproperty
  a_count_range: assert property (count_range_p) else flag_err("Assertion failed: count > FIFO_DEPTH");
  c_count_range: cover  property (count_range_p);

  property wr_ptr_range_p;
    @(posedge clk) disable iff (!rst_n) (wr_ptr < FIFO_DEPTH);
  endproperty
  a_wr_ptr_range: assert property (wr_ptr_range_p) else flag_err("Assertion failed: wr_ptr out of range");
  c_wr_ptr_range: cover  property (wr_ptr_range_p);

  property rd_ptr_range_p;
    @(posedge clk) disable iff (!rst_n) (rd_ptr < FIFO_DEPTH);
  endproperty
  a_rd_ptr_range: assert property (rd_ptr_range_p) else flag_err("Assertion failed: rd_ptr out of range");
  c_rd_ptr_range: cover  property (rd_ptr_range_p);

endmodule : fifo_assertions

