// BSD 3-Clause License
// 
// Copyright (c) 2017, William Granados, Saskia Tjioe, Venkada Naraisman Prasad
// All rights reserved.
// 
// Redistribution and use in source and binary forms, with or without
// modification, are permitted provided that the following conditions are met:
// 
// * Redistributions of source code must retain the above copyright notice, this
//   list of conditions and the following disclaimer.
// 
// * Redistributions in binary form must reproduce the above copyright notice,
//   this list of conditions and the following disclaimer in the documentation
//   and/or other materials provided with the distribution.
// 
// * Neither the name of the copyright holder nor the names of its
//   contributors may be used to endorse or promote products derived from
//   this software without specific prior written permission.
// 
// THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS"
// AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE
// IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE
// DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT HOLDER OR CONTRIBUTORS BE LIABLE
// FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL
// DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR
// SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER
// CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY,
// OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE
// OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.

module starflux (CLOCK_50, KEY, SW, LEDR, LEDG, 
                 HEX0, HEX1, HEX2, HEX3, HEX4, HEX5,
                 VGA_CLK, VGA_HS, VGA_VS, VGA_BLANK_N,
                 VGA_SYNC_N, VGA_R, VGA_G, VGA_B);

	input CLOCK_50; // Default 50 Mhz clock on De2 board
	input [9:0] SW; // Use SW[0] as firing, SW[1] as pause, SW[2] as reset
	input [3:0] KEY; // use KEY[0:3] as right, down, up, left respectively 
   output [17:0] LEDR; // no use for this yet, may be bonus
	output [8:0] LEDG;
   output [6:0] HEX0, HEX1, // Display all time high score on HEX[0:1]
                HEX2, HEX3, // Display current high score on HEX[2:3]
                HEX4, HEX5; // Display gun's cooldown timer on HEX[4:5]

	// Declare your inputs and outputs here
	// Do not change the following outputs
	output VGA_CLK;   				//	VGA Clock
	output VGA_HS;						//	VGA H_SYNC
	output VGA_VS;						//	VGA V_SYNC
	output VGA_BLANK_N;				//	VGA BLANK
	output VGA_SYNC_N;				//	VGA SYNC
	output [9:0] VGA_R;   			//	VGA Red[9:0]
	output [9:0] VGA_G;	 			//	VGA Green[9:0]
	output [9:0] VGA_B;   			//	VGA Blue[9:0]
	

   // Game related signals, here we will give useful names to the main 
   // signals which will interact with our starflux game

   wire shoot = SW[0]; // tells our game to shoot bullets from our ship
   wire pause = SW[1]; // tells our game to pause our current state
   wire reset = SW[2]; // tells our game to start from the beginning state

   wire right = ~KEY[0]; // tells our game to move our ship right
   wire down  = ~KEY[1]; // tells our healthgame to move our ship down
   wire up    = ~KEY[2]; // tells our game to move our ship up
   wire left  = ~KEY[3]; // tells our game to move our ship left 

   // Game logic related signals, this is where we'll keep a top level overview
	// of the modules required for our games. 
	 
	 
   wire [3:0]ship_health;  // 8 bit value, we're to display lower four bits on 
                           // HEX6, and upper four bits on HEX7
									
	wire [3:0]enemy_health;
   
	wire [3:0]gun_cooldown; // 8 bit value, we're to display lower four bits on 
                           // 4 and upper four bits HEX5

   wire [7:0]current_highscore; // 8 bit value, we're to display on lower four
                                // bits on HEX3 and upper four bits on HEX2
										  
   wire [7:0]alltime_highscore; // 8 bit value, we're to display on lower four
                                // bits on HEX1 and upper four bits on HEX
	
	wire [7:0] user_x, enemy_x; // keeps track of where the user is on the screen
	wire [7:0] x_val_bullet; // keeps track of the x value of enemy's bullet
	wire [7:0] y_val_bullet; // keeps track of the y value of enemy's bullet
	
	wire [160*120-1:0]grid; // grid we're gonna use for the shifter bit modules

   // Instansiate control and datapath variables 
   wire shipUpdateEn, gridUpdateEn;
	wire writeEn; // write enable to plot stuff on VGA screen
	wire [2:0] colour; // 3 bit (R,G,B) value to be displatyed on VGA
	wire [7:0] x; // 8 bit x value because of our screen resolution
	wire [6:0] y; // 7 bit y value because of our screen resolution
	wire health_update; // 1 bit value to update the health
	wire current_score_update; // 1 bit value to update the current score
	wire gameover; // 1 bit value to signal gameover
   // Instansiate FSM control and writing handler
	// which determines when we're going to draw stuff
	// on screen and ours ships and grids
	control C0(
        .clk(CLOCK_50),
        .reset(reset),
		  .shipUpdateEn(shipUpdateEn), 
		  .gridUpdateEn(gridUpdateEn),
		  .writeEn(writeEn)
   );
	 
   //hex h(
		//.ship_health(ship_health), 
	   //.current_highscore(current_highscore), 
		//.alltime_highscore(alltime_highscore), 
		//.resetn(SW[2]), .health_update(health_update), 
		//.current_score_update(current_score_update), 
		//.gameover_signal(gameover), 
		//.CLOCK_50(CLOCK_50), 
		//.LEDG(LEDG), 
	   //.LEDR(LEDR));
		
	enemy(.health(enemy_health), .x_val_bullet(x_val_bullet), .y_val_bullet(y_val_bullet), .CLOCK_50(CLOCK_50), .LEDR(LEDR), .x(8'b0), .resetn(SW[2]));
	// Instatiates datapah which makes changes to
	// our ships and grid, based on the FSM logic from
	// the controller
   datapath d0(
      .clk(CLOCK_50),
      .reset(reset),
		.right(right),
		.left(left),
		.shoot(shoot),
		.shipUpdateEn(shipUpdateEn),
		.gridUpdateEn(gridUpdateEn),
		.user_x(user_x),
		.enemy_x(enemy_x),
		.gun_cooldown(gun_cooldown),
		.grid(grid)
   );

	// handle logic for displaying stuff to our VGA screen
	// in this case we handle logic for our selection of 
	// triplets (X, Y, COLOUR)
	display d1(
		.clk(CLOCK_50),
		.reset(reset),
		.user_x(user_x),
		.enemy_x(enemy_x),
		.grid(grid),
		.x(x),
		.y(y),
		.colour(colour)
	);
	
	// display gun cooldown (0-F) on HEX4
	hex_decoder_always h4(
		.hex_digit(gun_cooldown[3:0]), 
		.segments(HEX4)
	);
	hex_decoder_always h1(
		.hex_digit(alltime_highscore[7:4]), 
		.segments(HEX1)); // displaying it on the hexes.
	hex_decoder_always h0(
		.hex_digit(alltime_highscore[3:0]), 
		.segments(HEX0));
	hex_decoder_always h3(
		.hex_digit(current_highscore[7:4]), 
		.segments(HEX3)); // displaying it on the hexes.
	hex_decoder_always h2(
		.hex_digit(current_highscore[3:0]), 
		.segments(HEX2));
	hex_decoder_always h5(
		.hex_digit(ship_health[3:0]), 
		.segments(HEX5));


	// Create an Instance of a VGA controller - there can be only one!
	// Define the number of colours as well asHEX the initial background
	// image file (.MIF) for the controller.
	vga_adapter VGA(
			.resetn(~reset),
			.clock(CLOCK_50),
			.colour(colour),
			.x(x),
			.y(y),
			.plot(writeEn),
			/* Signals for the DAC to drive the monitor. */
			.VGA_R(VGA_R),
			.VGA_G(VGA_G),
			.VGA_B(VGA_B),
			.VGA_HS(VGA_HS),
			.VGA_VS(VGA_VS),
			.VGA_BLANK(VGA_BLANK_N),
			.VGA_SYNC(VGA_SYNC_N),
			.VGA_CLK(VGA_CLK));
		defparam VGA.RESOLUTION = "160x120";
		defparam VGA.MONOCHROME = "FALSE";
		defparam VGA.BITS_PER_COLOUR_CHANNEL = 1;
		defparam VGA.BACKGROUND_IMAGE = "black.mif";



endmodule
