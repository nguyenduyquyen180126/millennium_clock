# Create work library if it doesn't exist
if {![file exists work]} {
    vlib work
}

# Compile RTL and Testbench source files
vlog rtl/button_auto_repeat.v
vlog tb/tb_button_auto_repeat.v

# Start the simulation in command line mode
vsim -c -voptargs=+acc work.tb_button_auto_repeat

# Run simulation
run -all
quit -f
