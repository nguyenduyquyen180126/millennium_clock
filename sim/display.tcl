# ==============================================================================
# ModelSim TCL Script for Running Simulation
# ==============================================================================

# 1. Create work library if it doesn't exist
if {![file exists work]} {
    vlib work
}

# 2. Compile RTL and Testbench source files
# Note: Add/remove source files here as your project grows.
vlog rtl/*.v
vlog tb/tb_display.v

# 3. Start the simulation
# -voptargs=+acc enables full visibility for waveforms and debugging
vsim work.tb_display


view wave
do sim/display.do


run -all

wave zoom full