module logic_handler(clk, reset, right, left, shoot, startGameEn, shipUpdateEn, gridUpdateEn, user_x, user_y, enemy_x, enemy_y, gun_cooldown, grid, ship_health, health_update, current_highscore, alltime_highscore, current_score_update, gameover_signal);
					 
	input clk; // default 50mhz clock
	input reset; // value given from SW[2]
	input right; // right signal from KEY[0]
	input left; // left signal from KEY[3]
	input shoot; // shoot signal from SW[0]
	input startGameEn; // FSM reset signal to reset everything
	input shipUpdateEn; // FSM update signal for ship movement
	input gridUpdateEn; // FSM update signal for shifting shifter bit grid
	input health_update; // 1 bit value to update health.
	input current_score_update; // 1 bit value to update the current score
	input gameover_signal; // 1 bit value to update the gameover score.

	output [3:0] ship_health; // 4 bit value keeping track of user's ship health
	output [7:0] current_highscore; // 8 bit value keeping track of user's current score
	output [7:0] alltime_highscore; // 8 bit value keeping track of the all time highscore
 
	output reg [7:0] user_x; // 8 bit value keeping track of the user's x position on the vga
	input [6:0] user_y; // 7 bit value keeping track of the user's y position on the vga
	output reg [7:0] enemy_x; // 8 bit value keeping track of the enemy's x position on the vga
	input [6:0] enemy_y; // 7 bit value keeping track of the enemy's y position on the vga
	output reg [3:0] gun_cooldown; // 4 bit value keeping trck of the gun's cooldown, overheats when it reaches 4'b1111
	output reg [160*120-1:0] grid; // 2D grid reprsentation for our 160x120 pixel screen, where each grid[y*120+x] represents an active bullet 

	 
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
	shifter_grid sh(
		.shoot(shoot),
		.clock(clk),
		.user_x(user_x),
		.enemy_x(enemy_x),
		.grid(grid),
		.startGameEn(startGameEn)
	);
	
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
		.current_score_update(current_score_update), // for now, we'll set this to 0
		.clk(clk),
		.startGameEn(startGameEn)
	);
	
	//handles logic for user's health
	health_handler h(
		.ship_health(ship_health), 
		.health_update(current_health_update), // for now we'll set this to 0
		.clk(clk),
		.startGameEn(startGameEn)
	);
		
endmodule
