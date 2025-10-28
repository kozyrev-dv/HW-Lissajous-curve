onerror {resume}
quietly WaveActivateNextPane {} 0
add wave -noupdate -radix unsigned /sync_gen_tb/cnt_i
add wave -noupdate /sync_gen_tb/sync_o_1
add wave -noupdate /sync_gen_tb/sync_o_2
TreeUpdate [SetDefaultTree]
WaveRestoreCursors {{Cursor 1} {0 ps} 0}
quietly wave cursor active 0
configure wave -namecolwidth 192
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
WaveRestoreZoom {1000089 ps} {1023966 ps}
