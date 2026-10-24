package fifo_test_pkg;
  import uvm_pkg::*;
  import fifo_env_pkg::*;
  import fifo_config_pkg::*;
  import fifo_seq_item_pkg::*;
  import fifo_sequence_pkg::*;
  `include "uvm_macros.svh"

  class fifo_test extends uvm_test;
    `uvm_component_utils(fifo_test)

    fifo_env env;
    fifo_config fifo_cfg;

    // Corrected Sequence Class Names to match fifo_sequence_pkg
    fifo_reset_sequence      reset_seq;
    fifo_write_only_sequence Write_seq;
    fifo_read_only_sequence  Read_seq;
    fifo_write_read_sequence Write_Read_seq;

    function new(string name = "fifo_test", uvm_component parent = null);
      super.new(name, parent);
    endfunction : new

    function void build_phase(uvm_phase phase);
      super.build_phase(phase);
      env            = fifo_env::type_id::create("env", this);
      fifo_cfg       = fifo_config::type_id::create("fifo_cfg");
      reset_seq      = fifo_reset_sequence::type_id::create("reset_seq");
      Write_seq      = fifo_write_only_sequence::type_id::create("Write_seq");
      Read_seq       = fifo_read_only_sequence::type_id::create("Read_seq");
      Write_Read_seq = fifo_write_read_sequence::type_id::create("Write_Read_seq");

      if (!uvm_config_db #(virtual FIFO_if)::get(this, "", "FIFO_IF", fifo_cfg.fifo_vif))
        `uvm_fatal("build_phase", "Test: Unable to get virtual interface from uvm_config_db")

      uvm_config_db #(fifo_config)::set(this, "*", "CFG", fifo_cfg);
    endfunction : build_phase

    task run_phase(uvm_phase phase);
      super.run_phase(phase);
      phase.raise_objection(this);

      `uvm_info("run_phase", "Reset Asserted", UVM_LOW)
      reset_seq.start(env.agt.sqr);
      `uvm_info("run_phase", "Reset Deasserted", UVM_LOW)

      `uvm_info("run_phase", "Write Only Sequence Started", UVM_LOW)
      Write_seq.start(env.agt.sqr);

      `uvm_info("run_phase", "Read Only Sequence Started", UVM_LOW)
      Read_seq.start(env.agt.sqr);

      `uvm_info("run_phase", "Write Read Sequence Started", UVM_LOW)
      Write_Read_seq.start(env.agt.sqr);

      `uvm_info("run_phase", "Stimulus Generation Ended", UVM_LOW)
      phase.drop_objection(this);
    endtask : run_phase

  endclass : fifo_test

endpackage : fifo_test_pkg