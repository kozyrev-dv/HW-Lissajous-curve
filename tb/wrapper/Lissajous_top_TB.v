module Lissajous_top_TB
(
output reg data_reg  ,
output reg valid_reg
);

reg clk = 0;
reg [20:0] DUT_signal = 0;

Lissaju_top
#(
    .CNT_TO    (32'd250  ),
    .RESOLUTION(9'd50    ),
    .STACK_SIZE(32'd65536)
)
Lissaju_top_inst
(
    .clk_i     (clk               ),
    .dataADC1_i(1'b0              ),
    .dataADC2_i(1'b0              ),
    .dataGEN1_i(DUT_signal[8:0]   ),
    .dataGEN2_i(DUT_signal[17:9]  ),
    .sel_i     (1'b1              ),
    .validADC_i(1'b0              ),
    .validGEN_i(1'b1              ),
    .ready_i   (1'b1              ),
    .sclr_i    (1'b1              ),
    .data_o    (data_o),
    .valid_o   (valid_o)
);

always begin
#5 clk = !clk;
end

always begin
#5 DUT_signal <= DUT_signal + 1'b1;
end

always @(posedge clk) begin
data_reg  <= data_o ;
valid_reg <= valid_o;
end



endmodule
