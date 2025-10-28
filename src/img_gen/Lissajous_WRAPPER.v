module Lissajous_WRAPPER
(
    input           PIN_P11, //MAX10_CLK1_50
    input           PIN_C10, //SW0
    input           PIN_C11, //SW1
    input           PIN_D12, //SW2
    input           PIN_C12, //SW3
    input           PIN_A12, //SW4
    input           KEY0     //aclr button
);

wire    [3:0]   SW_value;
wire    [8:0]   data_gen1;
wire    [8:0]   data_gen2;
wire            valid_gen;

assign SW_value = {PIN_C10, PIN_C11, PIN_D12, PIN_C12};


Lissaju_top
Lissaju_top_inst
(
    .clk_i      (clk_i),
    .dataADC1_i (0),
    .dataADC2_i (0),
    .dataGEN1_i (data_gen1),
    .dataGEN2_i (data_gen2),
    .full_img_i (0),
    .sel_i      (PIN_A12  ), 
    .validADC_i (0),
    .validGEN_i (valid_gen),
    .ready_i    (0),
    .sclr_i     (KEY0),
);

gen_sinus_top
gen_sinus_top_inst
(
    .clk            (clk_i    ),
    .rst            (KEY0     ),
    .phase_shift_val(SW_value ),
    .data_a         (data_gen1),
    .data_b         (data_gen2),
    .data_valid     (valid_gen)
);

endmodule