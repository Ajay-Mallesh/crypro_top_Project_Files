# ==========================================================================
# FILE: scripts/cts_script.tcl
# DESC: Master CTS Execution (Standard-Cell Only / No Macros)
# AUTHOR: Ajay Mallesh
# VERSION: 2.0
# DATE: May 19, 2026 | 21:55 IST
# ==========================================================================

# 1. Authorize CTS reference cells (Buffers/Inverters/Level Shifters)
source ./scripts/cts_include_refs.tcl

# 2. NDR Setup: Double-Width/Spacing for Clock Nets
remove_routing_rules -all
create_routing_rule iccrm_clock_double_spacing -default_reference_rule -multiplier_width 2 -multiplier_spacing 2
set_clock_routing_rules -net_type sink -rules iccrm_clock_double_spacing -min_routing_layer M4 -max_routing_layer M5

# 3. Clock Constraints

current_mode func
set_max_transition 0.15 [get_clocks] -corners [all_corners]
# set_clock_tree_options -target_skew 0.05 -corners [all_corners]

set_clock_tree_options -target_skew 0.05 -corners [get_corners ss_125c]
set_clock_tree_options -target_skew 0.05 -corners [get_corners ss_m40c]
set_clock_tree_options -target_skew 0.02 -corners [get_corners ff_m40c]
set_clock_tree_options -target_skew 0.02 -corners [get_corners ff_125c]

# 4. Uncertainty & Pessimism Management
foreach_in_collection scen [all_scenarios] {
    current_scenario $scen
    set_clock_uncertainty 0.1 -setup [all_clocks]
    set_clock_uncertainty 0.05 -hold [all_clocks]
}

# 5. enable CRPR
set_app_options -name time.remove_clock_reconvergence_pessimism -value true

# 6. CTS Instance Prefixes
set_app_option -name cts.common.user_instance_name_prefix -value clock_opt_clock_
set_app_option -name opt.common.user_instance_name_prefix -value clock_opt_opt_

# ==========================================================================
# Clock Level Shifter Insertion (2 Level Shifters for VDDL crossing)
# ==========================================================================
insert_mv_cells -level_shifter \
    -cell_name clk_ls_primary \
    -input_pin [get_pins clk_spine_out_1] \
    -output_pin [get_pins u_crypto_engine_lp/clk_in_1]

insert_mv_cells -level_shifter \
    -cell_name clk_ls_secondary \
    -input_pin [get_pins clk_spine_out_2] \
    -output_pin [get_pins u_crypto_engine_lp/clk_in_2]

# 7. CTS Execution (Standard Cell Only)
remove_routes -global_route

# Build the tree
clock_opt -to build_clock
save_block -as build_clock_done

# Route the clock
clock_opt -to route_clock
save_block -as cts_done

# 8. Final Optimization (Hold/Timing Fixes)
set_app_options -name ccd.hold_control_effort -value high
set_app_options -name opt.dft.clock_aware_scan_reorder -value true

clock_opt -final_opto
save_block -as clock_opt_all