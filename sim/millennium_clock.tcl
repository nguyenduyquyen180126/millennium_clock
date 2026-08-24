# Create work library
if {![file exists work]} {
    vlib work
}

# Compile source files
vlog rtl/*.v
vlog tb/tb_millennium_clock.v

# Start simulation in CLI mode
vsim -c -voptargs=+acc work.tb_millennium_clock

# Run simulation
run -all
quit -f
