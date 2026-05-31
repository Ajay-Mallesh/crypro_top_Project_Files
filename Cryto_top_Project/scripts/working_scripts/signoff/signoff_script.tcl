# ==========================================================================
# FILE: scripts/signoff_script.tcl
# DESC: Signoff Extraction (StarRC) and PrimeTime Handoff for Crypto_Top
# AUTHOR: Ajay Mallesh
# VERSION: 1.0
# DATE: May 19, 2026 | 22:30 IST
# ==========================================================================

# STARRC : to generate spef file
# In Icc2 : write_parasitics -corner ss_125c -output ./outputs/SS_125C.spef [not accurate]
# STARRC : 

# Inputs :
# NXTGRD
# MAP FILE
# ROUTED DEF
# NDM DATABASE

Cbest.spef -> Cmin.nxtgrd[ff] , 125c
Cworst.spef -> Cmax.nxtgrd[ss] , m40c

# ##################################################################
# PRIMETIME ########################################################
# ##################################################################

cd inputs
cp ../../STARRC/outputs/spef/* .

# Generating Optimised Netlist
write_verilog ../PRIME_TIME/inputs/routed_netlist.v

# Generating sdc
write_sdc -scenario func.ff_125c -output ../PRIME_TIME/inputs/ff_125c.sdc
write_sdc -scenario func.ss_125c -output ../PRIME_TIME/inputs/ss_125c.sdc

# In primetime inputs directory copy upf file
cp ../../PD/inputs/ORCA_TOP.upf .

# 22 servers:
read_parasitics /home/attulsharma/PD_ADV_MAY25/ORCA_TOP/PRIME_TIME/inputs/ORCATOP.cworst.spef -keep_capacitive_coupling