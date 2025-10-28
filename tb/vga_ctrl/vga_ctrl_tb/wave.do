onerror {resume}
quietly WaveActivateNextPane {} 0
add wave -noupdate /vga_ctrl_tb/clk
add wave -noupdate /vga_ctrl_tb/rst_n
add wave -noupdate -radix hexadecimal /vga_ctrl_tb/img_i
add wave -noupdate /vga_ctrl_tb/vga_ctrl_inst/img_buf_inst/wr_adr
add wave -noupdate /vga_ctrl_tb/valid_i
add wave -noupdate /vga_ctrl_tb/ready_o
add wave -noupdate /vga_ctrl_tb/write_start
add wave -noupdate /vga_ctrl_tb/write_finished
add wave -noupdate -divider -height 34 {img address gen}
add wave -noupdate -radix unsigned /vga_ctrl_tb/vga_ctrl_inst/vga_address_gen_inst/h_cnt
add wave -noupdate -radix unsigned /vga_ctrl_tb/vga_ctrl_inst/vga_address_gen_inst/v_cnt
add wave -noupdate -radix unsigned /vga_ctrl_tb/vga_ctrl_inst/vga_address_gen_inst/x
add wave -noupdate -radix unsigned /vga_ctrl_tb/vga_ctrl_inst/vga_address_gen_inst/y
add wave -noupdate /vga_ctrl_tb/vga_ctrl_inst/vga_address_gen_inst/drawable
add wave -noupdate -radix unsigned /vga_ctrl_tb/vga_ctrl_inst/img_buf_inst/rd_adr_i
add wave -noupdate -radix unsigned /vga_ctrl_tb/vga_ctrl_inst/img_buf_inst/data_o
add wave -noupdate -divider -height 34 VGA
add wave -noupdate -color {Dark Orchid} -radix hexadecimal /vga_ctrl_tb/vga_r_o
add wave -noupdate -color {Dark Orchid} -radix hexadecimal /vga_ctrl_tb/vga_g_o
add wave -noupdate -color {Dark Orchid} -radix hexadecimal /vga_ctrl_tb/vga_b_o
add wave -noupdate /vga_ctrl_tb/vga_hsync_o
add wave -noupdate /vga_ctrl_tb/vga_vsync_o
TreeUpdate [SetDefaultTree]
WaveRestoreCursors {{Cursor 1} {49000 ps} 0}
quietly wave cursor active 1
configure wave -namecolwidth 339
configure wave -valuecolwidth 40
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
WaveRestoreZoom {0 ps} {38141 ps}
