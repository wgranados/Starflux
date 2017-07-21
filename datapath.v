module datapath(clk, reset, right, left, shoot, shipUpdateEn, gridUpdateEn, user_x, enemy_x, gun_cooldown, grid);
					 
    input clk; // default 50mhz clock
    input reset; // value given from KEY[0]
	 input shipUpdateEn;
	 input gridUpdateEn;
	 input right;
	 input left;
	 input shoot;

	 output reg [7:0] user_x;
	 output reg [7:0] enemy_x;
	 output reg [3:0] gun_cooldown;
	 output reg [160*120-1:0] grid; 

	 
	 // handles logic for  gun cooldown
	 gun_cooldown_handler gc(
	   .clock(clk),
		.shoot(shoot),
		.reset(reset),
		.gun_cooldown_counter(gun_cooldown)
	 );
	
	 // handles logic for moving left and right
	 movement_handler mv(
		  .clock(clk),
		  .right(right),
		  .left(left),
		  .x_val(user_x)
	 );
	 
	 // handles the logic for moving the enemy
	 enemy enm(
			.clock(clk),
			.x_val(enemy_x), 
			.reset(reset)
	);
	
	//shifter_grid sh(
		//.reset(reset), 
		//.shoot(shoot), 
		//.clock(clk),
		//.user_x(user_x),
		//.enemy_x(enemy_x), 
		//.grid(grid)
	//);


   

endmodule
