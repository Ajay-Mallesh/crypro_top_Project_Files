# ==========================================================================
# FILE: crypto_s_func_ss_125c.tcl (Func Setup Scenario)
# ==========================================================================

# Setup Violation Trigger: External world eats 0.8ns of the 1.0ns clock.
set_input_delay  -max 0.8 -clock main_clk [remove_from_collection [all_inputs] [get_ports clk]]
set_output_delay -max 0.8 -clock main_clk [all_outputs]

set_clock_uncertainty -setup 0.15 [get_clocks main_clk]