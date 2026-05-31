# ==========================================================================
# FILE: crypto_c_ff_m40c.tcl (Hold Focus)
# ==========================================================================
set_process_number 1.0
set_voltage 1.05 -object_list VDD_DEFAULT
set_voltage 0.85 -object_list VDD_LP
set_temperature -40

set_timing_derate -early 0.80
set_timing_derate -late  1.20

# --> CORRECTED ICC2 TLU+ SYNTAX <--
# 1. Load the best-case (CMIN) file into memory and name it 'min_tlup'
read_parasitic_tech -tlup ./inputs/tech/saed32nm_1p9m_Cmin.tluplus \
                    -layermap ./inputs/tech/saed32nm_tf_itf_tluplus.map \
                    -name min_tlup

# 2. Attach the loaded 'min_tlup' physics to this specific hold corner
set_parasitic_parameters -corner ff_m40c -early_spec min_tlup -late_spec min_tlup