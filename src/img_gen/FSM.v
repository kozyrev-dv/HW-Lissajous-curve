module FSM
#(
    parameter CNT_TO = 32'd212_559
)

(
    input               clk_i  , 
    input               sclr_i ,
    input               done_i ,
    input               valid  ,
    input               ready_i,
    output reg    [3:0] value_o,
    output reg          w_ena_o,
    output reg          r_ena_o
);

localparam [1:0] IDLE  = 2'b00;
localparam [1:0] READ  = 2'b01;
localparam [1:0] WRITE = 2'b10;

reg       [1:0] state = 0;


reg [31:0] cnt;
reg [31:0] cnt2;


always @(posedge clk_i) begin
    case (state)
	 
        IDLE:
            begin
                if (valid) begin
                    state   <= WRITE;
                end 
            end
            
        WRITE:
            begin
                if (cnt == (CNT_TO - 1) ) begin
                    cnt   <= 0;
                    state <= READ;
                end
                else begin
                    cnt   <= cnt + 1'b1;
                end
            end
            
        READ:
            begin
                if (done_i) begin
                    state <= IDLE;
                end 
            end
        
    endcase
	 
	 if (sclr_i) begin
        state <= IDLE;
	 end
end
    
always @(posedge clk_i) begin
    cnt2    <= 0;
    value_o <= 4'hF;
    
    case (state)
        WRITE:
            begin
                if (value_o == 1'b1) begin
                    value_o <= value_o;
                end
                else if (cnt2 == (CNT_TO >> 4) ) begin
                        cnt2    <= 0;
                        value_o <= value_o - 1'b1;
                end
                else begin
                    cnt2 <= cnt2 + 1'b1;
                end
            end
        
    endcase
	 
	 if (sclr_i) begin
        cnt2 <= 0;
	 end
	 
end

endmodule