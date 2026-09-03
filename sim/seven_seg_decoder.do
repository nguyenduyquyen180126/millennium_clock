# ==============================================================================
# ModelSim Wave Window Configuration File
# ==============================================================================

# Testbench top-level signals
add wave -divider "Inputs"
add wave -noupdate -format Logic -radix binary /tb_seven_seg_decoder/blink
add wave -noupdate -format Literal -radix hexadecimal /tb_seven_seg_decoder/hex_code

add wave -divider "Outputs"
add wave -noupdate -format Literal -radix binary /tb_seven_seg_decoder/seg_data

add wave -divider "Verification Status"
add wave -noupdate -format Literal -radix decimal /tb_seven_seg_decoder/errors
