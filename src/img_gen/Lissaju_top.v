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

wire w_ena;
wire r_ena;
wire done;

reg        sclr ;
reg        valid;
reg [8:0]  data1;
reg [8:0]  data2;
reg [8:0]   data1_T_start;
reg [8:0]   data2_T_start;

reg         is_period_written = 1'b0;
reg [1:0]   fsm_state;
wire [1:0]   fsm_next_state;

wire [3:0] value;

always @(posedge clk_i) begin
    if (!sclr_i) begin
        fsm_state <= 2'b0;
    end else begin
        fsm_state <= fsm_next_state;
    end
end


always @(posedge clk_i) begin
    if (!sclr_i) begin
        valid <= 0;
        data1 <= 4'b0000;
        data2 <= 4'b0000;
        data1_T_start <= 4'b0000;
        data2_T_start <= 4'b0000;
        is_period_written <= 1'b0;
    end else if (sel_i) begin
        if (fsm_state == 2'b00 && fsm_next_state == 2'b10) begin // if starting to write
            data1_T_start <= dataGEN1_i;
            data2_T_start <= dataGEN2_i;
            is_period_written <= 1'b0;
        end else begin
            data1_T_start <= data1_T_start;
            data2_T_start <= data2_T_start;
            if (data1_T_start == dataGEN1_i && data2_T_start == dataGEN2_i && validGEN_i) begin
                is_period_written <= 1'b1;
            end
        end
        valid <= validGEN_i;
        data1 <= dataGEN1_i;
        data2 <= dataGEN2_i;
    end else begin
        if (fsm_state == 2'b00 && fsm_next_state == 2'b10) begin // if starting to write
            data1_T_start <= dataADC1_i;
            data2_T_start <= dataADC2_i;
            is_period_written <= 1'b0;
        end else begin
            data1_T_start <= data1_T_start;
            data2_T_start <= data2_T_start;
            if (data1_T_start == dataADC1_i && data2_T_start == dataADC2_i && validADC_i) begin
                is_period_written <= 1'b1;
            end
        end
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
    .w_ena_i (w_ena  && (~is_period_written)),
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
    .next_state_o   (fsm_next_state ),
    .w_ena_o    (w_ena          ),
    .r_ena_o    (r_ena          )
);



endmodule
