package fifo_coverage_pkg;
  import uvm_pkg::*;
  import shared_pkg::*;
  import fifo_seq_item_pkg::*;
  `include "uvm_macros.svh"

  class fifo_coverage extends uvm_component;
    `uvm_component_utils(fifo_coverage)

    uvm_analysis_export #(fifo_seq_item) cov_export;
    uvm_tlm_analysis_fifo #(fifo_seq_item) cov_fifo;
    fifo_seq_item seq_item_cov;

    covergroup fifo_cg;
      option.per_instance = 1;

      wr_en_covp: coverpoint seq_item_cov.wr_en {
        bins wr_en_on  = {1};
        bins wr_en_off = {0};
      }

      rd_en_covp: coverpoint seq_item_cov.rd_en {
        bins rd_en_on  = {1};
        bins rd_en_off = {0};
      }

      wr_ack_covp: coverpoint seq_item_cov.wr_ack {
        bins wr_ack_on  = {1};
        bins wr_ack_off = {0};
      }

      overflow_covp: coverpoint seq_item_cov.overflow {
        bins overflow_on  = {1};
        bins overflow_off = {0};
      }

      full_covp: coverpoint seq_item_cov.full {
        bins full_on  = {1};
        bins full_off = {0};
      }

      empty_covp: coverpoint seq_item_cov.empty {
        bins empty_on  = {1};
        bins empty_off = {0};
      }

      almostfull_covp: coverpoint seq_item_cov.almostfull {
        bins almostfull_on  = {1};
        bins almostfull_off = {0};
      }

      almostempty_covp: coverpoint seq_item_cov.almostempty {
        bins almostempty_on  = {1};
        bins almostempty_off = {0};
      }

      underflow_covp: coverpoint seq_item_cov.underflow {
        bins underflow_on  = {1};
        bins underflow_off = {0};
      }

      // Cross Coverage Definitions
      wr_rd_ack_covp: cross wr_en_covp, rd_en_covp, wr_ack_covp {
        ignore_bins wr_en_ack_on = binsof(wr_en_covp) intersect {0} && binsof(wr_ack_covp) intersect {1};
      }

      wr_rd_overflow_covp: cross wr_en_covp, rd_en_covp, overflow_covp {
        ignore_bins wr_en_overflow_on = binsof(wr_en_covp) intersect {0} && binsof(overflow_covp) intersect {1};
      }

      wr_rd_full_covp: cross wr_en_covp, rd_en_covp, full_covp {
        ignore_bins wr_en_overflow_on = binsof(rd_en_covp) intersect {1} && binsof(full_covp) intersect {1};
      }

     wr_rd_empty_covp: cross wr_en_covp, rd_en_covp, empty_covp {
    ignore_bins wr_rd_empty_on = binsof(wr_en_covp) intersect {1} && 
                                 binsof(rd_en_covp) intersect {1} && 
                                 binsof(empty_covp) intersect {1};
      }

      wr_rd_almostfull_covp: cross wr_en_covp, rd_en_covp, almostfull_covp;

      wr_rd_almostempty_covp: cross wr_en_covp, rd_en_covp, almostempty_covp;

      wr_rd_underflow_covp: cross wr_en_covp, rd_en_covp, underflow_covp {
        ignore_bins wr_en_overflow_on = binsof(rd_en_covp) intersect {0} && binsof(underflow_covp) intersect {1};
      }
    endgroup

    function new(string name = "fifo_coverage", uvm_component parent = null);
      super.new(name, parent);
      fifo_cg = new();
    endfunction : new

    function void build_phase(uvm_phase phase);
      super.build_phase(phase);
      cov_export = new("cov_export", this);
      cov_fifo   = new("cov_fifo", this);
    endfunction : build_phase

    function void connect_phase(uvm_phase phase);
      super.connect_phase(phase);
      cov_export.connect(cov_fifo.analysis_export);
    endfunction : connect_phase

    task run_phase(uvm_phase phase);
      super.run_phase(phase);
      forever begin
        cov_fifo.get(seq_item_cov);
        fifo_cg.sample();
      end
    endtask : run_phase

  endclass : fifo_coverage
endpackage : fifo_coverage_pkg