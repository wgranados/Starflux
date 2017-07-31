module gameoverDE1SOC(ledr, clk, reset, gameover);
 	output [8:0]ledr;
 	input clk;
	input reset;
	input gameover;
	
	wire [27:0]rd_16hz_out; 
	rate_divider rd_16hz(
			.enable(gameover),
			.countdown_start(28'd3_125_000),
			.clock(clk),
			.reset(reset),
			.q(rd_16hz_out)
	);
	
	wire led_out_clock   = (rd_16hz_out == 28'b0) ? 1'b1 : 1'b0;
	reg [8:0] redout;

		
 	always@(posedge led_out_clock) begin
 		if(gameover) begin
 			case (redout)
 				9'b0:
 				begin
 					redout <= 9'b101010101;
   			end
 				9'b101010101:
 				begin
 					redout <= 9'b100010001;
 				end
 				9'b100010001:
 				begin
 					redout <= 9'b100000001;
 				end
 				9'b100000001:
 				begin
 					redout <= 9'b0;
 				end
 				default: 
 				begin 
 					redout <= 9'b0;
 				end
 			endcase
 		end
		if(reset) begin
			redout <= 9'b0;
		end
 	end
 	assign ledr[8:0] = redout[8:0];
	
 endmodule
