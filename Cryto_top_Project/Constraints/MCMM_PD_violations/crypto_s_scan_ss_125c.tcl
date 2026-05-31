# ==========================================================================
# FILE: crypto_s_scan_ss_125c.tcl (Scan Setup Scenario)
# ==========================================================================

set_input_delay  -max 1.0 -clock main_clk [remove_from_collection [all_inputs] [get_ports clk]]
set_output_delay -max 1.0 -clock main_clk [all_outputs]
set_clock_uncertainty -setup 0.10 [get_clocks main_clk]