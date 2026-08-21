# ==============================================================================
# ModelSim Wave Window Configuration File for s_counter
# ==============================================================================

# Testbench top-level signals
add wave -divider "Testbench Signals"
add wave -noupdate -format Logic -radix binary /tb_counter_mod/clk
add wave -noupdate -format Logic -radix binary /tb_counter_mod/rst_n
add wave -noupdate -format Logic -radix binary /tb_counter_mod/en
add wave -noupdate -format Literal -radix unsigned /tb_counter_mod/sec
add wave -noupdate -format Logic -radix binary /tb_counter_mod/m_en
