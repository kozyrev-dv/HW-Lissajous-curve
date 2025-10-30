module Lissajous_WRAPPER_TB
#(
	parameter RESOLUTION = 9'd10,
	parameter CNT_TO     = 32'd10
)
();

reg clk = 0;

always begin
#5 clk = !clk;
end

Lissajous_WRAPPER
#(
	.RESOLUTION(RESOLUTION),
	.CNT_TO(CNT_TO)
)
Lissajous_WRAPPER_inst
(
	.PIN_P11 (clk),
	.PIN_C10 (0),
	.PIN_C11 (0),
	.PIN_D12 (0),
	.PIN_C12 (0),
	.PIN_A12 (1),
	.KEY0    (1)
);



endmodule
