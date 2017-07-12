// This Verilog file handles the movements of the ship.
// The ship is able to move left and right.

// Made by: Saskia Tjioe, William Granados, Venkada Prasad

// ----------------------------------------------------------------------------
include starflux.v;

// This module makes the ship and displays it to the VGA screen
module ship(CLOCK_50,
            KEY,
            SW,
            VGA_CLK,
            VGA_HS,
            VGA_VS,
            VGA_BLANK_N,
            VGA_SYNC_N,
            VGA_R,   						//	VGA Red[9:0]
            VGA_G,	 						//	VGA Green[9:0]
            VGA_B);

  input	CLOCK_50;				//	50 MHz
  input [9:0]SW;
  input [3:0]KEY;

  // Declare your inputs and outputs here
  // Do not change the following outputs
  output VGA_CLK;   				//	VGA Clock
  output VGA_HS;					//	VGA H_SYNC
  output VGA_VS;					//	VGA V_SYNC
  output VGA_BLANK_N;				//	VGA BLANK
  output VGA_SYNC_N;				//	VGA SYNC
  output [9:0]VGA_R;   				//	VGA Red[9:0]
  output [9:0]VGA_G;	 				//	VGA Green[9:0]
  output [9:0]VGA_B;   				//	VGA Blue[9:0]

  // call the VGA
  starflux ship(
    .CLOCK_50(CLOCK_50),
    .KEY(KEY),
    .SW(SW),
    .VGA_CLK(VGA_CLK),
    .VGA_HS(VGA_HS),
    .VGA_VS(VGA_VS),
    .VGA_BLANK_N(VGA_BLANK_N),
    .VGA_SYNC_N(VGA_SYNC_N),
    .VGA_R(VGA_R),   						//	VGA Red[9:0]
    .VGA_G(VGA_G),	 						//	VGA Green[9:0]
    .VGA_B(VGA_B));

endmodule

// ----------------------------------------------------------------------------

// This module allows the ship to move left and right.
module draw_ship(left_key, right_key, colour, clk, reset);
  input left_key; // KEY[3] is used to move left
  input right_key; // KEY[0] is used to move right
  input clk;
  input reset;

  // create an always block that will allow the ship to move left and right


endmodule
