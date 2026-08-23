# Create work library
if {![file exists work]} {
    vlib work
}

# Compile source files
vlog rtl/add3.v
vlog rtl/bin2bcd_6bits.v
vlog rtl/bin2bcd_14bits.v
vlog rtl/clkdiv.v
vlog rtl/debounce.v
vlog rtl/display_ctrl.v
vlog rtl/seven_seg_decoder.v
vlog rtl/display.v
vlog rtl/test_counter.v
vlog rtl/millennium_clock.v
vlog tb/tb_millennium_clock.v

# Start simulation in CLI mode
vsim -c -voptargs=+acc work.tb_millennium_clock

# Run simulation
run -all
quit -f
