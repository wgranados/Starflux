module datapath(clk, reset, right, left, shoot, startGameEn, shipUpdateEn, gridUpdateEn, user_x, enemy_x, gun_cooldown, grid, ship_health, health_update, current_highscore, alltime_highscore, current_score_update, gameover_signal);
					 
    input clk; // default 50mhz clock
    input reset; // value given from KEY[0]
	 input right;
	 input left;
	 input shoot;
	 input startGameEn;
	 input shipUpdateEn;
	 input gridUpdateEn;
	 input health_update; // 1 bit value to update health.
	 input current_score_update; // 1 bit value to update the current score
    input gameover_signal; // 1 bit value to update the gameover score.

	 output [3:0] ship_health;
	 output [7:0] current_highscore;
	 output [7:0] alltime_highscore;
 
	 output reg [7:0] user_x;
	 output reg [7:0] enemy_x;
	 output reg [3:0] gun_cooldown;
	 output reg [160*120-1:0] grid; 

	 
	 // handles logic for  gun cooldown
	 gun_cooldown_handler gc(
	   .clock(clk),
		.shoot(shoot),
		.gun_cooldown_counter(gun_cooldown),
		.startGameEn(startGameEn)
	 );
	
	 // handles logic for moving left and right
	 movement_handler mv(
		  .clock(clk),
		  .right(right),
		  .left(left),
		  .x_val(user_x),
		  .startGameEn(startGameEn)
	 );
	 
	 // handles the logic for moving the enemy
	 enemy enm(
			.clock(clk),
			.x_val(enemy_x), 
			.startGameEn(startGameEn)
	);
	
	// handles the shifter bit logic which keeps
	// track of all the bullets
	//shifter_grid sh(
	//	.shoot(shoot),
	//	.clock(clk),
	//	.user_x(user_x),
	//	.enemy_x(enemy_x),
	//	.grid(grid),
	//	.startGameEn(startGameEn)
	//);
	
	wire current_score_update;
	wire current_health_update;
	
	// handles collision logic for our stuff
	//collision_handler ch(
	//	.grid(grid),
	//   .current_score_update(current_score_update),
	//	.current_health_update(current_health_update),
	//	.user_x(user_x),
	//	.enemy_x(enemy_x)
	//);
	
	// handles logic for all time highscore
	best_score_handler a(
		.current_highscore(current_highscore),	
		.alltime_highscore(alltime_highscore), 
		.clk(Clk),
		.startGameEn(startGameEn)
	);
	
	// handles logic for current highscore
	current_score_handler csh(
		.current_highscore(current_highscore),
		.current_score_update(1'b0), // for now, we'll set this to 0
		.clk(clk),
		.startGameEn(startGameEn)
	);
	
	//handles logic for user's health
	health_handler h(
		.ship_health(ship_health), 
		.health_update(1'b0), // for now we'll set this to 0
		.clk(clk),
		.startGameEn(startGameEn)
	);
		
endmodule
