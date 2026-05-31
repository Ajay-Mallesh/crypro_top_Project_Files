# ==========================================================================
# MULTI-VOLTAGE PHYSICAL DESIGN SDC (only for synthesis) 
# ==========================================================================
# PROJECT        : Multi-Voltage Crypto Core
# AUTHOR         : AJAYMALLESH
# VERSION        : 1.0 (Silicon-Ready SDC)
# GENERATION DATE: 25/04/2026 01:25:16 PM
# DESCRIPTION    : Physical Timing Constraints & Setup 
# NOTE			 : "Not to be used for PHYSICAL DESIGN {Timing Analysis}"
# ==========================================================================

create_clock -name "sys_clk" -period 2.0 -waveform {0.0 1.0} [get_ports clk]
create_clock -name "v_clk" -period 2.0 -waveform {0.0 1.0}

set_input_delay  -max 0.8 -clock [get_clocks v_clk] [get_ports plaintext_in]
set_input_delay  -max 0.8 -clock [get_clocks v_clk] [get_ports valid_in]
set_output_delay -max 0.8 -clock [get_clocks v_clk] [get_ports ciphertext_out]
set_output_delay -max 0.8 -clock [get_clocks v_clk] [get_ports valid_out]

set_max_fanout 32 [current_design]
set_max_transition 0.5 [current_design]
set_load 5.0 [all_outputs]
set_input_transition 0.1 [all_inputs]