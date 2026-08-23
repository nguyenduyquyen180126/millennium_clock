# Create a clock constraint for the primary CLOCK_50 port (50 MHz, period = 20 ns)
create_clock -name {CLOCK_50} -period 20.000 [get_ports {CLOCK_50}]

# Derive clock uncertainty
derive_clock_uncertainty

# Set constraints for other input/output paths (optional but good practice)
set_input_delay -clock {CLOCK_50} 2.000 [get_ports {KEY[*] SW[*]}]
set_output_delay -clock {CLOCK_50} 2.000 [get_ports {HEX0[*] HEX1[*] HEX2[*] HEX3[*] HEX4[*] HEX5[*] HEX6[*] HEX7[*]}]
