module logic_handler(clk, reset, right, left, shoot, startGameEn, shipUpdateEn, gridUpdateEn, user_x, user_y, enemy_x, enemy_y, gun_cooldown, enem_grid, ship_health, current_highscore, alltime_highscore);
					 
	input clk; // default 50mhz clock
	input reset; // value given from SW[2]
	input right; // right signal from KEY[0]
	input left; // left signal from KEY[3]
	input shoot; // shoot signal from SW[0]
	
	input startGameEn; // FSM reset signal to reset everything
	input shipUpdateEn; // FSM update signal for ship movement
	input gridUpdateEn; // FSM update signal for shifting shifter bit grid

	output [3:0] ship_health; // 4 bit value keeping track of user's ship health
	output [7:0] current_highscore; // 8 bit value keeping track of user's current score
	output [7:0] alltime_highscore; // 8 bit value keeping track of the all time highscore
 
	output reg [7:0] user_x; // 8 bit value keeping track of the user's x position on the vga
	input [6:0] user_y; // 7 bit value keeping track of the user's y position on the vga
	
	output reg [7:0] enemy_x; // 8 bit value keeping track of the enemy's x position on the vga
	input [6:0] enemy_y; // 7 bit value keeping track of the enemy's y position on the vga
	
	output reg [3:0] gun_cooldown; // 4 bit value keeping trck of the gun's cooldown, overheats when it reaches 4'b1111
	output reg [160*120-1:0] enem_grid; // 2D grid reprsentation for our 160x120 pixel screen, where each grid[y*120+x] represents an active bullet
   
	wire enemy_shoot; // shoot signal sent from the enemy, behaviour is specified in enemy_gun_handler

	// determines when enemy_shoot is set to high or low
	enemy_gun_handler gun(
		.clock(clk),
		.gun_cooldown(gun_cooldown),  
		.startGameEn(startGameEn),
		.enemy_shoot(enemy_shoot)
	);
	 
	// handles logic for gun cooldown
	gun_cooldown_handler gc(
		.clock(clk),
		.shoot(enemy_shoot),
		.gun_cooldown_counter(gun_cooldown),
		.startGameEn(startGameEn)
	);
	 
	// handles logic for moving left and right
	user_movement_handler user_mv(
		.clock(clk),
		.right(right),
		.left(left),
		.x_val(user_x),
		.startGameEn(startGameEn)
	);
	 
	// handles the logic for moving the enemy
	enemy_movement_handler enemy_mv(
		.clock(clk),
		.x_val(enemy_x), 
		.startGameEn(startGameEn)
	);
	
	// handles the shifter bit logic which keeps
	// track of all the bullets
	shifter_grid sh_enem(
		.shoot(enemy_shoot),
		.clock(clk),
		.user_x(enemy_x),
		.grid(enem_grid),
		.gridUpdateEn(gridUpdateEn),
		.startGameEn(startGameEn)
	);

	wire current_score_update;
	wire current_health_update;
	
	// Update the score continously every 0.5s
	wire [27:0]rd_2hz_out; 
	rate_divider rd_2hz(
		.enable(1'b1),
		.countdown_start(28'd24_999_999),
		.clock(clk),
		.reset(startGameEn),
		.q(rd_2hz_out)
	);
  
	assign current_score_update = (rd_2hz_out == 28'b0) ? 1'b1 : 1'b0;

	// handles collision logic for our stuff
	collision_handler ch(
		.clock(clk),
		.current_health_update(current_health_update),
		.user_x(user_x),
		.user_y(user_y),
		.enemy_x(enemy_x),
		.enemy_y(enemy_y),
		.enem_grid(enem_grid)
	);


	// handles logic for current highscore
	current_score_handler csh(
		.current_highscore(current_highscore),
		.current_score_update(current_score_update),
		.clk(clk),
		.startGameEn(startGameEn)
	);
	
	// handles logic for all time highscore
	best_score_handler bsh(
		.current_highscore(current_highscore),	
		.alltime_highscore(alltime_highscore), 
		.clk(clk),
		.startGameEn(startGameEn)
	);
	
	//handles logic for user's health
	health_handler h(
		.ship_health(ship_health), 
		.health_update(current_health_update),
		.clk(clk),
		.startGameEn(startGameEn)
	);
		
endmodule
