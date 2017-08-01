module user_movement_handler(clock, right, left, x_val, startGameEn);
	input clock; // 50mhz clock from de2 board
	input right, left; // left, right movement from KEY[3] and KEY[0]
	input startGameEn; // enable signal to reset the user's position
	output reg [7:0] x_val; // output values 
		 
	wire [27:0]rd_16hz_out; 
	rate_divider rd_16hz(
		.enable(1'b1),
		.countdown_start(28'd3_125_000),
		.clock(clock),
		.reset(startGameEn),
		.q(rd_16hz_out)
	);
	 
	wire movement_handler_clock   = (rd_16hz_out == 28'b0) ? 1'b1 : 1'b0;

	always@(posedge movement_handler_clock)
	begin
		if(startGameEn) begin
			x_val <= 8'b0;
		end
		else if(left & right) begin
			x_val <= x_val;
		end
		else if(left) begin
			x_val <= (x_val > 8'd0)  ? x_val - 1'b1 : 8'd0;
		end
		else if(right) begin
			x_val <= (x_val < 8'd160) ? x_val + 1'b1: 8'd160;
		end
	end

endmodule
