# ==========================================================================
# FILE: crypto_m_func.tcl (Functional Mode)
# ==========================================================================


create_clock -name main_clk -period 1.0 [get_ports clk]
set_case_analysis 0 [get_ports scan_en]
set_false_path -from [get_ports rst_n]