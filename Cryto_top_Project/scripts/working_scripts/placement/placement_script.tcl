# copy_block -from_block all_error_fixed -to_block initial_placement

open_block initial_placement

check_design -checks pre_placement

set_fixed_objects [get_flat_cells -filter "is_hard_macro == true"]

read_def ./outputs/crypto_top.scandef

source ./inputs/constraints/mcmm_setup.tcl

set_attribute [get_lib_cells *TIE*] dont_touch false
set_attribute [get_lib_cells *TIE*] dont_use false

set_app_options -name place.legalize.enable_advance_legalizer -value true
set_app_options -name place.legalize.legalizer_search_and_repair -value true

set_app_options -name place.coarse.max_density -value 0.75
set_app_options -name opt.common.max_fanout -value 25

set_ideal_network [all_fanout -clock_tree]

set_ignored_layers -min_routing_layer M2 -max_routing_layer M6

set_app_options -name route.common.net_max_layer_mode -value hard
set_app_options -name route.common.net_min_layer_mode -value allow_pin_connection

remove_placement_blockages -all
derive_placement_blockages

create_placement

# place_opt

legalize_placement

report_congestion -rerun_global_router

save_block

report_timing