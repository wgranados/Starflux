// CSCB58 Starflux project - bullet mechanics
// By: Saskia Tjioe, William Granados, and Venkada Prasad

// This file takes care of bullet mechanics in regards to
// collision, such as if the bullet hits another bullet,
// if the bullet hits the enemy ship, and if the bullet
// hits the player

// -----------------------------------------------------------------

// NOTE! THIS IS GOING TO HAVE TO OUTPUT TOWARD THE VGA AS A SHOT!
// WE STILL NEED TO FIGURE THAT PART OUT!

// This module handles the bullets, which is made of other modules
// that are called in this module
// bullets will only move in the direction they were shot at
module shiftergrid(SW, CLOCK_50, Q);
  // have switch 0 be what allows the player to fire their weapon
  // at this point, we have yet to have something that will allow
  // enemy fire to be triggered, unless you want it to be on all the time
  input [2:0] SW; // SW[2] for the reset, SW[0] for firing the gun
  input CLOCK_50;

  output Q; // The output is displayed onto the VGA
  
  // create the bullet mechanics
  bullets b(
    .sw_select(SW[0]),
	 .load_n(),
	 .reset_n(SW[2]),
	 .clock(CLOCK_50),
	 .Q(Q));

endmodule

// -----------------------------------------------------------------

// This module creates the bullets for the game
module bullets(sw_select, load_n, reset_n, clock, Q);
  input sw_select; // switch to fire gun
  input load_n;
  input reset_n;
  input clock; // clock signal from the CLOCK_50
  output Q;
  reg [0:0]shoot; // shoot is a one bit value
  
  // FROM THE MORSE CODE MODULE, case unchanged; need modification
  always @(*)
  begin
    case(sw_select) // select what to put into the shifter module
	 1'b0: shoot = 1'b0; // don't fire a bullet 
    1'b1: shoot = 1'b1; // fire a bullet
    default: shoot = 1'b0; // probably won't reach this but okay
	 endcase
  end
  
  wire [0:0] rd_out;
  // create the rate divide, which will always be on but have a reset
  rate_divider rd(
    .enable(1), 
	 .countdown_start(1'b1), 
	 .clock(clock), 
	 .reset_n(reset_n), 
	 .q(rd_out));
  
  // send to the shifter for the bullet to move when fired by the player
  shift_up su(
    .load_val(sw_select[0]),
	 .load_n(load_n),
	 .shift_u(enable),
	 .ASR(0),
	 .clk(rd),
	 .reset(reset_n),
	 .Q(Q));
	 
  // create a shifter that allows enemy bullets to move
  // the loading of values, like enable in the rate divider, will always be on
  shift_down sd(
    .load_val(1),
	 .load_n(load_n),
	 .shift_u(enable),
	 .ASR(0),
	 .clk(rd),
	 .reset(reset_n),
	 .Q(Q));

endmodule

// ------------------------------------------------------------------

// This module creates a demultiplexer for the load_n for shifters
module demux1to4(data_in, select, data_out);
  input data_in;
  input [1:0]select;
  output [3:0]data_out;
  
  assign data_out[3] = data_in & (~select[0]) & (~select[1]);
  assign data_out[2] = data_in & (~select[0]) & select[1];
  assign data_out[1] = data_in & select[0] & (~select[1]);
  assign data_out[0] = data_in & select[0] & select[1];

  
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
// In this case, a bullet is to be fired once every second while the 
// switch to fire the weapon is on
module rate_divider(enable, countdown_start, clock, reset_n, q);
  input enable; // enable signal
  input reset_n; // reset signal
  input clock; // clock signal given from CLOCK_50
  input [1:0]countdown_start; // value that this counter should start at
  output reg [1:0]q; // output register

  // start counting down from countdown_start all the way to 0
  always @(posedge clock)
  begin
    if(reset_n == 1'b0) // when clear_b is 0
      q <= countdown_start;
    else if(enable == 1'b1) // countdown when enable is high
    q <= (q == 0) ? countdown_start : q - 1'b1; // if 0, start countdown again
  end

endmodule

// ------------------------------------------------------------------

// This module creates one shifter bit
module shifter_bit(in, load_val, shift, load_n, clk, reset_n, out);
  // Note that these should all be 1 bit inputs as we're really only handling/storing one bit of information in shifter bit
  input in; // connected to out port of left shifter, 0 otherwise on left most shifter bit
  input load_val; // input given from switches, used onlywhen shift = 0
  input shift;  // indicates to shift all bits
  input load_n; // indicates to load input from switches
  input clk;  // clock used for flip flop
  input reset_n;  // reset signal to set shifter bit's value to 0
  output out; // output of value in shifter bit, often sent to next shifter bit

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
// CSCB58 Starflux project - bullet mechanics
// By: Saskia Tjioe, William Granados, and Venkada Prasad

// This file takes care of bullet mechanics in regards to
// collision, such as if the bullet hits another bullet,
// if the bullet hits the enemy ship, and if the bullet
// hits the player

// -----------------------------------------------------------------

// This module handles the bullets, which is made of other modules
// that are called in this module
// bullets will only move in the direction they were shot at
module shiftergrid(SW, CLOCK_50, Q);
  input [2:0] SW; // SW[2] for the reset, SW[0] for firing the gun
  input CLOCK_50;

  output Q; // The output is displayed onto the VGA

  // create the bullet mechanics
  bullet_collision b(
    .collide(),
    .enemy(),
    .location(),
    .reset_n(),
    .clock(),
    .Q());

endmodule

// ------------------------------------------------------------------

// This module will take a rate divider to act as a clock for the register
// In this case, a bullet is to be fired once every second while the
// switch to fire the weapon is on
module rate_divider(enable, countdown_start, clock, reset_n, q);
  input enable; // enable signal
  input reset_n; // reset signal
  input clock; // clock signal given from CLOCK_50
  input [1:0]countdown_start; // value that this counter should start at
  output reg [1:0]q; // output register

  // start counting down from countdown_start all the way to 0
  always @(posedge clock)
  begin
    if(reset_n == 1'b0) // when clear_b is 0
      q <= countdown_start;
    else if(enable == 1'b1) // countdown when enable is high
    q <= (q == 0) ? countdown_start : q - 1'b1; // if 0, start countdown again
  end

endmodule

// -----------------------------------------------------------------

// This module takes care of the bullet physics and collision
// It only takes care of collisions between player bullets and the enemies
module bullet_collision(bullets, enemy, player, location, reset_n, clock, Q);
  input [117:0]bullets; // checks if any of the bullets were part of collision
  input enemy; // the enemy's location
  input player; // the player's location
  input location; // where on screen the collision has occurred
  input reset_n;
  input clock; // clock signal from the CLOCK_50
  output Q;
  reg [0:0]shoot; // shoot is a one bit value

  // ever time the clk has reached a positive edge, check the follwing:
  always @ (posedge clk)
  begin
    // check if any of the bullets hit anything
    for (i = 0, i < 118, i = i + 1) begin
      // if the bullet hit an enemy
      if (bullets[i] == location && location == enemy)
        enemy = // have the enemy destroyed
    // if the bullets hit nothing, then nothing happens, bullet keeps moving
    end
  end

endmodule

// ------------------------------------------------------------------

// This module creates a demultiplexer for the load_n for shifters
module demux1to4(data_in, select, data_out);
  input data_in;
  input [1:0]select;
  output [3:0]data_out;

  assign data_out[3] = data_in & (~select[0]) & (~select[1]);
  assign data_out[2] = data_in & (~select[0]) & select[1];
  assign data_out[1] = data_in & select[0] & (~select[1]);
  assign data_out[0] = data_in & select[0] & select[1];


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

// This module creates one shifter bit
module shifter_bit(in, load_val, shift, load_n, clk, reset_n, out);
  // Note that these should all be 1 bit inputs as we're really only handling/storing one bit of information in shifter bit
  input in; // connected to out port of left shifter, 0 otherwise on left most shifter bit
  input load_val; // input given from switches, used onlywhen shift = 0
  input shift;  // indicates to shift all bits
  input load_n; // indicates to load input from switches
  input clk;  // clock used for flip flop
  input reset_n;  // reset signal to set shifter bit's value to 0
  output out; // output of value in shifter bit, often sent to next shifter bit

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

// The following module creates a serial-in, parallel out shift register
// that is along one horizontal row of the screen which will allow the ship
// to generate bullets from wherever on the screen

module bullet_HSR(data_in, clk, resetn, data_out);
  input data_in;
  input clk;
  input resetn;
  output [117:0]data_out;
  wire [117:0]data_out;
  wire resetn;
  reg [117:0]d_out;

  always @ (posedge clk)
  begin
    if (resetn)
      // if the reset is on, do not fire anything
      d_out <= 0;
    else
      // set up the firing of the bullets
      d_out[117] <= data_in;
      for (i = 116, i != 0, i = i - 1) begin
       d_out[i] <= d_out[i + 1];
      end
  end

  assign data_out = d_out;

endmodule

// The following module is a shift register that will allow a bullet to
// move in the direction it was shot at, and move to the end of the screen
// since this is a vertical scrolling game, the bullet will only ever
// move up or down, depending on who fired it (player or enemy)

// This module is the shift register that will allow the bullet to go
// in the y direction, such as up and down
module shift_up(load_val, load_n, shift_u, ASR, clk, reset, Q);
  input load_val; // this is loaded by the gun being fired from the player
  input load_n;
  input shift_u;
  input ASR;
  input clk; // the clk is from the rate divider
  input reset; // reset must be from some switch

  output Q; // displays the position of the bullet further up

  wire [7:0]sb_out;
  // this is on per pixel basis, so in order to fill the whole screen
  // it will take a lot of shifter bits. So make a loop to make them all
  // as this is not complete, let's start with 300
  for (i = 0, i < 300, i = i + 1) begin
    shifter_bit sb_7(.in(ASR), .load_val(load_val), .shift(shift_u), .load_n(load_n), .clk(clk), .reset_n(reset_n), .out(sb_out[7]));
    shifter_bit sb_6(.in(sb_out[7]), .load_val(load_val), .shift(shift_u), .load_n(load_n), .clk(clk), .reset_n(reset_n), .out(sb_out[6]));
    shifter_bit sb_5(.in(sb_out[6]), .load_val(load_val), .shift(shift_u), .load_n(load_n), .clk(clk), .reset_n(reset_n), .out(sb_out[5]));
    shifter_bit sb_4(.in(sb_out[5]), .load_val(load_val), .shift(shift_u), .load_n(load_n), .clk(clk), .reset_n(reset_n), .out(sb_out[4]));
    shifter_bit sb_3(.in(sb_out[4]), .load_val(load_val), .shift(shift_u), .load_n(load_n), .clk(clk), .reset_n(reset_n), .out(sb_out[3]));
    shifter_bit sb_2(.in(sb_out[3]), .load_val(load_val), .shift(shift_u), .load_n(load_n), .clk(clk), .reset_n(reset_n), .out(sb_out[2]));
    shifter_bit sb_1(.in(sb_out[2]), .load_val(load_val), .shift(shift_u), .load_n(load_n), .clk(clk), .reset_n(reset_n), .out(sb_out[1]));
    shifter_bit sb_0(.in(sb_out[1]), .load_val(load_val), .shift(shift_u), .load_n(load_n), .clk(clk), .reset_n(reset_n), .out(sb_out[0]));
  end

  assign Q = sb_out[7:0];

endmodule
