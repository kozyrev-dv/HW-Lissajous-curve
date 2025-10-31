module FSM
#(
	parameter CNT_TO
)

(
	input		   		clk_i  		, 
	input		   		sclr_i 		,
	input       		done_i	,
   input	 	   		valid  		,
	input	      		ready_i		,
	output     [3:0]  value_o	   ,
   output reg  		w_ena_o		,
   output reg  		r_ena_o
);

localparam [1:0] IDLE  = 2'b00;
localparam [1:0] READ  = 2'b01;
localparam [1:0] WRITE = 2'b10;

reg		  [1:0] state = 0;
reg		  [1:0] NextState = 0;

counter
#(
	.CNT_TO (CNT_TO)
)
FSM_WRITE_COUNTER
(
	.clk_i   (clk_i   ),
	.ena_i   (state[1]),
	.value_o (value_o ),
	.imp_o   (timeout )
);


always @(posedge clk_i) begin
	state <= NextState;
end

always @(*) begin

	case (state)
	
		IDLE:
			begin
			
				NextState = IDLE;
					
					if (valid) begin
						NextState = WRITE;
					end
			end
			
		WRITE:
			begin
			
				NextState = WRITE;
					
					if (sclr_i) begin
						NextState = IDLE;
					end
					else if (timeout) begin
						NextState = READ;
					end
						
				end
				
			READ:
				begin
				
					NextState = READ;
					
					if (sclr_i || done_i) begin
						NextState = IDLE;
					end
					
				end
				
		default: begin
			NextState = IDLE;
		end
			
	endcase
end

always @(*) begin
	case (state)
		IDLE:
			begin
				w_ena_o = 1'b0;
				r_ena_o = 1'b0;
			end
		
		WRITE:
			begin
				w_ena_o = 1'b0;
				r_ena_o = 1'b0;
				
				if (valid) begin
					w_ena_o = 1'b1;
				end
			
			end
			
		READ:
			begin
				w_ena_o = 1'b0;
				r_ena_o = 1'b0;
				
				if (ready_i) begin
					r_ena_o = 1'b1;
				end
				
			end
			
		default: begin
			w_ena_o = 1'b0;
			r_ena_o = 1'b0;
		end
		
	endcase	
end



endmodule 