# ==========================================================================
# FILE: crypto_s_scan_ff_m40c.tcl (Scan Hold Scenario)
# ==========================================================================

set_input_delay  -min 0.5 -clock main_clk [remove_from_collection [all_inputs] [get_ports clk]]
set_output_delay -min 0.5 -clock main_clk [all_outputs]
set_clock_uncertainty -hold 0.05 [get_clocks main_clk]