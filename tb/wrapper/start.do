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
vlog ../../src/img_gen/FSM_counter.v                -work work
vlog ../../src/img_gen/Lissaju.v                    -work work 
vlog ../../src/img_gen/FSM.v                        -work work
vlog ../../src/img_gen/Lissaju_top.v                -work work 
vcom ../../src/img_gen/phase_shifter.vhd            -work work -O0 -2008
vcom ../../src/img_gen/sinus.vhd                    -work work -O0 -2008
vcom ../../src/img_gen/gen_sinus_top.vhd            -work work -O0 -2008
vcom ../../src/basics_p.vhd                         -work work -O0 -2008
vcom ../../src/vga_ctrl/img_buf.vhd                 -work work -O0 -2008
vcom ../../src/vga_ctrl/vga_address_gen.vhd         -work work -O0 -2008
vcom ../../src/vga_ctrl/sync_gen.vhd                -work work -O0 -2008
vcom ../../src/vga_ctrl/overflow_counter.vhd        -work work -O0 -2008
vcom ../../src/vga_ctrl/vga_ctrl.vhd                -work work -O0 -2008
vlog ../../src/img_gen/Lissajous_WRAPPER.v          -work work 
vlog ./Lissajous_WRAPPER_TB.v           -work work



vsim -msgmode both Lissajous_WRAPPER_TB

