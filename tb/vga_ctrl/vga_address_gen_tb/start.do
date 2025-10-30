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
vcom ../../../src/vga_ctrl/vga_address_gen.vhd -work work -O0 -2008
vcom ./vga_address_gen_tb.vhd -work work -O0 -2008
vsim -msgmode both vga_address_gen_tb
do wave.do
run 10000 ns