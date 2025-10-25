#--------------------------------------------------------------------
#      Author:
#          Daniil Kozyrev, k-daniilv@mail.ru
#
#      Description:
#           QuestaSim/ModelSim start script which compiles the wth_axis_to_wrf_tb testbench's modules, prepares the waveform (wave.do file required)
#           and runs simulation with upper limit of 10000 ps of simulation (can be changed).
#
#--------------------------------------------------------------------

vlib work
vcom ../../../src/basics_p.vhd -work work -O0 -2008
vcom ../../../src/vga_ctrl/img_buf.vhd -work work -O0 -2008
vcom ./img_buf_tb.vhd -work work -O0 -2008
vsim -msgmode both img_buf_tb
# do wave.do
# run 1000 ns