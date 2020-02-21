module MP3(
input CLK,//系统时钟
input DREQ,//数据请求
output reg XRSET,//硬件复位
output reg XCS,//低电平有效片选输入
output reg XDCS,////数据片选/字节同步
output reg SI,//串行数据输入
output reg SCLK,//SPI时钟
input init,//初始化
input up_vol,
input down_vol,
input prev,
input next,
output [7:0]seg_sel,
output  [6:0]seg_data,
output dot,
output  [3:0]R,
output  [3:0]G,
output  [3:0]B,
output  H_Sync,
output  V_Sync
    );
    parameter  CMD_START=0;//开始写指令
    parameter  WRITE_CMD=1;//将一条指令全部写入
    parameter  DATA_START=2;//开始写数据
    parameter  WRITE_DATA=3;//将一条数据全部写入
    
    parameter  DELAY=4;//延时  
    parameter VOL_CMD_START=5;
    parameter SEND_VOL_CMD=6;
    
    
    wire CLK_1M;//分频1MHz
    Divider #(.N(100))CLKDIV(CLK,CLK_1M);
	assign dot=1;
	wire [15:0]adjusted_vol;
	reg [31:0]volcmd;
	wire [3:0] vol_class;
	Adjust_vol adjvol(
	//input
	.clk(CLK_1M), 
	.up_vol(up_vol),
	.down_vol(down_vol),
	 //output
	.vol(adjusted_vol),
	.vol_class(vol_class)
	); 
	
	wire[2:0]current;
	reg [2:0]pre=0;
  Switch_music sw_music(
	.clk(CLK_1M),
	.prev(prev),
	.next(next),
	.current(current)
	);
  VGA_DISPLAY display(
    .clk(CLK),
    .rst(init),
    .switch(current),
    .R(R),
    .G(G),
    .B(B),
    .H_Sync(H_Sync),
    .V_Sync(V_Sync)
     );
    reg [11:0]addr;
    wire [15:0] Data;
    reg [15:0] _Data;
    blk_mem_gen_0 your_instance_name(.clka(CLK),.ena(1),.addra({current,addr}),.douta(Data));

    reg [95:0]cmd={32'h02000804,32'h020B0000,32'hffffffff};
	Display7(
	.rst(init),
	.clk(CLK_1M),
	.prev(prev),
    .next(next),
	.idata1(vol_class),
	.idata2(current+1),
	.seg_data(seg_data),
	.seg_sel(seg_sel)
	);
    integer status=CMD_START;
    integer cnt=0;//位计数
    integer cmd_cnt=0;//命令计数
    always @(posedge CLK_1M) begin
          pre<=current;
   if(~init || pre!=current) begin
        XCS<=1;
        XDCS<=1;
        XRSET<=0;
        cmd_cnt<=0;
        status<=DELAY;
        SCLK<=0;
        cnt<=0;
        addr<=0;
    end
    else begin
        case(status)
        CMD_START:begin
            SCLK<=0;
            if(cmd_cnt>=3)
                status<=DATA_START;
            else if(DREQ) begin
                XCS<=0;
                status<=WRITE_CMD;  
                SI<=cmd[95];
                cmd<={cmd[94:0],cmd[95]}; 
                cnt<=1;
            end
        end
        
      WRITE_CMD:begin
            if(DREQ) begin
                if(SCLK) begin
                    if(cnt>=32)begin
                        XCS<=1;
                         cnt<=0;
                        cmd_cnt<=cmd_cnt+1;
                        status<=CMD_START;
                    end
                    else begin
                       SI<=cmd[95];
                       cmd<={cmd[94:0],cmd[95]}; 
                       cnt<=cnt+1; 
                    end
                end
                SCLK<=~SCLK;
            end
        end
        
        DATA_START:begin
		if(adjusted_vol[15:0]!=cmd[47:32])begin//音量变了
		    cnt<=0;
		    volcmd<={16'h020B,adjusted_vol}; 
			status<=VOL_CMD_START;
	    end
        else if(DREQ) begin
                XDCS<=0;
                SCLK<=0;
                SI<=Data[15];
                _Data<={Data[14:0],Data[15]};
                cnt<=1;    
                status<=WRITE_DATA;  
            end
           cmd[47:32]<=adjusted_vol;
        end
        
        WRITE_DATA:begin  
            if(SCLK)begin
                if(cnt>=16)begin
                    XDCS<=1;
                    addr<=addr+1;
                    status<=DATA_START;
                end
                else begin
                  cnt<=cnt+1;
                  _Data<={_Data[14:0],_Data[15]};
                   SI<=_Data[15];
                end
            end
            SCLK<=~SCLK;
        end
  	  
  	    DELAY:begin
                   if(cnt<1000)
                       cnt<=cnt+1;
                   else begin
                       cnt<=0;
                       status<=CMD_START;
                       XRSET<=1;
                   end
               end
		
		VOL_CMD_START:begin
	    if(DREQ) begin
	            XCS<=0;  
	            status<=SEND_VOL_CMD;  
	            SI<=volcmd[31];
	            volcmd<={volcmd[30:0],volcmd[31]}; 
	            cnt<=1;
	        end
	    end
		
		SEND_VOL_CMD:begin
		  if(DREQ) begin
		         if(SCLK) begin
		            if(cnt<32)begin
		                SI<=volcmd[31];
		               volcmd<={volcmd[30:0],volcmd[31]}; 
		               cnt<=cnt+1; 
		            end
		            else begin 
					    XCS<=1;
		                 cnt<=0;
		                 status<=DATA_START;
		              
		            end
		        end
		        SCLK<=~SCLK;
		    end
		end
		default:;
        endcase
    end
end
endmodule