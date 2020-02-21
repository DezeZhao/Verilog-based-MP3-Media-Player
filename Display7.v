module Display7
(
input rst,
input clk,
input prev,
input next,
input [3:0]idata1, 
input [3:0]idata2,
output reg[6:0]seg_data, // seven segments LED output
output reg[7:0]seg_sel
);
parameter SEC_SCAN_FREQ=1000000;//一秒扫描频率
reg [19:0]scan_time_cnt;//扫描计数
reg [3:0]sec_tens_digit=0;//秒的十位数
reg [3:0]sec_ones_digit=0;//秒的个位数
reg [3:0]min_ones_digit=0;//分的个位数
reg [3:0]min_tens_digit=0;//分的十位数
reg [15:0]cnt=0;
reg [3:0]idata;
always@(posedge clk)begin
   if(~rst)begin
	 cnt<=0;
	 end
	else begin
	cnt<=cnt+1;
	if(cnt==16'd10000)
	   cnt<=0;
   end
end
always@(posedge clk)begin
    if(~rst||prev || next)begin
        sec_tens_digit=0;
        sec_ones_digit=0;
        min_ones_digit=0;
        min_tens_digit=0;
       scan_time_cnt<=0;
      end
    else begin
      if(scan_time_cnt==SEC_SCAN_FREQ)begin
        scan_time_cnt<=0;
        sec_ones_digit<=sec_ones_digit+4'd1;
        if(sec_ones_digit==4'd9)begin
         sec_ones_digit<=0;
         sec_tens_digit<=sec_tens_digit+1;
         if(sec_tens_digit==4'd5)begin
            min_ones_digit<=min_ones_digit+1;
            sec_tens_digit<=0;
         end
      end
   end
   else 
      scan_time_cnt<=scan_time_cnt+1;
     end
 end
always@(*) begin
	 if(~rst)begin
	     seg_data<=7'b1111111;
	     seg_sel<=8'b11111111;
	     end
	 else begin
	     if(cnt<=16'd1000)begin
		 seg_sel<=8'b11111110;
		 idata<=idata1;
		 end
		 else if(cnt<=16'd2000)begin
		 seg_sel<=8'b11111011;
		 idata<=idata2;
		 end
		 else if(cnt<=16'd4000)begin
		 idata<=sec_ones_digit;
		 seg_sel<=8'b11101111;
		 end
		 else if(cnt<=16'd6000)begin
		 seg_sel<=8'b11011111;
		 idata<=sec_tens_digit;
		 end
		 else if(cnt<=16'd8000)begin
		 idata<=min_ones_digit;
		 seg_sel<=8'b10111111;
		 end
		 else if(cnt<16'd10000)begin
		 seg_sel<=8'b01111111;
		 idata<=min_tens_digit;
	   end 
     end
	 	 case(idata)
	 		4'd0:seg_data <= 7'b1000000;
	 		4'd1:seg_data <= 7'b1111001;
	 		4'd2:seg_data <= 7'b0100100;
	 		4'd3:seg_data <= 7'b0110000;
	 		4'd4:seg_data <= 7'b0011001;
	 		4'd5:seg_data <= 7'b0010010;
	 		4'd6:seg_data <= 7'b0000010;
	 		4'd7:seg_data <= 7'b1111000;
	 		4'd8:seg_data <= 7'b0000000;
	 		4'd9:seg_data <= 7'b0010000;
	 		default:seg_data <= 7'b1111111;
	 	endcase
	 end
endmodule