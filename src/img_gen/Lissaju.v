module Lissaju
#(
parameter RESOLUTION = 9'd480,
parameter STACK_SIZE = 32'd230400
)
(
    input           clk_i   ,
    input     [3:0] value_i ,
    input     [8:0] data1_i , // 9 БИт!!!
    input     [8:0] data2_i , // 9 БИт!!!
    input           sclr_i  , // filled || sclr
    input           w_ena_i ,
    input           r_ena_i , // r_ena - это ready
   
    output reg        done_o  ,
    output reg        valid_o ,
    output reg [3:0]  data_o   

);

reg   [3:0] buffer [RESOLUTION-1:0][RESOLUTION-1:0];
reg  [17:0] r_adr_x = 0                            ;
reg  [17:0] r_adr_y = 0                            ;
reg  [17:0] w_adr_x = 0                            ;
reg  [17:0] w_adr_y = 0                            ;

 
// ЗАПОЛНЕНИЕ И СБРОС БУФФЕРА 
always @(posedge clk_i) begin
   
    if (sclr_i) begin
        buffer [r_adr_x][r_adr_y] <= 0;
    end
    else if (r_ena_i) begin
        buffer [r_adr_x][r_adr_y] <= 0;
    end
    else if (w_ena_i) begin
        buffer [w_adr_x][w_adr_y] <= value_i;
    end
    
end

// КОНТРОЛЛЕР АДРЕСА ЗАПИСИ
always @(posedge clk_i) begin
    w_adr_x <= data1_i;
    w_adr_y <= data2_i;
end

always @(posedge clk_i) begin
	if ( (r_adr_x == (RESOLUTION-1) ) && (r_adr_y == (RESOLUTION-1) ) ) begin // если адрес по Х и У равны последнему пикселю по горизонтали и вертикали, то
      done_o <= 1'b1;
   end
	else begin
		done_o <= 0;
	end
	
end
// КОНТРОЛЛЕР АДРЕСА ЧТЕНИЯ
always @(posedge clk_i) begin
    
    if (sclr_i) begin
        r_adr_x <= 0;
        r_adr_y <= 0;
    end
    else if ( (r_adr_x == (RESOLUTION-1) ) && (r_adr_y == (RESOLUTION-1) ) ) begin // если адрес по Х и У равны последнему пикселю по горизонтали и вертикали, то
        r_adr_x <= 0;
        r_adr_y <= 0;
    end
    else if (r_adr_x == (RESOLUTION-1) ) begin
        r_adr_x <= 0;
        r_adr_y <= r_adr_y + 1'b1;
    end
    else if (r_ena_i) begin
        r_adr_x <= r_adr_x + 1'b1;
    end
    
end

// КОНТРОЛЛЕР   
always @(posedge clk_i) begin
    valid_o <= 1'b0;
    
    if (r_ena_i) begin 
        
        data_o  <= buffer [r_adr_x][r_adr_y];
        valid_o <= 1'b1;
    end
end


endmodule
