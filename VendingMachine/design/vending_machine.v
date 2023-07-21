`include "vending_machine_def.v"

module vending_machine (

   clk,                     // Clock signal
   reset_n,                  // Reset signal (active-low)

   i_input_coin,            // coin is inserted.
   i_select_item,            // item is selected.
   i_trigger_return,         // change-return is triggered

   o_available_item,         // Sign of the item availability
   o_output_item,            // Sign of the item withdrawal
   o_return_coin,            // Sign of the coin return
   o_current_total
);

   // Ports Declaration
   input clk;
   input reset_n;

   input [`kNumCoins-1:0] i_input_coin;
   input [`kNumItems-1:0] i_select_item;
   input i_trigger_return;

   output reg [`kNumItems-1:0] o_available_item;
   output reg [`kNumItems-1:0] o_output_item;
   output reg [`kReturnCoins-1:0] o_return_coin;
   output reg [`kTotalBits-1:0] o_current_total;

   // Net constant values (prefix kk & CamelCase)
   wire [31:0] kkItemPrice [`kNumItems-1:0];   // Price of each item
   wire [31:0] kkCoinValue [`kNumCoins-1:0];   // Value of each coin
   assign kkItemPrice[0] = 400;
   assign kkItemPrice[1] = 500;
   assign kkItemPrice[2] = 1000;
   assign kkItemPrice[3] = 2000;
   assign kkCoinValue[0] = 100;
   assign kkCoinValue[1] = 500;
   assign kkCoinValue[2] = 1000;

   // Internal states. You may add your own reg variables.
   reg [`kTotalBits-1:0] current_total; 
    
    reg [`kTotalBits-1:0] next_total;
    reg [`kReturnCoins-1:0] next_return_coin;
    reg [`kNumItems-1:0] next_output_item;
   
   // Combinational circuit for the next states
   always @(i_input_coin or i_select_item or i_trigger_return) begin                          
           //determines next_total    
           case(i_input_coin)
               3'b001: begin next_total = current_total + kkCoinValue[0]; end
               3'b010: begin next_total = current_total + kkCoinValue[1]; end
               3'b100: begin next_total = current_total + kkCoinValue[2]; end
           endcase
           case(i_select_item)
               4'b0001: if(current_total>kkItemPrice[0] || current_total==kkItemPrice[0]) begin next_total = current_total - kkItemPrice[0]; end
               4'b0010: if(current_total>kkItemPrice[1] || current_total==kkItemPrice[1]) begin next_total = current_total - kkItemPrice[1]; end
               4'b0100: if(current_total>kkItemPrice[2] || current_total==kkItemPrice[2]) begin next_total = current_total - kkItemPrice[2]; end
               4'b1000: if(current_total>kkItemPrice[3] || current_total==kkItemPrice[3]) begin next_total = current_total - kkItemPrice[3]; end     
           endcase
           
           //determines next_output_item
           case(i_select_item)
                4'b0001: next_output_item = (current_total>kkItemPrice[0]||current_total==kkItemPrice[0]) ? 4'b0001 : 4'b0000;
                4'b0010: next_output_item = (current_total>kkItemPrice[1]||current_total==kkItemPrice[1]) ? 4'b0010 : 4'b0000;
                4'b0100: next_output_item = (current_total>kkItemPrice[2]||current_total==kkItemPrice[2]) ? 4'b0100 : 4'b0000;
                4'b1000: next_output_item = (current_total>kkItemPrice[3]||current_total==kkItemPrice[3]) ? 4'b1000 : 4'b0000;
                default: next_output_item = 4'b0000;
           endcase
           //calculates number of return coins 
           if(i_trigger_return)begin  
                next_return_coin=
                (current_total/kkCoinValue[2])
                +((current_total%kkCoinValue[2])/kkCoinValue[1])
                +(((current_total%kkCoinValue[1])%kkCoinValue[1])/kkCoinValue[0]);
                next_total=0;
            end
            else next_return_coin=0;
      
   end
   // Combinational circuit for the output
   always @(*) begin
      //shows available item depending on the state
        if((current_total>kkItemPrice[3])||(current_total==kkItemPrice[3])) o_available_item=4'b1111;
        else if((current_total>kkItemPrice[2])||(current_total==kkItemPrice[2])) o_available_item=4'b0111;
        else if((current_total>kkItemPrice[1])||(current_total==kkItemPrice[1])) o_available_item=4'b0011;
        else if((current_total>kkItemPrice[0])||(current_total==kkItemPrice[0])) o_available_item=4'b0001;
        else o_available_item=4'b0000;
        //shows current_total
        o_current_total = current_total;
   end

      // Sequential circuit to reset or update the states
   always @(posedge clk) begin
      if (!reset_n) begin
         // TODO: reset all states.
         o_available_item<=0;      
            o_output_item<=0;         
            o_return_coin<=0;         
            o_current_total<=0;
            current_total<=0;
            next_total<=0;
            next_return_coin<=0;
            next_output_item<=0;          
      end
      else begin
         // TODO: update all states.
            current_total<=next_total;
            o_output_item<=next_output_item;  
            o_return_coin<=next_return_coin;                           
      end
   end



endmodule