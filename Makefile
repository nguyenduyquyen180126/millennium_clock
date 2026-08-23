# ==============================================================================
# Makefile for Verilog & ModelSim Simulation
# ==============================================================================


# Default target
.PHONY: all sim sim_cli clean help

all: 

# Show help menu
help:
	@echo Verilog ModelSim Makefile Template
	@echo ==================================
	@echo make sim      - Run simulation in GUI mode (opens ModelSim)
	@echo make sim_cli  - Run simulation in command-line/batch mode
	@echo make clean    - Remove generated simulation files and folders
	@echo make help     - Show this help message

# Run simulation 
clkdiv:
	vsim -do sim/clkdiv.tcl

clkdiv_cli:
	vsim -c -do "do sim/clkdiv.tcl; quit -f"

bin2bcd_14bits_cli:
	vsim -c -do "do sim/bin2bcd_14bits.tcl; quit -f"

bin2bcd_14bits:
	vsim -do sim/bin2bcd_14bits.tcl

display_cli:
	vsim -c -do "do sim/display.tcl; quit -f"

display:
	vsim -do sim/display.tcl

millennium_clock_cli:
	vsim -c -do "do sim/millennium_clock.tcl; quit -f"


# Clean up compilation database and temporary simulator outputs
clean:
	@echo Cleaning simulation artifacts...
	@if exist transcript del /Q transcript
	@if exist vsim.wlf del /Q vsim.wlf
	@if exist work rmdir /S /Q work
	@if exist wlft* del /Q wlft*
	@rm -rf work transcript vsim.wlf wlft*
