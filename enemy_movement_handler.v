module enemy_movement_handler(clock, x_val, startGameEn);
    input clock; // 50mhz clock from de2 board
    input startGameEn; // reset signal to reset the game
    output reg [7:0] x_val; // output values


	 wire [27:0]rd_2hz_out; 
	 rate_divider rd_2hz(
			.enable(1'b1),
			.countdown_start(28'd24_99_999), // 24,999,99 in dec
			.clock(clock),
			.reset(reset),
			.q(rd_2hz_out)
	 );
	  
	 wire movement_handler_clock   = (rd_2hz_out == 28'b0) ? 1:0;

	 reg left; // true if the enemy is moving towards left side of the screen

    always@(posedge movement_handler_clock)
    begin
		if(startGameEn)begin // If the reset button is clicked then reset the x value and make it go right
				x_val <= 8'b0;
				left <= 1'b0;
		end
      else if(!left) begin
		    	x_val <= x_val + 1'b1;
		    	if(x_val == 8'd160)begin // change direction once we hit the right boundary
					left = 1'b1; 
				end		
		end
      else if(left)begin
				x_val <= x_val - 1'b1; 
				if(x_val == 8'b0)begin // change direction once we hit the left boundary
					left = 1'b0;
				end
		end
	end
endmodule



