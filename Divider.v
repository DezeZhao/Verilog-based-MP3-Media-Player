module Divider #(parameter N=10000)
   (
   input  I_CLK,
   output reg O_CLK_1M
   );
        integer  i=0;
        always@(posedge I_CLK)
        begin
        if(i==N/2-1) begin
           O_CLK_1M<=~O_CLK_1M;
           i<=0;
        end
        else
           i<=i+1;
        end         
   endmodule 