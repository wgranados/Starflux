// CSCB58 Starflux project - ship movement mechanics
// By: Saskia Tjioe, William Granados, and Venkada Prasad
// -----------------------------------------------------------------

// NOTE! THIS IS GOING TO HAVE TO OUTPUT TOWARD THE VGA AS A SHOT!
// WE STILL NEED TO FIGURE THAT PART OUT!

// This module handles the bullets, which is made of other modules
// that are called in this module
// bullets will only move in the direction they were shot at
module shifter_grid(SW, Q);
  // have switch 0 be what allows the player to fire their weapon
  // at this point, we have yet to have something that will allow
  // enemy fire to be triggered, unless you want it to be on all the time
  input [0:0] SW;

  wire [7:0]Q;

  shift_up s_up();
  shift_down s_down();

endmodule

// ------------------------------------------------------------------

// This module is the 2-to-1 mux that will help create the shifter bit
module mux2to1(x, y, s, m);
  input x;
  input y;
  input s;
  output m;

  assign m = s & y | ~s & x;

endmodule

// This module creates a d-flip flop that helps make the shifter bit
module flip_flop(d, q, clk, resetn);
  input d;
  input clk;
  input resetn;
  output reg q;

  always @(posedge clk)
  begin
    if (resetn = 1b'0)
        q <= 0;
    else
        q <= d;
  end

endmodule

// ------------------------------------------------------------------

// This module will take a rate divider to act as a clock for the register
module rate_divider(enable, countdown_start, clock, reset_n, q);
  input enable; // enable signal given from user
  input reset_n; // reset signal given by user
  input clock; // clock signal given from CLOCK_50
  input [27:0]countdown_start; // value that this counter should start counting down from
  output reg [27:0]q; // output register we're outputting current count for this rate divider

  // start counting down from count_down_start all the way to 0
  always @(posedge clock)
  begin
    if(reset_n == 1'b0) // when clear_b is 0
      q <= countdown_start;
    else if(enable == 1'b1) // decrement q only when enable is high
    q <= (q == 0) ? countdown_start : q - 1'b1; // if we get to 0, then we loop back
  end

endmodule

// ------------------------------------------------------------------

// This module creates one shifter bit
module shifter_bit(in, load_val, shift, load_n, clk, reset_n, out);
  // Note that these should all be 1 bit inputs as we're really only handling/storing one bit of information in shifter bit
  input in; // connected to out port of left shifter, 0 otherwise on left most shifter bit
  input load_val; // input given from switches, used onlywhen shift = 0
  input shift;  // indicates to shift all bits right
  input load_n; // indicates to load input from switches
  input clk;  // clock used for flip flop
  input reset_n;  // reset signal to set shifter bit's value to 0
  output out; // output of value in shifter bit, generally sent to shifter bit on right

  wire mux_one_out, mux_two_out;

  // determine's whether to shift the bit or not
  mux2to1 mux_one(
  .x(out),
  .y(in),
  .s(shift),
  .m(mux_one_out)
  );
  // determine's whether to load the value from load_val or from in(from left shifter_bit)
  mux2to1 mux_two(
  .x(load_val),
  .y(mux_one_out),
  .s(load_n),
  .m(mux_two_out)
  );
  // determine's logic for what bit should be sent to next shifter_bit module
  flipflop flip_flop(
  .d(mux_two_out),
  .q(out),
  .clock(clk),
  .reset_n(reset_n)
  );

endmodule

// ------------------------------------------------------------------

// NOTE! THIS IS NOT COMPLETE!

// The following module is a shift register that will allow a bullet to
// move in the direction it was shot at, and move to the end of the screen
// since this is a vertical scrolling game, the bullet will only ever
// move up or down, depending on who fired it (player or enemy)

// To make the movement and sight of shifting enough for the player to see
// Could try to do a for loop that creates the shifters we need to fill
// the whole screen and so allow movement

// This module is the shift register that will allow the bullet to go
// in the y direction, such as up and down
module shift_up(load_val, load_n, shift_u, ASR, clk, reset, Q);
  input load_val; // this is loaded by the gun being fired from the player
  input load_n;
  input shift_y;
  input ASR;
  input clk; // the clk is from the rate divider
  input reset; // reset must be from some switch

  output Q; // displays the position of the bullet further up

  wire [7:0]sb_out;
  // this is on per pixel basis, so in order to fill the whole screen
  // it will take a lot of shifter bits. So make a loop to make them all
  // as this is not complete, let's start with 300
  for (i = 0, i < 300, i = i + 1) begin
    shifter_bit sb_7(.in(ASR), .load_val(load_val), .shift(shift_right), .load_n(load_n), .clk(clk), .reset_n(reset_n), .out(sb_out[7]) );
    shifter_bit sb_6(.in(sb_out[7]), .load_val(load_val), .shift(shift_right), .load_n(load_n), .clk(clk), .reset_n(reset_n), .out(sb_out[6]) );
    shifter_bit sb_5(.in(sb_out[6]), .load_val(load_val), .shift(shift_right), .load_n(load_n), .clk(clk), .reset_n(reset_n), .out(sb_out[5]) );
    shifter_bit sb_4(.in(sb_out[5]), .load_val(load_val), .shift(shift_right), .load_n(load_n), .clk(clk), .reset_n(reset_n), .out(sb_out[4]) );
    shifter_bit sb_3(.in(sb_out[4]), .load_val(load_val), .shift(shift_right), .load_n(load_n), .clk(clk), .reset_n(reset_n), .out(sb_out[3]) );
    shifter_bit sb_2(.in(sb_out[3]), .load_val(load_val), .shift(shift_right), .load_n(load_n), .clk(clk), .reset_n(reset_n), .out(sb_out[2]) );
    shifter_bit sb_1(.in(sb_out[2]), .load_val(load_val), .shift(shift_right), .load_n(load_n), .clk(clk), .reset_n(reset_n), .out(sb_out[1]) );
    shifter_bit sb_0(.in(sb_out[1]), .load_val(load_val), .shift(shift_right), .load_n(load_n), .clk(clk), .reset_n(reset_n), .out(sb_out[0]) );
  end

  assign Q = sb_out[7:0];

endmodule

// This module will control the shifter that allows enemy bullets to move
// down the screen
module shift_down(load_val, load_n, shift_d, ASR, clk, reset, Q);
  input load_val;
  input load_n;
  input shift_y;
  input ASR;
  input clk;
  input reset;

  output Q;

  wire [7:0]sb_out;
  // this is on per pixel basis, so in order to fill the whole screen
  // it will take a lot of shifter bits. So make a loop to make them all
  // as this is not complete, let's start with 300
  for (i = 0, i < 300, i = i + 1) begin
    shifter_bit sb_7(.in(ASR), .load_val(load_val), .shift(shift_right), .load_n(load_n), .clk(clk), .reset_n(reset_n), .out(sb_out[7]) );
    shifter_bit sb_6(.in(sb_out[7]), .load_val(load_val), .shift(shift_right), .load_n(load_n), .clk(clk), .reset_n(reset_n), .out(sb_out[6]) );
    shifter_bit sb_5(.in(sb_out[6]), .load_val(load_val), .shift(shift_right), .load_n(load_n), .clk(clk), .reset_n(reset_n), .out(sb_out[5]) );
    shifter_bit sb_4(.in(sb_out[5]), .load_val(load_val), .shift(shift_right), .load_n(load_n), .clk(clk), .reset_n(reset_n), .out(sb_out[4]) );
    shifter_bit sb_3(.in(sb_out[4]), .load_val(load_val), .shift(shift_right), .load_n(load_n), .clk(clk), .reset_n(reset_n), .out(sb_out[3]) );
    shifter_bit sb_2(.in(sb_out[3]), .load_val(load_val), .shift(shift_right), .load_n(load_n), .clk(clk), .reset_n(reset_n), .out(sb_out[2]) );
    shifter_bit sb_1(.in(sb_out[2]), .load_val(load_val), .shift(shift_right), .load_n(load_n), .clk(clk), .reset_n(reset_n), .out(sb_out[1]) );
    shifter_bit sb_0(.in(sb_out[1]), .load_val(load_val), .shift(shift_right), .load_n(load_n), .clk(clk), .reset_n(reset_n), .out(sb_out[0]) );
  end

  assign Q = sb_out[7:0];

endmodule
