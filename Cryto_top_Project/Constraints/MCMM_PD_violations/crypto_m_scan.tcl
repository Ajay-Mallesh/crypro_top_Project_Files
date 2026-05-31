# ==========================================================================
# FILE: crypto_m_scan.tcl (Scan Mode)
# ==========================================================================

create_clock -name main_clk -period 10.0 [get_ports clk]
set_case_analysis 1 [get_ports scan_en]