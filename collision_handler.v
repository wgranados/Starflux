module collision_handler(grid, clock, current_score_update, current_health_update, user_x, user_y, enemy_x, enemy_y);
	input [160*120-1:0]grid;
	input clock;
	input [7:0] user_x;
	input [6:0] user_y;
	input [7:0] enemy_x;
	input [6:0] enemy_y;
	
	output reg current_score_update;
	output reg current_health_update;
	
	 wire [27:0]rd_2hz_out; 
	 rate_divider rd_2hz(
			.enable(1'b1),
			.countdown_start(28'd1_499_999),
			.clock(clock),
			.reset(reset),
			.q(rd_2hz_out)
	 );
	  
	 wire collision_handler_clock   = (rd_2hz_out == 28'b0) ? 1:0;
	
	
	always@(posedge collision_handler_clock)
	begin
		if(grid[120*enemy_x+enemy_y] == 1'b1)begin
			 current_score_update <= 1'b1;
		end
		else begin
			 current_score_update <= 1'b0;
		end
	
	end
	
endmodule
