# ==============================================================================
# Makefile for Verilog & ModelSim Simulation
# ==============================================================================


# Default target
.PHONY: all sim sim_cli clean help

all: sim

# Show help menu
help:
	@echo Verilog ModelSim Makefile Template
	@echo ==================================
	@echo make sim      - Run simulation in GUI mode (opens ModelSim)
	@echo make sim_cli  - Run simulation in command-line/batch mode
	@echo make clean    - Remove generated simulation files and folders
	@echo make help     - Show this help message

# Run simulation in GUI mode
clkdiv:
	vsim -do sim/clkdiv.tcl

counter_mod:
	vsim -do sim/counter_mod.tcl

# Run simulation in CLI/Batch mode (useful for CI/CD or fast tests)
clkdiv_cli:
	vsim -c -do "do sim/clkdiv.tcl; quit -f"

counter_mod_cli:
	vsim -c -do "do sim/counter_mod.tcl; quit -f"

# Clean up compilation database and temporary simulator outputs
clean:
	@echo Cleaning simulation artifacts...
	@if exist transcript del /Q transcript
	@if exist vsim.wlf del /Q vsim.wlf
	@if exist work rmdir /S /Q work
	@if exist wlft* del /Q wlft*
	@rm -rf work transcript vsim.wlf wlft*
