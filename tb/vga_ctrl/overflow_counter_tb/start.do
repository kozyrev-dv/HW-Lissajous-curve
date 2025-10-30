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
vcom ../../../src/vga_ctrl/overflow_counter.vhd -work work -O0 -2008
vcom ./overflow_counter_tb.vhd -work work -O0 -2008
# vopt +acc work.overflow_counter_tb -o overflow_counter_tb_opt
vsim -msgmode both overflow_counter_tb
do wave.do
run 1000 ns