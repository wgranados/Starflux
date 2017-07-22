module collision_handler(grid, current_score_update, current_health_update, user_x, user_y, enemy_x, enemy_y);
	input [160*120-1:0]grid;
	output current_score_update;
	output current_health_update;
	input [7:0] user_x;
	input [7:0] user_y;
	input [7:0] enemy_x;
	input [7:0] enemy_y;
	
	
	wire [160:0]collision;
	
	// unwrap the portion of the grid we're interested in
	genvar i;	
	generate

		for(i = 0;i < 160;i = i+1) begin: shifter_grid_endpoints
			 assign collision[i] = grid[120*i];
		end
	
	endgenerate
	
	assign current_score_update = collision[user_x];
	assign current_health_update = collision[user_x];
	

	
endmodule
