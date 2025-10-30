onerror {resume}
quietly WaveActivateNextPane {} 0
add wave -noupdate -radix unsigned /vga_address_gen_tb/h_cnt
add wave -noupdate /vga_address_gen_tb/v_cnt_ena
add wave -noupdate -radix unsigned /vga_address_gen_tb/v_cnt
add wave -noupdate -radix unsigned /vga_address_gen_tb/x
add wave -noupdate -radix unsigned /vga_address_gen_tb/y
add wave -noupdate /vga_address_gen_tb/drawable
TreeUpdate [SetDefaultTree]
WaveRestoreCursors {{Cursor 1} {0 ps} 0}
quietly wave cursor active 0
configure wave -namecolwidth 244
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
WaveRestoreZoom {0 ps} {877 ps}
