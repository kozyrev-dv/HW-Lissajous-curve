module Lissajous_WRAPPER_TB
();

reg	clk_i = 0;

reg     PIN_P11 = 0; //MAX10_CLK1_50
reg     PIN_C10 = 0; //SW0
reg     PIN_C11 = 0; //SW1
reg     PIN_D12 = 0; //SW2
reg     PIN_C12 = 0; //SW3
reg     PIN_A12 = 0; //SW4
reg     KEY0    = 0; //aclr button

Lissajous_WRAPPER
Lissajous_WRAPPER_inst
(
    .PIN_P11    (PIN_P11),
    .PIN_C10    (PIN_C10),
    .PIN_C11    (PIN_C11),
    .PIN_D12    (PIN_D12),
    .PIN_C12    (PIN_C12),
    .PIN_A12    (PIN_A12),
    .KEY0       (KEY0   )
);

always begin
    #5 PIN_P11 = !PIN_P11;
end

//---------------------------------------------------------------------------------------
// TESTBENCH REGISTERS
//---------------------------------------------------------------------------------------

reg     [15:0] cnt0 = 0;
reg     [3:0] cnt1 = 0;

always @(posedge clk_i) begin
    cnt <= cnt + 1'b1;
    
    if (cnt0 == 15'd1275) begin
        cnt1 <= cnt1 + 1'b1;
        cnt0 <= 0;
    end
end

always @(posedge clk_i) begin
    case (cnt1)
        4'd0:
            begin
                PIN_C10 <= 0;
                PIN_C11 <= 0;
                PIN_D12 <= 0;
                PIN_C12 <= 0;
            end
            
        4'd1:
            begin
                PIN_C10 <= 1'b1;
                PIN_C11 <= 0;
                PIN_D12 <= 0;
                PIN_C12 <= 0;
            end
        4'd2:
            begin
                PIN_C10 <= 0;
                PIN_C11 <= 1'b1;
                PIN_D12 <= 0;
                PIN_C12 <= 0;
            end
            
        4'd3:
            begin
                PIN_C10 <= 0;
                PIN_C11 <= 0;
                PIN_D12 <= 1'b1;
                PIN_C12 <= 0;
            end
            
        4'd4:
            begin
                PIN_C10 <= 0;
                PIN_C11 <= 0;
                PIN_D12 <= 0;
                PIN_C12 <= 1'b1;
            end
    endcase
    
        PIN_C10 = 0;
        PIN_C11 = 0;
        PIN_D12 = 0;
        PIN_C12 = 0;
    end
    
end


endmodule

// 1275 = 255*5