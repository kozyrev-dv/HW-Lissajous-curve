module Lissaju_TB
#(
	parameter CNT_TO     = 32'd1436267	,  // Считается как "( (Частота проекта/частота монитора) - STACK_SIZE)"
	parameter RESOLUTION	=  8'd480	   ,	// Передавать разрешение выводимое на экран
	parameter STACK_SIZE = 32'd230400    	// RESOLUTION в квадрате
)
();

reg 			clk   = 0;
reg [8:0]	x_adr = 0;
reg [8:0]	y_adr = 1'b1;
reg			r_ena = 0;
reg			w_ena = 0;
reg			sclr  = 0;

Lissaju_top
#(
	.CNT_TO 		(CNT_TO		),
	.RESOLUTION (RESOLUTION	),
	.STACK_SIZE (STACK_SIZE )
)
Lissaju_top_inst
(
	.clk_i		(clk  ),
   .dataADC1_i (x_adr),
	.dataADC2_i (y_adr),
	.dataGEN1_i (0),
	.dataGEN2_i (0),
	.full_img_i (0),
	.sel_i		(0),  
	.validADC_i (w_ena),
	.validGEN_i (0),
	.ready_i    (r_ena),
	.sclr_i     (sclr)
);

always begin
	#5 clk = !clk;
end

always @(posedge clk) begin
	
	x_adr <= x_adr + 2'b1;
	w_ena <= 1'b1;
	r_ena <= 1'b0;
	
	
	if (x_adr == 9'd510) begin
		x_adr <= x_adr;
		w_ena <= 1'b0;
		r_ena <= 1'b1;
	end
	
end

endmodule 