`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2019/01/04 16:35:33
// Design Name: 
// Module Name: VGA
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: 
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////
module VGA_DISPLAY(
input clk,rst,
input [3:0]switch,
output [3:0]R,
output [3:0]G,
output [3:0]B,
output H_Sync,V_Sync);
wire [9:0]x_cnt,y_cnt;
wire clk_25M;
 //分频 
Divider #(.N(4))CLKD(clk,clk_25M);
  //生成VGA扫描信号 
 VGA_Sync vga_sync(.clk(clk_25M),.rst(rst),.x_cnt(x_cnt),.y_cnt(y_cnt),.H_Sync(H_Sync),.V_Sync(V_Sync));
  //显示图像 
  VGA__RGB vga_rgb(.clk(clk_25M),.x_cnt(x_cnt),.y_cnt(y_cnt),.R(R),.G(G),.B(B),.switch(switch));
endmodule

module VGA_Sync(
input clk,rst,
output reg[9:0]x_cnt,
output reg[9:0]y_cnt,
output reg H_Sync,V_Sync);
 parameter H_SYNC_END   = 96;     //行同步脉冲结束时间
 parameter V_SYNC_END   = 2;      //列同步脉冲结束时间
 parameter H_SYNC_TOTAL = 800;    //行扫描总像素单位
 parameter V_SYNC_TOTAL = 525;    //列扫描总像素单位
 parameter H_SHOW_START = 144;    //显示区行开始像素点
 parameter V_SHOW_START = 35;     //显示区列开始像素点
always@(posedge clk or negedge rst)begin//行扫描
   if(!rst)
     y_cnt<='d0;
   else if(y_cnt==H_SYNC_TOTAL)
     y_cnt<='d0;
   else
     y_cnt=y_cnt+1'b1;
    end
always@(posedge clk or negedge rst)begin//列扫描
   if(!rst)
    x_cnt<='d0;
   else if(x_cnt==V_SYNC_TOTAL)
    x_cnt<='d0;
   else if(y_cnt==H_SYNC_TOTAL)
    x_cnt<=x_cnt+1'b1;
   else
    x_cnt<=x_cnt; 
end
always@(posedge clk or negedge rst)begin//当行扫描计数器扫描完行同步脉冲后置高H_Sync信号
   if(!rst)
    H_Sync<='d0;
   else if(y_cnt==0)
    H_Sync<=1'b0;
    else if(y_cnt==H_SYNC_END)
    H_Sync<=1'b1;
    else
    H_Sync<=H_Sync;
end
always@(posedge clk or negedge rst)begin//当列扫描计数器扫描完列同步脉冲后置高V_Sync信号
   if(!rst) 
     V_Sync<= 'd0;
   else if (x_cnt == 'd0)
    V_Sync <= 1'b0;
   else if (x_cnt == V_SYNC_END)
    V_Sync <= 1'b1;
   else  
    V_Sync <= V_Sync;   
 end   
endmodule

module VGA__RGB(
input clk,
input [9:0]x_cnt,
input [9:0]y_cnt,
output reg[3:0]R,G,B,
input [3:0]switch
);
wire [15:0]data1;
wire [15:0]data2;
wire [15:0]data3;
reg  [15:0]addr1=16'b0;
reg  [15:0]addr2=16'b0;
reg  [15:0]addr3=16'b0;

blk_mem_gen_1 p1(
  .clka(clk),    // input wire clka    // input wire ena
  .addra(addr1),  // input wire [17 : 0] addra
  .douta(data1)  // output wire [11 : 0] douta
);
blk_mem_gen_2   p2(
  .clka(clk),    // input wire clka     // input wire ena
  .addra(addr2),  // input wire [17 : 0] addra
  .douta(data2)  // output wire [11 : 0] douta
);
blk_mem_gen_3 p3(
  .clka(clk),   
   .ena(1),  // input wire clka    // input wire ena
  .addra(addr3),  // input wire [15 : 0] addra
  .douta(data3)  // output wire [11 : 0] douta
);
 always @ (posedge clk)begin
 if((y_cnt>=10'd0&&y_cnt<=10'd300)&&(x_cnt>=10'd0&x_cnt<=10'd200))
 begin
if(switch==4'd0)begin
R<=data1[15:12];
G<=data1[10:7];
B<=data1[4:1];
addr1<=(x_cnt)*10'd300+y_cnt;
end
if(switch==4'd1)begin
R<=data2[15:12];
G<=data2[10:7];
B<=data2[4:1];
addr2<=(x_cnt)*10'd300+y_cnt;
end
if(switch==4'd2)begin
addr3<=(x_cnt)*10'd300+y_cnt;
R<=data3[15:12];
G<=data3[10:7];
B<=data3[4:1];
end
end
 else
 begin
 R<=4'b1111;
 G<=4'b1111;
 B<=4'b1111;
 end
 end
 endmodule
