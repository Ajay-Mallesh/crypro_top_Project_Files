# ==========================================================================
# Tool: IC Compiler II
# Script: mcmm_setup.tcl
# Description: Array-Driven MCMM initialization for the Crypto Core
# ==========================================================================
puts "RM-info : Running script [info script]\n"

set CONSTR_DIR "./inputs/constraints"

remove_scenarios -all
remove_modes -all
remove_corners -all

# 1. Define Arrays
set m_constr(func) "crypto_m_func.tcl"
set m_constr(scan) "crypto_m_scan.tcl"

set c_constr(ss_125c) "crypto_c_ss_125c.tcl"
set c_constr(ff_m40c) "crypto_c_ff_m40c.tcl"

set s_constr(func.ss_125c) "crypto_s_func_ss_125c.tcl"
set s_constr(func.ff_m40c) "crypto_s_func_ff_m40c.tcl"
set s_constr(scan.ss_125c) "crypto_s_scan_ss_125c.tcl"
set s_constr(scan.ff_m40c) "crypto_s_scan_ff_m40c.tcl"

# 2. Create Containers
foreach m [array names m_constr] { create_mode $m }
foreach c [array names c_constr] { create_corner $c }
foreach s [array names s_constr] {
    lassign [split $s "."] m c
    create_scenario -name $s -mode $m -corner $c
}

# 3. Populate Containers
foreach m [array names m_constr] {
    current_mode $m
    source ${CONSTR_DIR}/$m_constr($m)
}
foreach c [array names c_constr] {
    current_corner $c
    source ${CONSTR_DIR}/$c_constr($c)
}
foreach s [array names s_constr] {
    current_scenario $s
    source ${CONSTR_DIR}/$s_constr($s)
}

# 4. Configure Scenario Analysis
set_scenario_status {func.ss_125c scan.ss_125c} -hold false
set_scenario_status {func.ff_m40c scan.ff_m40c} -setup false
set_scenario_status {*} -leakage_power false -dynamic_power false
set_scenario_status func.ss_125c -leakage_power true -dynamic_power true

puts "RM-info : Completed script [info script]\n"