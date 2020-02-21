module Adjust_vol(
    input clk,
    input up_vol,
    input down_vol,
    output reg [15:0]vol=16'h0000,
    output reg [3:0]vol_class=4'b0000
    );
    wire [15:0]adjusted_vol;
    assign adjusted_vol=vol;
    integer clk_cnt=500000;
    always @(posedge clk) begin
        if(clk_cnt==500000) begin
            if(up_vol) begin
                clk_cnt<=0;
                vol<=(vol==16'h0000)?16'h0000:(vol-16'd13107);
            end
            else if(down_vol) begin
                clk_cnt <= 0;
                vol<=(vol==16'hffff)?16'hffff:(vol+16'd13107);
            end
        end
        else 
            clk_cnt<=clk_cnt+1;
    end
    always @(posedge clk)begin
    if(adjusted_vol==16'hffff)
            vol_class<=4'd0;
         else if(adjusted_vol<16'd65535&&adjusted_vol>=16'd52428)
            vol_class<=4'd1;
         else if(adjusted_vol<16'd52428&&adjusted_vol>=16'd39321)
            vol_class<=4'd2;
         else if(adjusted_vol<16'd39321&&adjusted_vol>=16'd26214)
            vol_class<=4'd3;
         else if(adjusted_vol<16'd16214&&adjusted_vol>=16'd13107)
            vol_class<=4'd4;
         else if(adjusted_vol<16'd13107&&adjusted_vol>=16'd0)
            vol_class<=4'd5;
        end
   endmodule 
