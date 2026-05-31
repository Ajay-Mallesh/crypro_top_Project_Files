															Timing Analysis

1. Worst-Case Input-to-Register (in2reg)

report_timing -delay_type max -scenario func_ss -from [all_inputs] -to [all_registers] -max_paths 1 -nworst 1 -path_type full_clock_expanded -nets -capacitance -transition_time -physical

2. Worst-Case Register-to-Register (reg2reg)

report_timing -delay_type max -scenario func_ss -from [all_registers] -to [all_registers] -max_paths 1 -nworst 1 -path_type full_clock_expanded -nets -capacitance -transition_time -physical

3. Worst-Case Register-to-Output (reg2out)

report_timing -delay_type max -scenario func_ss -from [all_registers] -to [all_outputs] -max_paths 1 -nworst 1 -path_type full_clock_expanded -nets -capacitance -transition_time -physical

