# 1. Design Initialization & NDM Creation
set search_path ./inputs/CLIBs/
set a {saed32_1p9m_tech.ndm saed32_hvt.ndm saed32_lvt.ndm saed32_rvt.ndm saed32_sram_lp.ndm}
create_lib -ref_libs $a ./outputs/work/CRYPTO_TOP_SCANCHAIN.nlib
save_lib

open_lib ./outputs/work/CRYPTO_TOP_SCANCHAIN.nlib
read_verilog ./outputs/crypto_top_netlist.v
link

# 2. Floorplan Creation 
initialize_floorplan -shape R -core_utilization 0.70 -core_offset 5 -site_def unit -use_site_row -side_ratio {1 1}
save_block -as initial_floorplan

# 3. Pin Placement
set_block_pin_constraints -self -sides 1 -allowed_layers M5 -pin_spacing 1 -corner_keepout_distance 250
place_pins -ports [remove_from_collection [all_inputs] [get_ports *clk*]]

set_block_pin_constraints -self -sides 1 -allowed_layers M5 -pin_spacing 1 -corner_keepout_distance 450
place_pins -ports [get_ports *clk*]

set_block_pin_constraints -self -sides 1 -allowed_layers M5 -pin_spacing 1 -corner_keepout_distance 460
place_pins -ports [all_outputs]

save_block -as ports_placed

# 4. Multi-Voltage Initialization (The Chapter 4 Fix!)
load_upf ./outputs/crypto_top.upf
commit_upf 

source ./scripts/voltage_area_efficient.tcl
save_block -as voltage_area_created

check_mv_design

# 5. Macro Placement (MUST happen before Powerplan)
# -> INSERT YOUR MACRO PLACEMENT COMMANDS HERE <-
# e.g., create_placement -floorplan OR manually set_macro_location

# 6. Power Delivery Network
source ./scripts/powerplan.tcl
save_block -as powerplan_completed

# 7. DFT / Scan Chain Def
read_def ./outputs/crypto_top.scandef