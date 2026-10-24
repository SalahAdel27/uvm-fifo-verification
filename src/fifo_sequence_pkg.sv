package fifo_sequence_pkg;
  import uvm_pkg::*;
  import shared_pkg::*;
  import fifo_seq_item_pkg::*;
  `include "uvm_macros.svh"

  // ------------------------------------------------------------------------
  // 1. Reset Sequence
  // ------------------------------------------------------------------------
  class fifo_reset_sequence extends uvm_sequence #(fifo_seq_item);
    `uvm_object_utils(fifo_reset_sequence)

    fifo_seq_item seq_item;

    function new(string name = "fifo_reset_sequence");
      super.new(name);
    endfunction : new

    task body();
      seq_item = fifo_seq_item::type_id::create("seq_item");
      start_item(seq_item);
      seq_item.rst_n   = 0;
      seq_item.wr_en   = 0;
      seq_item.rd_en   = 0;
      seq_item.data_in = 0;
      finish_item(seq_item);
    endtask : body
  endclass : fifo_reset_sequence

  // ------------------------------------------------------------------------
  // 2. Write-Only Sequence
  // ------------------------------------------------------------------------
  class fifo_write_only_sequence extends uvm_sequence #(fifo_seq_item);
    `uvm_object_utils(fifo_write_only_sequence)

    fifo_seq_item seq_item;

    function new(string name = "fifo_write_only_sequence");
      super.new(name);
    endfunction : new

    task body();
      repeat (20) begin
        seq_item = fifo_seq_item::type_id::create("seq_item");
        start_item(seq_item);
        assert(seq_item.randomize() with {
          rst_n == 1;
          wr_en == 1;
          rd_en == 0;
        });
        finish_item(seq_item);
      end
    endtask : body
  endclass : fifo_write_only_sequence

  // ------------------------------------------------------------------------
  // 3. Read-Only Sequence
  // ------------------------------------------------------------------------
  class fifo_read_only_sequence extends uvm_sequence #(fifo_seq_item);
    `uvm_object_utils(fifo_read_only_sequence)

    fifo_seq_item seq_item;

    function new(string name = "fifo_read_only_sequence");
      super.new(name);
    endfunction : new

    task body();
      repeat (20) begin
        seq_item = fifo_seq_item::type_id::create("seq_item");
        start_item(seq_item);
        assert(seq_item.randomize() with {
          rst_n == 1;
          wr_en == 0;
          rd_en == 1;
        });
        finish_item(seq_item);
      end
    endtask : body
  endclass : fifo_read_only_sequence

  // ------------------------------------------------------------------------
  // 4. Write & Read Concurrent Sequence
  // ------------------------------------------------------------------------
  class fifo_write_read_sequence extends uvm_sequence #(fifo_seq_item);
    `uvm_object_utils(fifo_write_read_sequence)

    fifo_seq_item seq_item;

    function new(string name = "fifo_write_read_sequence");
      super.new(name);
    endfunction : new

    task body();
      repeat (350) begin
        seq_item = fifo_seq_item::type_id::create("seq_item");
        start_item(seq_item);
        assert(seq_item.randomize());
        finish_item(seq_item);
      end
    endtask : body
  endclass : fifo_write_read_sequence



endpackage : fifo_sequence_pkg