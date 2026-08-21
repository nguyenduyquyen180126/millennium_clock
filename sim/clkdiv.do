# ==============================================================================
# ModelSim Wave Window Configuration File
# ==============================================================================


# Testbench top-level signals
add wave -divider "Testbench Signals"
add wave -noupdate -format Logic -radix binary /tb_clkdiv/clk
add wave -noupdate -format Logic -radix binary /tb_clkdiv/rst_n
add wave -noupdate -format Logic -radix binary /tb_clkdiv/clk_2Hz
add wave -noupdate -format Logic -radix binary /tb_clkdiv/tick_1Hz



