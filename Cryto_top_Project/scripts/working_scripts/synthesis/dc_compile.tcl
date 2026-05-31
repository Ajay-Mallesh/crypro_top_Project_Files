# ==========================================================================
# MULTI-VOLTAGE SYNTHESIS SCRIPT (2-Domain: 0.95V & 0.75V)
# ==========================================================================
# PROJECT     : Multi-Voltage Crypto Core
# AUTHOR      : AJAYMALLESh
# VERSION     : 1.2 (Corrected Order: Compile -> DFT -> Rename -> Export)
# DESCRIPTION : Script for SYNTHESIS (dc_shell)
# ==========================================================================

# 1. PATHS & VARIABLES SETUP
set search_path "./inputs"
set SDC_FILE "./inputs/constraints_mv.sdc"
set UPF_FILE "./inputs/crypto_power.upf"

# 2. LIBRARY SETUP (One-Line Format)
set target_library "saed32rvt_ss0p95v125c.db saed32rvt_ss0p75v125c.db saed32rvt_ulvl_ss0p95v125c_i0p75v.db saed32rvt_dlvl_ss0p75v125c_i0p95v.db"
set link_library "* $target_library"

# 3. READ & ELABORATE RTL
analyze -format verilog {crypto_top.v}
elaborate crypto_top
current_design crypto_top
link

# 4. READ POWER INTENT (UPF)
load_upf $UPF_FILE
set_voltage 0.95 -object_list {VDD_DEFAULT}
set_voltage 0.75 -object_list {VDD_LP}
set_voltage 0.00 -object_list {VSS}

# 5. READ TIMING CONSTRAINTS & OPERATING CONDITIONS
read_sdc $SDC_FILE
set_operating_conditions -library saed32rvt_ss0p95v125c ss0p95v125c
check_mv_design

# ==========================================================================
# 5.5 MULTI-VOLTAGE PRE-COMPILATION FIXES
# ==========================================================================
# Fix for MV-027: Unlock Tie cells for constant logic 0/1
remove_attribute [get_lib_cells */TIE*] dont_use

# Fix for MV-012: Safely handle massive input nets and allow level shifters
set_input_transition 0.1 [get_ports rst_n]
set_input_transition 0.1 [get_ports valid_in]

set auto_insert_level_shifters_on_ideal_nets all
set auto_insert_level_shifters_on_clocks false
set compile_enable_multivoltage_dr_fix true

# ==========================================================================
# 6. MAIN COMPILATION (MUST HAPPEN BEFORE DFT!)
# ==========================================================================
uniquify -force
# Map RTL to scan-ready standard cells
compile_ultra -scan -no_autoungroup -gate_clock -retime

# Insert the missing level shifters and stabilize the domains
insert_mv_cells
compile_ultra -incremental

# ==========================================================================
# 7. DFT & SCAN CHAIN INSERTION (Stitch the placed cells)
# ==========================================================================
# 1. Create the missing test ports
create_port scan_en -direction in
create_port scan_in_1 -direction in
create_port scan_out_1 -direction out

# 2. Define the Test Protocol
set_dft_signal -view existing_dft -type ScanClock -port clk -timing {45 55}
set_dft_signal -view existing_dft -type Reset -port rst_n -active_state 0
set_dft_signal -view spec -type ScanEnable -port scan_en -active_state 1
set_dft_signal -view spec -type ScanDataIn -port scan_in_1
set_dft_signal -view spec -type ScanDataOut -port scan_out_1

# 3. Enable Auto-Fix and limit to 1 chain
set_dft_configuration -fix_reset enable -fix_clock enable
set_scan_configuration -chain_count 1

# 4. Generate and physically stitch the scan chains
create_test_protocol
dft_drc
preview_dft
insert_dft

# ==========================================================================
# 8. RENAME & EXPORT DATA (Synchronize all files)
# ==========================================================================
# IMPORTANT: Rename must happen EXACTLY here to synchronize all outputs
change_names -rules verilog -hierarchy

# --- A. SCANDEF ---
write_scan_def -output ./outputs/crypto_top.scandef

# --- B. UPF ---
save_upf ./outputs/crypto_top.upf

set file_name "./outputs/crypto_top.upf"
set in_file [open $file_name r]
set file_data [read $in_file]
close $in_file

regsub -all {\[([0-9]+)\]_UPF} $file_data {_\1_UPF} file_data

set out_file [open $file_name w]
puts $out_file "# =========================================================================="
puts $out_file "# PROJECT     : Multi-Voltage Crypto Core"
puts $out_file "# AUTHOR      : \\\[AJAYMALLESh\\\]"
puts $out_file "# VERSION     : 1.0 (Silicon-Ready)"
puts $out_file "# DATE        : [clock format [clock seconds] -format {%B %d, %Y}]"
puts $out_file "# ==========================================================================\n"
puts $out_file $file_data
close $out_file

# --- C. SDC ---
write_sdc ./outputs/crypto_top_synth.sdc
set file_name "./outputs/crypto_top_synth.sdc"
set in_file [open $file_name r]; set file_data [read $in_file]; close $in_file
set out_file [open $file_name w]
puts $out_file "# =========================================================================="
puts $out_file "# PROJECT     : Multi-Voltage Crypto Core"
puts $out_file "# AUTHOR      : \\\[AJAYMALLESh\\\]"
puts $out_file "# VERSION     : 1.0 (Mapped Timing Constraints)"
puts $out_file "# ==========================================================================\n"
puts $out_file $file_data
close $out_file

# --- D. NETLIST ---
write -format verilog -hierarchy -output ./outputs/crypto_top_netlist.v
set file_name "./outputs/crypto_top_netlist.v"
set in_file [open $file_name r]; set file_data [read $in_file]; close $in_file
set out_file [open $file_name w]
puts $out_file "// =========================================================================="
puts $out_file "// PROJECT     : Multi-Voltage Crypto Core"
puts $out_file "// AUTHOR      : \\\[AJAYMALLESh\\\]"
puts $out_file "// VERSION     : 1.0 (Mapped Gate-Level Netlist)"
puts $out_file "// ==========================================================================\n"
puts $out_file $file_data
close $out_file

# 9. REPORTS
#report_level_shifter > ./outputs/mv_level_shifters.rpt
#report_power_domain  > ./outputs/mv_domains.rpt
#report_timing        > ./outputs/timing.rpt
#report_area          > ./outputs/area.rpt
#report_dft           > ./outputs/dft_scan.rpt  ;# [NEW] Added a quick scan report!

# 9. Use if you want to exit "dc_shell" after SYNTHESIS COMPILATION
#exit