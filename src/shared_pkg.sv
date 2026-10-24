////////////////////////////////////////////////////////////////////////////////
// Author: Salah Adel
// Description: Shared Package for FIFO UVM Verification Environment
// Date: October, 2026
////////////////////////////////////////////////////////////////////////////////
package shared_pkg;
  import uvm_pkg::*;
  `include "uvm_macros.svh"

  // Design Parameters
  parameter FIFO_WIDTH    = 16;
  parameter FIFO_DEPTH    = 8;
  parameter MAX_FIFO_ADDR = $clog2(FIFO_DEPTH);

  // Constraint Distribution Weights
  parameter RD_EN_ON_DIST = 30;
  parameter WR_EN_ON_DIST = 70;
  parameter RESET_ON_DIST = 2; // Low reset probability during stimulus generation

  // Control Signals Constants
  parameter ACTIVE   = 1;
  parameter INACTIVE = 0;

  parameter ACTIVE_RESET   = 0;
  parameter INACTIVE_RESET = 1;

  // Data Limits
  parameter MAX  = (2**FIFO_WIDTH) - 1;
  parameter ZERO = 0;

  // Global Verification Flags & Counters (Used across UVM Testbench)
  int error_count   = 0;
  int correct_count = 0;

endpackage : shared_pkg