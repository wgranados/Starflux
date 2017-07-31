module gameover(ledr, ledg, clk, reset, gameover);
 	output [17:0]ledr;
 	output [8:0] ledg;
 	input clk;
	input reset;
	input gameover;
 	
	
	
	reg [17:0] redout;
 	reg [8:0] greenout;
	
	wire [27:0]rd_16hz_out; 
	rate_divider rd_16hz(
			.enable(gameover),
			.countdown_start(28'd3_125_000),
			.clock(clk),
			.reset(reset),
			.q(rd_16hz_out)
	);
	wire led_out_clock   = (rd_16hz_out == 28'b0) ? 1'b1 : 1'b0;

	
 	always@(posedge led_out_clock) begin
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
		if(reset) begin
			redout <= 18'b0;
			greenout <= 9'b0;
		end
 	end
 	assign ledr[17:0] = redout[17:0];
 	assign ledg[8:0] = greenout[8:0];
 endmodule
