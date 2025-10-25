onerror {resume}
quietly WaveActivateNextPane {} 0
add wave -noupdate /overflow_counter_tb/clk
add wave -noupdate /overflow_counter_tb/rst_n
add wave -noupdate /overflow_counter_tb/ena
add wave -noupdate /overflow_counter_tb/cnt_o
add wave -noupdate /overflow_counter_tb/overflow_o
TreeUpdate [SetDefaultTree]
WaveRestoreCursors {{Cursor 1} {4120 ps} 0}
quietly wave cursor active 1
configure wave -namecolwidth 265
configure wave -valuecolwidth 100
configure wave -justifyvalue left
configure wave -signalnamewidth 0
configure wave -snapdistance 10
configure wave -datasetprefix 0
configure wave -rowmargin 4
configure wave -childrowmargin 2
configure wave -gridoffset 0
configure wave -gridperiod 1
configure wave -griddelta 40
configure wave -timeline 0
configure wave -timelineunits ns
update
WaveRestoreZoom {0 ps} {18384 ps}
