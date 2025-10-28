onerror {resume}
quietly WaveActivateNextPane {} 0
add wave -noupdate /img_buf_tb/clk
add wave -noupdate /img_buf_tb/rst_n
add wave -noupdate /img_buf_tb/filled_o
add wave -noupdate /img_buf_tb/is_write_allow
add wave -noupdate /img_buf_tb/is_writing
add wave -noupdate /img_buf_tb/we_i
add wave -noupdate -height 30 -expand -group {WRITE ADDRESS} /img_buf_tb/img_buf_inst/wr_adr_x
add wave -noupdate -height 30 -expand -group {WRITE ADDRESS} /img_buf_tb/img_buf_inst/wr_adr_y_ena
add wave -noupdate -height 30 -expand -group {WRITE ADDRESS} /img_buf_tb/img_buf_inst/wr_adr_y
add wave -noupdate -height 30 -expand -group {WRITE ADDRESS} /img_buf_tb/img_buf_inst/wr_mem_adr
add wave -noupdate -radix hexadecimal /img_buf_tb/data_i
add wave -noupdate /img_buf_tb/is_read_allow
add wave -noupdate /img_buf_tb/is_reading
add wave -noupdate /img_buf_tb/re_i
add wave -noupdate -radix hexadecimal /img_buf_tb/rd_adr_i
add wave -noupdate -radix hexadecimal /img_buf_tb/data_o
add wave -noupdate /img_buf_tb/img_buf_inst/ram_block
TreeUpdate [SetDefaultTree]
WaveRestoreCursors {{Cursor 1} {589000 ps} 0}
quietly wave cursor active 1
configure wave -namecolwidth 266
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
WaveRestoreZoom {574432 ps} {612989 ps}
