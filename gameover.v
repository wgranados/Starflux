module gameover(ledr, ledg, clk, gameover);
 	output [17:0]ledr;
 	output [8:0] ledg;
 	input clk;
	input gameover;
 	reg [17:0] redout;
 	reg [8:0] greenout;
 	always@(posedge clk) begin
 		if(gameover) begin
 			case (redout)
 				18'b0:
 				begin
   				redout <= 18'b101010101010101010;
 					greenout <= 9'b101010101;
   			end
 				18'b101010101010101010:
 				begin
 					redout <= 18'b100010001000100010;
 					greenout <= 9'b100010001;
 				end
 				18'b100010001000100010:
 				begin
 					redout <= 18'b100000001000000010;
 					greenout <= 9'b100000001;
 				end
 				18'b10000000100000001:
 				begin
 					redout <= 18'b0;
 					greenout <= 9'b0;
 				end
 				default: 
 				begin 
 					redout <= 18'b0;
 					greenout <= 9'b0;
 				end
 			endcase
 		end
 	end
 	assign ledr = redout;
 	assign ledg = greenout;
 endmodule
