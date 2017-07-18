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

module starflux (CLOCK_50, KEY, SW, LEDR, 
                 HEX0, HEX1, HEX2, HEX3, HEX4, HEX5,
                 VGA_CLK, VGA_HS, VGA_VS, VGA_BLANK_N,
                 VGA_SYNC_N, VGA_R, VGA_G, VGA_B);

	input CLOCK_50; // Default 50 Mhz clock on De2 board
	input [9:0] SW; // Use SW[0] as firing, SW[1] as pause, SW[2] as reset
	input [3:0] KEY; // use KEY[0:3] as right, down, up, left respectively 
   output [9:0] LEDR; // no use for this yet, may be bonus
   output [6:0] HEX0, HEX1, // Display all time high score on HEX[0:1]
                HEX2, HEX3, // Display current high score on HEX[2:3]
                HEX4, HEX5; // Display gun's cooldown timer on HEX[4:5]

	// Declare your inputs and outputs here
	// Do not change the following outputs
	output VGA_CLK;   				//	VGA Clock
	output VGA_HS;					//	VGA H_SYNC
	output VGA_VS;					//	VGA V_SYNC
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
   wire down  = ~KEY[1]; // tells our game to move our ship down
   wire up    = ~KEY[2]; // tells our game to move our ship up
   wire left  = ~KEY[3]; // tells our game to move our ship left 

   // Game logic related signals, this is where we'll keep a top level overview
	// of the modules required for our games. 
	 
	 
   wire [7:0]ship_health;  // 8 bit value, we're to display lower four bits on 
                           // HEX6, and upper four bits on HEX7
   
	wire [3:0]gun_cooldown; // 8 bit value, we're to display lower four bits on 
                           // HEX4 and upper four bits HEX5

   wire [7:0]current_highscore; // 8 bit value, we're to display on lower four
                                // bits on HEX3 and upper four bits on HEX2
										  
   wire [7:0]alltime_highscore; // 8 bit value, we're to display on lower four
                                // bits on HEX1 and upper four bits on HEX
	
	wire [7:0] user_x, enemy_x; // keeps track of where the use is on the screen
	
	wire [160*120-1:0]grid; // grid we're gonna use for the shifter bit modules


	hex_decoder_always h4(.hex_digit(gun_cooldown[3:0]), .segments(HEX4));

   // Instansiate datapath
   wire shipUpdateEn, gridUpdateEn;
	wire writeEn;
	wire [2:0] colour;
	wire [7:0] x;
	wire [6:0] y;
	 
	 
   // Instansiate FSM control and writing handler
	control C0(
        .clk(CLOCK_50),
        .reset(reset),
		  .shipUpdateEn(shipUpdateEn), gridUpdateEn
		  .writeEn(writeEn)
   );
	 
   datapath d0(
        .clk(CLOCK_50),
        .resetn(resetn),
        .colour_in(SW[9:7]),
        .coord_in(SW[6:0]),
        .ld_x(ld_x), 
        .ld_y(ld_y), 
        .ld_col(ld_col),
        .enable(writeEn),
        .x_out(x),
        .y_out(y),
        .col_out(colour)
   );

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
	

	// Create an Instance of a VGA controller - there can be only one!
	// Define the number of colours as well as the initial background
	// image file (.MIF) for the controller.
	vga_adapter VGA(
			.resetn(resetn),
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
