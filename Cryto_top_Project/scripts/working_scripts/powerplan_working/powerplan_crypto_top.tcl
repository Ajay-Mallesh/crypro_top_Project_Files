# ==========================================================================
# PROJECT        : Multi-Voltage Crypto Core
# AUTHOR         : [AJAYMALLESH]
# VERSION        : 1.0 (Silicon-Ready)
# DESCRIPTION    : Physical Power Planning (PG Mesh) Script
# ==========================================================================

remove_pg_strategies -all
remove_pg_patterns -all
remove_pg_regions -all
remove_pg_via_master_rules -all
remove_pg_strategy_via_rules -all
remove_routes -net_types {power ground} -ring -stripe -macro_pin_connect -lib_cell_pin_connect
remove_routes -net_types {power ground} -ring -global_route -detail_route
remove_vias [get_vias]

connect_pg_net

set_pg_via_master_rule pgvia_8x10 -via_array_dimension {8 10}

#########################################################################
# 1. TOP MESH (M7 / M8)
#########################################################################

create_pg_mesh_pattern P_top_two -layers { \
    {{horizontal_layer: M7} {width: 1.104} {spacing: interleaving} {pitch: 13.376} {offset: 0.856} {trim : true} } \
    {{vertical_layer: M8} {width: 4.64 } {spacing: interleaving} {pitch: 19.456} {offset: 6.08} {trim : true} } \
} -via_rule { {intersection: adjacent} {via_master : pgvia_8x10} }

# Default Voltage area (VDD_DEFAULT blocked exactly at PD_LP)
set_pg_strategy S_default_vddvss -core -pattern { {name: P_top_two} {nets: {VSS VDD_DEFAULT}} {offset_start: {0 0}} } \
    -blockage { {{nets: VDD_DEFAULT} {voltage_areas: PD_LP}} } \
    -extension { {{stop:design_boundary_and_generate_pin}} }

# PD_LP voltage area (VDDL) - Pushes straps exactly to all 4 inner guard band boundaries
set_pg_strategy S_va_vddl -voltage_areas PD_LP -pattern { {name: P_top_two} {nets: {- VDD_LP}} {offset_start: {0 0}} } \
    -extension { {{direction: T B L R} {stop: keep_floating_wire_pieces}} }


#########################################################################
# 2. LOWER MESH (M2)
#########################################################################

create_pg_mesh_pattern P_m2_triple -layers { \
    {{vertical_layer: M2} {track_alignment : track} {width: 0.44 0.192 0.192} {spacing: 2.724 3.456} {pitch: 9.728} {offset: 1.216} {trim : true} } \
}

# Default Voltage area (VDD_DEFAULT blocked exactly at PD_LP)
set_pg_strategy S_m2_vddvss -core -pattern { {name: P_m2_triple} {nets: {VDD_DEFAULT VSS VSS}} {offset_start: {0 0}} } \
    -blockage { {{nets: VDD_DEFAULT} {voltage_areas: PD_LP}} } \
    -extension {{stop:keep_floating_wire_pieces}}

# PD_LP voltage area (VDDL) - Pushes M2 exactly to all 4 inner guard band boundaries
set_pg_strategy S_m2_vddl -voltage_areas PD_LP -pattern { {name: P_m2_triple} {nets: {VDD_LP - -}} {offset_start: {0 0}} } \
    -extension { {{direction: T B L R} {stop: keep_floating_wire_pieces}} }


#########################################################################
# 3. MACRO RINGS (COMMENTED OUT PER REFERENCE METHODOLOGY)
#########################################################################

# create_pg_ring_pattern P_macro_ring -horizontal_layer M5 -horizontal_width 2 -vertical_layer M6 -vertical_width 2
# set_pg_strategy S_macro_ring -macros [get_cells -hierarchical -filter "is_macro == true"] \
#    -pattern {{name: P_macro_ring} {nets: {VDD_DEFAULT VSS}}}
# compile_pg -strategies {S_macro_ring}


#########################################################################
# 4. MESH VIA RULES & COMPILE
#########################################################################

set_pg_strategy_via_rule S_via_m2_m7 -via_rule { \
    {{{strategies: {S_m2_vddvss S_m2_vddl}} {layers: { M2 }} {nets: {VDD_DEFAULT VDD_LP}} } {{strategies: {S_default_vddvss S_va_vddl}} {layers: { M7 }} } {via_master: {default}}} \
    {{{strategies: {S_m2_vddvss S_m2_vddl}} {layers: { M2 }} {nets: {VSS}} } {{strategies: {S_default_vddvss S_va_vddl}} {layers: { M7 }} } {via_master: {default}}} \
}

compile_pg -strategies {S_va_vddl S_default_vddvss S_m2_vddvss S_m2_vddl} -via_rule {S_via_m2_m7}


#########################################################################
# 5. STANDARD CELL RAILS (M1)
#########################################################################

create_pg_std_cell_conn_pattern P_std_cell_rail

# Default Rails (VDD_DEFAULT blocked at PD_LP)
set_pg_strategy S_std_cell_rail_VSS_VDD -core \
    -blockage { {{nets: VDD_DEFAULT} {voltage_areas: PD_LP}} } \
    -pattern {{pattern: P_std_cell_rail}{nets: {VSS VDD_DEFAULT}}}

# LP Rails (VDDL)
set_pg_strategy S_std_cell_rail_VDDL -voltage_areas PD_LP \
    -pattern {{pattern: P_std_cell_rail}{nets: {VDD_LP}}}

set_pg_strategy_via_rule S_via_stdcellrail -via_rule {{intersection: adjacent} {via_master: default}}

compile_pg -strategies {S_std_cell_rail_VSS_VDD S_std_cell_rail_VDDL} -via_rule {S_via_stdcellrail}


#########################################################################
# 6. SANITY CHECKS
#########################################################################

check_pg_missing_vias
check_pg_drc -ignore_std_cells
check_pg_connectivity -check_std_cell_pins none