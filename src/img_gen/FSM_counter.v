module counter
#(
	parameter CNT_TO = 32'd212_559
)
(
	input      			clk_i  ,  
	input      			ena_i  ,
	input 				draw_pix_i, 
	 
	output reg 			imp_o  ,
	output reg [3:0]	value_o = 4'hF
);

reg [31:0] cnt;
reg [31:0] cnt2;

always @(posedge clk_i) begin
	cnt   <= 0;
	imp_o <= 0;
	
	if (cnt == (CNT_TO - 1) ) begin
		cnt   <= 0;
		imp_o <= 1'b1;
	end
	else if (ena_i) begin
		cnt   <= cnt + 1'b1;
		imp_o <= 0;
	end

end



always @(posedge clk_i) begin
	
	if (ena_i) begin
		if (draw_pix_i) begin
			cnt2 <= cnt2 + 1'b1;
			if (cnt2 == 2 - 1) begin
				cnt2 <= 0;
				if (value_o == 4'b0000) begin
					value_o <= value_o;
				end else begin 
					value_o <= value_o - 1'b1;
				end
			end
		end;
	end else begin
		cnt2    <= 0;
		value_o <= 4'hF;
	end
	
end

endmodule 