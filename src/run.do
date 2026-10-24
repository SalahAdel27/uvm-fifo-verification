# ==============================================================================
# File Name: run.do
# Description: QuestaSim DO Script - FIFO UVM Clean Text Reports Setup
# Author: Salah Adel
# ==============================================================================

# 1. Clear transcript and close previous simulation
transcript off
vsim -c -do "quit -sim"
transcript on

# 2. Create work library if it doesn't exist
if {[file exists work]} {
    vdel -lib work -all
}
vlib work
vmap work work

# 3. Compile Shared Package & Interfaces
echo "-----------------------------------------------------------------"
echo "--> Compiling Shared Packages and Interfaces..."
echo "-----------------------------------------------------------------"
vlog -sv shared_pkg.sv
vlog -sv FIFO_if.sv

# 4. Compile Design Under Test (DUT) with Code Coverage
echo "-----------------------------------------------------------------"
echo "--> Compiling DUT (FIFO)..."
echo "-----------------------------------------------------------------"
vlog -sv +cover=sbcef FIFO.sv

# 5. Compile UVM Packages
echo "-----------------------------------------------------------------"
echo "--> Compiling UVM Packages..."
echo "-----------------------------------------------------------------"
vlog -sv fifo_seq_item_pkg.sv
vlog -sv fifo_sequence_pkg.sv
vlog -sv fifo_sequencer_pkg.sv
vlog -sv fifo_config_pkg.sv
vlog -sv fifo_driver_pkg.sv
vlog -sv fifo_monitor_pkg.sv
vlog -sv fifo_agent_pkg.sv
vlog -sv fifo_scoreboard_pkg.sv
vlog -sv +cover=f fifo_coverage_pkg.sv
vlog -sv fifo_env_pkg.sv
vlog -sv fifo_test_pkg.sv

# 6. Compile Assertions Module & Top Module
echo "-----------------------------------------------------------------"
echo "--> Compiling Assertions and Top Testbench..."
echo "-----------------------------------------------------------------"
vlog -sv fifo_assertions.sv
vlog -sv fifo_top.sv

# 7. Elaboration & Simulation Setup
echo "-----------------------------------------------------------------"
echo "--> Starting Elaboration and Simulation..."
echo "-----------------------------------------------------------------"
vsim -voptargs=+acc work.fifo_top -coverage -classdebug -assertdebug

# 8. Add Waves to Wave Window
echo "-----------------------------------------------------------------"
echo "--> Wave Window Configuration..."
echo "-----------------------------------------------------------------"
add wave -position insertpoint sim:/fifo_top/fifo_vif/*
add wave -position insertpoint sim:/fifo_top/DUT/*

# 9. Run Simulation
echo "-----------------------------------------------------------------"
echo "--> Running Simulation..."
echo "-----------------------------------------------------------------"
run -all

# 10. Save Database & Export Detailed Text Reports (.txt)
echo "-----------------------------------------------------------------"
echo "--> Saving Coverage UCDB and Exporting ALL Text Reports..."
echo "-----------------------------------------------------------------"

# Save Coverage Database
coverage save fifo_cov.ucdb

# 1. Detailed Code Coverage Report (.txt)
coverage report -detail -code bcefst -output code_coverage_rpt.txt

# 2. Detailed Functional Coverage Report (.txt)
coverage report -detail -cvg -output functional_coverage_rpt.txt

# 3. Assertions Detail Report (.txt)
coverage report -detail -assert -output assertions_detail_rpt.txt

# 3. Detailed Assertions Report (.txt)
coverage report -detail -assert -output assertions_detail_rpt.txt

# 4. Assertions Summary Report (.txt)
assertion action -file assertions_summary_rpt.txt -show all

# 11. Zoom Fit in Wave Window
wave zoom full