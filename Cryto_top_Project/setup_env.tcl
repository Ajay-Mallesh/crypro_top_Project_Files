# setup_env.tcl
# Purpose: Automatically create the crypto_top workspace directories

# 1. Create top-level directories
file mkdir "cmds"
file mkdir "docs"
file mkdir "inputs"
file mkdir "outputs"
file mkdir "scripts"
file mkdir "reports"

# 2. Create sub-directories inside inputs
# file mkdir "inputs/CLIBs"
file mkdir "inputs/constraints"
# file mkdir "inputs/tech"

# 3. Create sub-directories inside outputs
file mkdir "outputs/u_shape"
file mkdir "outputs/work"
