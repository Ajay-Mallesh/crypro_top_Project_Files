# ==========================================================================
# FILE: crypto_s_func_ff_m40c.tcl (Func Hold Scenario)
# ==========================================================================


# Hold Violation Trigger: Data arrives instantly from the outside world.
set_input_delay  -min 0.0 -clock main_clk [remove_from_collection [all_inputs] [get_ports clk]]
set_output_delay -min 0.4 -clock main_clk [all_outputs]

# Hold Violation Trigger: Massive fake pre-CTS skew.
set_clock_uncertainty -hold 0.35 [get_clocks main_clk]