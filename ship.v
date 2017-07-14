// CSCB58 - Display
// This file displays the text from the the font_Rom to the screen
// It will also display the ship when the player starts the game.(FSM)

// This is based off of this code:
// https://github.com/bogini/Pong/blob/master/pong_text.v

// Made by: Saskia Tjioe, William Granados, and Venkada Prasad

// ----------------------------------------------------------------------------

// This module allows the title and ship to appear on the screen
// This is heavily based on the code in the link mentioned above
module ship(clk, pos_x, pos_y, text, text_colour);
  input clk;
  // pos_x is the x-axis position of the text
  input pos_x;
  wire [9:0]pos_x;
  // pos_y is the position of the text along the y axis
  input pos_y;
  wire [9:0]pos_y;

  output text;
  wire [3:0]text;
  output reg [2:0]text_colour;
  // create the signals to allow text to be displayed
  wire [10:0]add_rom;
  wire [7:0]font;
  wire [7:0]add_logo;
  wire title_pos;
  wire ship_pos;

  reg [6:0]char;
  reg [6:0]pixel;

  // create the local parameters for the states of the display FSM
  localparam START_SCREEN = 5'd0,
				 GAME         = 5'd0;
  // call the font_Rom to get all the text
  VGA_font_rom fr(
    .clk(clk),
    .add(add_rom),
    .data(font));

  // have the title, Starflux, be displayed at the top centre of the screen
  assign title_pos = pos_y[9:7] == 2 && pos_x[9:6] >= 3 && pos_x[9:6] <= 6;
  assign ship_pos = pos_x[9:7] == 2 && pos_y[9:6] >= 3 && pos_y[9:6] <= 6;

  // display the text
  always @(*)
  begin
	case(pos_x[8:6])
		3'o1: char = 7'h00;
		3'o2: char = 7'h01;
		3'o3: char = 7'h02;
		3'o4: char = 7'h03;
		3'o5: char = 7'h04;
		3'o6: char = 7'h05;
		3'o7: char = 7'h06;
	default: char = 7'h07;
	endcase
  end

  // display the ship
  always @(*)
  begin
	case(pos_y[8:6])
		3'o1: pixel = 7'h08; // ship is not in the font_Rom (need to draw rom)
	endcase // ship
  end

endmodule

// ---------------------------------------------------------------

// This module handles the FSM that will control the screens
// The screens are made either through user input or by drawing to screen.
module display_FSM(clk, reset, go, go_draw, ld_x, ld_y, writeEn);
	input clk; // normal 50 Mhz clock passed by de2 board
	input reset; // reset signal given by SW[2]
	input go, go_draw;// state signals given SW[1]
	output reg [7:0] ld_x, ld_y; // state register values for X and Y
   output reg writeEn; // write signal to vga screen

	reg [3:0] current_state, next_state; // state map for our FSM

	localparam START_SCREEN = 5'd0,
              S_BACKGROUND = 5'd1,
              S_SHIP       = 5'd2,
              S_ENEMY      = 5'd3,
				  S_GAME_OVER  = 5'd4;

  // create the state table for the screen display
  always @ (*)
  begin
	case(current_state)
		START_SCREEN:   next_state = go ? S_BACKGROUND: START_SCREEN;
		S_BACKGROUND:   next_state = go_draw ? S_SHIP: S_BACKGROUND;
		S_SHIP:         next_state = go_draw ? S_ENEMY : S_SHIP;
		S_ENEMY:        next_state = go ? S_GAME_OVER : S_ENEMY;
		S_GAME_OVER:    next_state = go ? START_SCREEN : S_GAME_OVER;
		default: next_state = START_SCREEN;
	endcase
  end

  // Output logic to our datapath,
  // here we control x, y, and colour, and set writeEn to 8'b1;
  // in out S_DRAW state(for VGA screen)
  always @(*)
  begin
	ld_x = 8'd80; // start the ship at the bottom middle of the screen
   ld_y = 1'b0;
	writeEn = 8'b1;
   case (current_state)
		S_BACKGROUND: writeEn = 8'b1;
      S_SHIP: writeEn = 8'b1;
   endcase
  end

  // If the reset button has been hit, return to the start screen regardless
  // of the current state
  always@(posedge clk)
  begin
	if(reset)
     current_state <= START_SCREEN;
   else
     current_state <= next_state;
  end

endmodule
