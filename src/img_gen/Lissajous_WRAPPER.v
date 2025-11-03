module Lissajous_WRAPPER
#(
	parameter RESOLUTION    = 9'd10,
	parameter CNT_TO        = 32'd212_559,
    parameter CLK_FREQ_HZ   = 25_175_000,
    parameter FPS_HZ        = 32'd59
)
(
    input           PIN_P11, //MAX10_CLK1_50
    input           PIN_C10, //SW0
    input           PIN_C11, //SW1
    input           PIN_D12, //SW2
    input           PIN_C12, //SW3
    input           PIN_A12, //SW4
    input           KEY0   , //aclr button
    input           KEY1   , //pause button

    output          PIN_AA1, // r
    output          PIN_V1 , // r
    output          PIN_Y2 , // r
    output          PIN_Y1 , // r
    output          PIN_W1 , // g
    output          PIN_T2 , // g
    output          PIN_R2 , // g
    output          PIN_R1 , // g
    output          PIN_P1 , // b
    output          PIN_T1 , // b
    output          PIN_P4 , // b
    output          PIN_N2 , // b
    output          PIN_N3 , // hsync
    output          PIN_N1   // vsync
);
wire 	        hsync;
wire            vsync;
wire    [3:0]   vga_r;
wire    [3:0]   vga_g;
wire    [3:0]   vga_b;
wire    [3:0]   SW_value;
wire    [3:0]   data_img;
wire    [8:0]   data_gen1;
wire    [8:0]   data_gen2;
wire            valid_gen;
wire ready;
wire valid_img;

assign SW_value = {PIN_C10, PIN_C11, PIN_D12, PIN_C12};

assign PIN_AA1 = vga_r[0];
assign PIN_V1  = vga_r[1];
assign PIN_Y2  = vga_r[2];
assign PIN_Y1  = vga_r[3];

assign PIN_W1  = vga_g[0];
assign PIN_T2  = vga_g[1];
assign PIN_R2  = vga_g[2];
assign PIN_R1  = vga_g[3];

assign PIN_P1  = vga_b[0];
assign PIN_T1  = vga_b[1];
assign PIN_P4  = vga_b[2];
assign PIN_N2  = vga_b[3];

assign PIN_N3  = hsync;
assign PIN_N1  = vsync;

Lissaju_top
#(
	.CNT_TO     (CNT_TO), // КОЛ-ВО ТАКТОВ СБОРА ИНФОРМАЦИИ
	.RESOLUTION (RESOLUTION), // РАЗМЕР СЕТКИ ЭКРАНА
	.STACK_SIZE (1)  // РУДИМЕНТ?
)
Lissaju_top_inst
(
    .clk_i      (PIN_P11),
    .dataADC1_i (0),
    .dataADC2_i (0),
    .dataGEN1_i (data_gen1),
    .dataGEN2_i (data_gen2),
    .full_img_i (~ready),
    .sel_i      (PIN_A12  ), 
    .validADC_i (0),
    .validGEN_i (valid_gen),
    .ready_i    (ready),
    .sclr_i     (KEY0),
    .data_o     (data_img),
    .valid_o    (valid_img)
);

gen_sinus_top
#(
    .CLK_FREQ_HZ    (CLK_FREQ_HZ ),
    .FPS            (FPS_HZ         )
)
gen_sinus_top_inst
(
    .clk            (PIN_P11    ),
    .rst            (KEY0     ),
    .phase_shift_val(SW_value ),
    .data_a         (data_gen1),
    .data_b         (data_gen2),
    .data_valid     (valid_gen)
);

vga_ctrl
#(
    .CLK_FREQ_HZ    (CLK_FREQ_HZ),    
    .DISPLAY_PXL_W  (640),
    .DISPLAY_PXL_H  (480),
    .IMG_PXL_W      (RESOLUTION),
    .IMG_PXL_H      (RESOLUTION),
    .FRONT_PORCH_W  (16),
    .SYNC_PULSE_W   (96),
    .BACK_PORCH_W   (48),
    .FRONT_PORCH_H  (10),
    .SYNC_PULSE_H   (2),
    .BACK_PORCH_H   (33),
    .DISPLAY_FPS_HZ (FPS_HZ)
)
vga_ctrl_inst
(
    .clk         (PIN_P11), 
    .rst_n       (KEY0),     
    .img_i       (data_img),     
    .valid_i     (valid_img && KEY1),     
    .ready_o     (ready),         
    .vga_r_o     (vga_r),     
    .vga_g_o     (vga_g),     
    .vga_b_o     (vga_b),     
    .vga_hsync_o (hsync),         
    .vga_vsync_o (vsync)          
);

endmodule