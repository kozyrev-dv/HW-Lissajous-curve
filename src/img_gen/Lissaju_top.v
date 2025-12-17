module Lissaju_top
#(
	parameter CNT_TO     = 32'd10000000  ,
//    parameter CNT_TO     = 32'd602933  ,  // Считается как "( (Частота проекта/частота монитора) - STACK_SIZE)"
    parameter RESOLUTION =  9'd256     ,  // Передавать разрешение выводимое на экран
    parameter STACK_SIZE = 32'd65536      // RESOLUTION в квадрате
)
(
    input        clk_i      ,
    input  [8:0] dataADC1_i ,
    input  [8:0] dataADC2_i ,
    input  [8:0] dataGEN1_i ,
    input  [8:0] dataGEN2_i ,
    input        full_img_i , // ДАНЯ, СЮДА ФЛАГ ТОГО, ЧТО У ТЕБЯ ПОЛНЫЙ БУФЕР
    input        sel_i      , // Выбирает между данными АЦП и ген синуса, ДОЛЖЕН БЫТЬ СВИТЧ НА ОТЛАДОЧНОЙ ПЛАТЕ
    input        validADC_i , // подать 1 КОГДА ОБА dataADC1_i и dataADC2_i обновлены
    input        validGEN_i ,
    input        ready_i    , // готовность img buf заграбить данные 
    input        sclr_i     , // глобал sclr
    
    output [3:0] data_o     ,
    output       valid_o      

);

reg        sclr ;
reg        valid;
reg [8:0]  data1;
reg [8:0]  data2;

wire [3:0] value;

always @(posedge clk_i) begin
    if (!sclr_i) begin
        valid <= 0;
    end
    else if (sel_i) begin
        valid <= validGEN_i;
        data1 <= dataGEN1_i;
        data2 <= dataGEN2_i;
    end
    else begin
        valid <= validADC_i;
        data1 <= dataADC1_i;
        data2 <= dataADC2_i;
    end
    
end

always @(posedge clk_i) begin
    sclr <= 0;
    
    if (!sclr_i || full_img_i) begin
        sclr <= 1'b1;
    end
    
end

Lissaju
#(
   .RESOLUTION (RESOLUTION),
   .STACK_SIZE (STACK_SIZE)
)
Lissaju_inst
(
    .clk_i   (clk_i  ),
    .data1_i (data1  ),
    .data2_i (data2  ),
    .value_i (value  ),
    .sclr_i  (sclr   ),
    .w_ena_i (w_ena  ),
    .r_ena_i (r_ena  ),
    .done_o  (done   ),
    .valid_o (valid_o),
    .data_o  (data_o )
);

FSM
#(
    .CNT_TO (CNT_TO)
)
FSM_inst
(
    .clk_i      (clk_i          ),
	 .sclr_i     (sclr           ),
    .valid      (valid          ),
    .ready_i    (ready_i        ),
    .done_i     (done           ),
    .value_o    (value          ),
    .w_ena_o    (w_ena          ),
    .r_ena_o    (r_ena          )
);



endmodule
