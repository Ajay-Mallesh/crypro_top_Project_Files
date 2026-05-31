# ==========================================================================
# FILE: crypto_c_ss_125c.tcl (Setup Focus)
# ==========================================================================
set_process_number 1.0
set_voltage 0.95 -object_list VDD_DEFAULT
set_voltage 0.75 -object_list VDD_LP
set_temperature 125

set_timing_derate -early 0.95
set_timing_derate -late  1.05

# --> CORRECTED ICC2 TLU+ SYNTAX <--
# 1. Load the worst-case (CMAX) file into memory and name it 'max_tlup'
read_parasitic_tech -tlup ./inputs/tech/saed32nm_1p9m_Cmax.tluplus \
                    -layermap ./inputs/tech/saed32nm_tf_itf_tluplus.map \
                    -name max_tlup

# 2. Attach the loaded 'max_tlup' physics to this specific setup corner
set_parasitic_parameters -corner ss_125c -early_spec max_tlup -late_spec max_tlup