module collision_handler(enem_grid, clock, startGameEn, current_health_update, user_x, user_y, enemy_x, enemy_y);
	input [160*120-1:0]enem_grid;
	input clock;
	input startGameEn;
	input [7:0] user_x;
	input [6:0] user_y;
	input [7:0] enemy_x;
	input [6:0] enemy_y;

	output reg current_health_update;
	
	 wire [27:0]rd_2hz_out; 
	 rate_divider rd_2hz(
			.enable(1'b1),
			.countdown_start(28'd3_125_000),
			.clock(clock),
			.reset(startGameEn),
			.q(rd_2hz_out)
	 );
	  
	 wire collision_handler_clock   = (rd_2hz_out == 28'b0) ? 1:0;
	
	
	always@(posedge collision_handler_clock)
	begin
		// handle collisition for use on enem_grid
		if(enem_grid[120*user_x+user_y] == 1'b1)begin
			 current_health_update <= 1'b1;
		end
		else begin
			 current_health_update <= 1'b0;
		end
	end
	
endmodule
