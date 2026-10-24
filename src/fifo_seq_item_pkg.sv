package fifo_seq_item_pkg;
  import uvm_pkg::*;
  import shared_pkg::*;
  `include "uvm_macros.svh"

  class fifo_seq_item extends uvm_sequence_item;
    `uvm_object_utils(fifo_seq_item)

    // Inputs
    rand logic [FIFO_WIDTH-1:0] data_in;
    rand logic rst_n;
    rand logic wr_en;
    rand logic rd_en;
    
    // Outputs (predicted by monitor)
    logic [FIFO_WIDTH-1:0] data_out;
    logic wr_ack;
    logic overflow;
    logic full, empty, almostfull, almostempty, underflow;

    function new(string name = "fifo_seq_item");
      super.new(name);
    endfunction : new

    // CONVERT TO STRING FUNCTIONS
    function string convert2string();
      return $sformatf("%s rst_n = 0b%b, wr_en = 0b%b, rd_en = 0b%b, data_in = 0x%0h | data_out = 0x%0h, wr_ack = 0b%b, overflow = 0b%b, underflow = 0b%b, full = 0b%b, empty = 0b%b, almostfull = 0b%b, almostempty = 0b%b",
                       super.convert2string(), rst_n, wr_en, rd_en, data_in, data_out, wr_ack, overflow, underflow, full, empty, almostfull, almostempty);
    endfunction : convert2string

    function string convert2string_stimulus();
      return $sformatf("%s rst_n = 0b%b, wr_en = 0b%b, rd_en = 0b%b, data_in = 0x%0h",
                       super.convert2string(), rst_n, wr_en, rd_en, data_in);
    endfunction : convert2string_stimulus

    // ------------------------------------------------------------------------
    // CONSTRAINTS
    // ------------------------------------------------------------------------
    // Constraint 1: Reset to be asserted with low probability
    constraint c_rst {
      rst_n dist { ACTIVE_RESET := RESET_ON_DIST, INACTIVE_RESET := (100 - RESET_ON_DIST) };
    }
  
    // Constraint 2: Write Enable distribution bias
    constraint c_wr_en {
      wr_en dist { ACTIVE := WR_EN_ON_DIST, INACTIVE := (100 - WR_EN_ON_DIST) };
    }
  
    // Constraint 3: Read Enable distribution bias
    constraint c_rd_en {
      rd_en dist { ACTIVE := RD_EN_ON_DIST, INACTIVE := (100 - RD_EN_ON_DIST) };
    }

    // Constraint 4: Corner Values distribution for data_in
    constraint c_data_in_corners {
      data_in dist { MAX := 10, ZERO := 10, [ZERO:MAX] := 80 };
    }

  endclass : fifo_seq_item

endpackage : fifo_seq_item_pkg