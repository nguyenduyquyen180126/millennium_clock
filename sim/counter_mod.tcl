# ==============================================================================
# ModelSim TCL Script for Running s_counter Simulation
# ==============================================================================

# 1. Create work library if it doesn't exist
if {![file exists work]} {
    vlib work
}

# 2. Compile RTL and Testbench source files
vlog rtl/counter_mod.v
vlog tb/tb_counter_mod.v

# 3. Start the simulation
# -voptargs=+acc enables full visibility for waveforms and debugging
vsim work.tb_counter_mod

view wave
do sim/counter_mod.do

run -all

wave zoom full
