package fifo_scoreboard_pkg;
  import uvm_pkg::*;
  import shared_pkg::*;
  import fifo_seq_item_pkg::*;
  `include "uvm_macros.svh"

  class fifo_scoreboard extends uvm_scoreboard;
    `uvm_component_utils(fifo_scoreboard)

    // TLM Ports
    uvm_analysis_export #(fifo_seq_item) sb_export;
    uvm_tlm_analysis_fifo #(fifo_seq_item) sb_fifo;
    fifo_seq_item seq_item_sb;

    // Reference model signals & structures
    logic [FIFO_WIDTH-1:0] data_out_ref = 0;
    logic wr_ack_ref = 0;
    logic overflow_ref = 0;
    logic full_ref = 0, empty_ref = 1, almostfull_ref = 0, almostempty_ref = 0, underflow_ref = 0;
    
    logic [FIFO_WIDTH-1:0] queue[$];
    logic [MAX_FIFO_ADDR:0] counter = 0;
    logic rd_done = 0;   // 1 when the reference model performed a successful read in this transaction

    function new(string name = "fifo_scoreboard", uvm_component parent = null);
      super.new(name, parent);
    endfunction : new

    function void build_phase(uvm_phase phase);
      super.build_phase(phase);
      sb_export = new("sb_export", this);
      sb_fifo   = new("sb_fifo", this);
    endfunction : build_phase

    function void connect_phase(uvm_phase phase);
      super.connect_phase(phase);
      sb_export.connect(sb_fifo.analysis_export);
    endfunction : connect_phase

    task run_phase(uvm_phase phase);
      super.run_phase(phase);
      forever begin
        sb_fifo.get(seq_item_sb);
        reference_model(seq_item_sb);

        // 1. Compare Data Output on EVERY successful read (also when wr_en=1 in the same cycle,
        //    and also for the read that empties the FIFO). rd_done is set inside the reference model.
        if (rd_done) begin
          if (seq_item_sb.data_out !== data_out_ref) begin
            `uvm_error("run_phase", $sformatf("Compare dataout failed! DUT data_out=%0h, REF data_out=%0h\nTransaction details: %s", 
                       seq_item_sb.data_out, data_out_ref, seq_item_sb.convert2string()));
            error_count++;
          end
          else begin
            `uvm_info("run_phase", $sformatf("Compare dataout correct: DUT data_out=%0h, REF data_out=%0h", 
                      seq_item_sb.data_out, data_out_ref), UVM_HIGH);
            correct_count++;
          end
        end

        // 2. Compare Status Flags on EVERY transaction
        if ({seq_item_sb.wr_ack, seq_item_sb.overflow, seq_item_sb.underflow, seq_item_sb.full, seq_item_sb.empty, seq_item_sb.almostfull, seq_item_sb.almostempty} !==
            {wr_ack_ref, overflow_ref, underflow_ref, full_ref, empty_ref, almostfull_ref, almostempty_ref}) begin
          `uvm_error("run_phase", $sformatf("Compare flags failed!\nDUT flags={wr_ack,overflow,underflow,full,empty,almostfull,almostempty}=7'b%7b\nREF flags={wr_ack,overflow,underflow,full,empty,almostfull,almostempty}=7'b%7b",
                     {seq_item_sb.wr_ack, seq_item_sb.overflow, seq_item_sb.underflow, seq_item_sb.full, seq_item_sb.empty, seq_item_sb.almostfull, seq_item_sb.almostempty},
                     {wr_ack_ref, overflow_ref, underflow_ref, full_ref, empty_ref, almostfull_ref, almostempty_ref}));
          error_count++;
        end
        else begin
          `uvm_info("run_phase", $sformatf("Compare flags correct: 7'b%7b", 
                    {wr_ack_ref, overflow_ref, underflow_ref, full_ref, empty_ref, almostfull_ref, almostempty_ref}), UVM_HIGH);
          correct_count++;
        end        
      end
    endtask : run_phase

    // Queue-based Reference Model
    function void reference_model(fifo_seq_item F_ref_txn);
      rd_done = 0;
      if (!F_ref_txn.rst_n) begin
        wr_ack_ref    = 0;
        overflow_ref  = 0;
        data_out_ref  = 0;
        underflow_ref = 0;
        queue.delete();
      end 
      else begin
        // Write Check
        if (F_ref_txn.wr_en && (counter < FIFO_DEPTH)) begin
          queue.push_back(F_ref_txn.data_in);
          wr_ack_ref   = 1;
          overflow_ref = 0;
        end 
        else begin
          wr_ack_ref = 0;
          if (F_ref_txn.wr_en && full_ref) begin
            overflow_ref = 1;
          end
          else begin
            overflow_ref = 0;
          end
        end

        // Read Check
        if (F_ref_txn.rd_en && (counter != 0)) begin
          data_out_ref  = queue.pop_front();
          rd_done       = 1;
          underflow_ref = 0;
        end 
        else begin
          if (F_ref_txn.rd_en && empty_ref) begin
            underflow_ref = 1;
          end
          else begin
            underflow_ref = 0;
          end
        end
      end

      // Counter Tracking
      if (!F_ref_txn.rst_n) begin
        counter = 0;
      end 
      else begin
        case ({F_ref_txn.wr_en, F_ref_txn.rd_en})
          2'b10: if (!full_ref)  counter = counter + 1;
          2'b01: if (!empty_ref) counter = counter - 1;
          2'b11: begin
            if (full_ref && !empty_ref)       counter = counter - 1; // writing when full, read takes priority
            else if (empty_ref && !full_ref)  counter = counter + 1;
          end
        endcase
      end

      // Update Ref Status Flags
      full_ref        = (counter == FIFO_DEPTH)     ? 1 : 0;
      empty_ref       = (counter == 0)              ? 1 : 0;
      almostfull_ref  = (counter == FIFO_DEPTH - 1) ? 1 : 0;
      almostempty_ref = (counter == 1)              ? 1 : 0;
    endfunction : reference_model

    function void report_phase(uvm_phase phase);
      super.report_phase(phase);
      `uvm_info("report_phase", $sformatf("Total successful transactions: %0d", correct_count), UVM_LOW)
      `uvm_info("report_phase", $sformatf("Total failed transactions: %0d", error_count), UVM_LOW)
    endfunction : report_phase

  endclass : fifo_scoreboard
endpackage : fifo_scoreboard_pkg