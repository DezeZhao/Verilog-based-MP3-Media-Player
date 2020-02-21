module Switch_music(
       input clk,
       input prev,
       input next,
       output reg [2:0]current=0
       );
       parameter SONG_NUM=5;
       integer clk_cnt=400000;
       always @(posedge clk) begin
           if(clk_cnt>=400000) begin
               if(prev) begin
                   clk_cnt<=0;
                   current<=current-3'b001;
                   if(current==3'b000)
                   current<=SONG_NUM-1;
               end
               else if(next) begin
                   clk_cnt<=0;
                   current<=current+3'b001;
                   if(current==SONG_NUM-1)
                   current<=0;
               end
           end
           else 
               clk_cnt<=clk_cnt+1;
       end
   endmodule
   