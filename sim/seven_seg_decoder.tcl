# ==============================================================================
# ModelSim TCL Script for Running Simulation
# ==============================================================================

# 1. Create work library if it doesn't exist
if {![file exists work]} {
    vlib work
}

# 2. Compile RTL and Testbench source files
vlog rtl/seven_seg_decoder.v
vlog tb/tb_seven_seg_decoder.v

# 3. Start the simulation
# -voptargs=+acc enables full visibility for waveforms and debugging
vsim -voptargs=+acc work.tb_seven_seg_decoder

# 4. View waveform and load signal configurations
view wave
do sim/seven_seg_decoder.do

# 5. Run simulation
run -all

wave zoom full
