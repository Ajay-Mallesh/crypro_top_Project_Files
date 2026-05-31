# ==========================================================================
# PROJECT       : Multi-Voltage Crypto Core
# SCRIPT        : qa_checks_pre_cts_master.tcl
# DESCRIPTION   : Complete QA Checklist from Netlist to Pre-CTS Stage
# ==========================================================================

puts "\n========================================================="
puts " STAGE 1: PORT & PIN PLACEMENT CHECKS"
puts "========================================================="
puts "--> Running: report_ports -physical"
report_ports -physical

puts "--> Running: check_pin_placement (Inputs & Outputs)"
check_pin_placement -ports [all_inputs]
check_pin_placement -ports [all_outputs]


puts "\n========================================================="
puts " STAGE 2: INITIALIZATION & LOGICAL SETUP CHECKS"
puts "========================================================="
puts "--> Running: check_mv_design (UPF & Domain Check)"
check_mv_design

puts "--> Running: check_design -checks pre_placement_stage"
check_design -checks pre_placement_stage


puts "\n========================================================="
puts " STAGE 3: FLOORPLAN & POWER MESH (PG) CHECKS"
puts "========================================================="
puts "--> Running: check_floorplan"
check_floorplan

puts "--> Running: check_pg_connectivity -check_pins all"
check_pg_connectivity -check_pins all

puts "--> Running: check_pg_drc"
check_pg_drc


puts "\n========================================================="
puts " STAGE 4: PLACEMENT & CONGESTION CHECKS"
puts "========================================================="
puts "--> Running: check_legality"
check_legality

puts "--> Running: report_congestion -routing_stage global"
report_congestion -routing_stage global


puts "\n========================================================="
puts " STAGE 5: PRE-CTS STA & DESIGN RULE (DRV) CHECKS"
puts "========================================================="
puts "--> Running: report_constraint -all_violators (DRVs)"
report_constraint -all_violators -max_transition -max_capacitance 

# To fix max capacitance violations 

# size_cell u_cipher_hp/round_data_reg_42__115_ [get_lib_cells */SDFFARX2_HVT]
# size_cell u_cipher_hp/round_data_reg_42__63_  [get_lib_cells */SDFFARX2_HVT]
# size_cell u_cipher_hp/round_data_reg_42__19_  [get_lib_cells */SDFFARX2_HVT]
# size_cell u_cipher_hp/round_data_reg_6__117_  [get_lib_cells */SDFFARX2_HVT]

# ==========================================================================
# MANUAL FIXES FOR MAX_TRANSITION (SLEW)
# ==========================================================================

# STRATEGY 1: SIZE UP THE DRIVER
# Use this if the wire is short but the gate is too weak (e.g., X1 -> X4).
# Syntax: size_cell <hier_path/instance_name> [get_lib_cells <library/cell_name>]
size_cell u_cipher_hp/INST_NAME [get_lib_cells */SDFFARX4_HVT]

# STRATEGY 2: INSERT A BUFFER
# Use this if the wire is very long. It breaks the wire and "refreshes" the signal.
# Syntax: insert_buffer <pin_path> -lib_cell <library/buffer_name> -new_cell_names <new_inst_name>
insert_buffer [get_pins u_cipher_hp/INST_NAME/Q] \
    -lib_cell */BUF_X4_HVT \
    -new_cell_names u_cipher_hp/trans_fix_buf_0

puts "--> Running: report_qor -summary"
report_qor -summary


puts "\n========================================================="
puts " STAGE 6: TAPE-OUT PARANOIA CHECKS (ADVANCED)"
puts "========================================================="
puts "--> Running: Level Shifter Physical Verification"
report_level_shifters -domain PD_LP

puts "--> Running: Pre-CTS Power Baseline"
report_power -scenario func_ss

puts "--> Running: Clock Tree Exception Dry-Run"
check_clock_trees

puts "--> Running: Scan Chain Integrity Check"
check_scan_chain

puts "--> Running: High Fanout Net Report (>1000 pins)"
report_net_fanout -nosplit -threshold 1000


puts "\n========================================================="
puts " MASTER QA SCRIPT COMPLETE."
puts " Review the log above. If everything is clean, you are"
puts " officially cleared for Clock Tree Synthesis!"
puts "========================================================="