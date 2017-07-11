// This file displays the text from the the font_Rom to the screen
// This is based off of this code:
// https://github.com/bogini/Pong/blob/master/pong_text.v

// Made by: Saskia Tjioe, William Granados, and Venkada Prasad

// ----------------------------------------------------------------------------

// This module allows the title to appear on the screen
// This is heavily based on the code in the link mentioned above
module text_display(clk, pos_x, pos_y, text, text_colour);
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
  reg [6:0]char;
  // call the font_Rom to get all the text
  VGA_font_rom fr(
    .clk(clk),
    .add(add_rom),
    .data(font));

  // have the title, Starflux, be displayed at the top centre of the screen
  assign title_pos = pos_y[9:7] == 2 && pos_x[9:6] >= 3 && pos_x[9:6] <= 6;
  always @ (*)
  begin
    case (pos_x[8:6])
      3'o1: char = 7'h00; // S
      3'o2: char = 7'h01; // t
      3'o3: char = 7'h02; // a
      3'o4: char = 7'h03; // r
      3'o5: char = 7'h04; // f
      3'o6: char = 7'h05; // l
      3'o7: char = 7'h06; // u
      default: char = 7'h07; // x
  end

endmodule
