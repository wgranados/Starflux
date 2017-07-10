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

  // create the x-shift and y-shift registers to determine the bullet's location
  shift_up y(
    .data_in(),
    .clk(),
    .resetn(),
    .data_out());

  bullet_HSR x(
    .data_in(),
    .clk(),
    .resetn(),
    .data_out());

  // create the y-shift for the enemy bullets
  shift_down enemy(
    .data_in(),
    .clk(),
    .resetn(),
    .data_out());

  // create the bullet mechanics
  bullet_collision b(
    .collide(),
    .enemy(),
    .location(),
    .reset_n(SW[2]),
    .clock(CLOCK_50),
    .Q(Q));

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
  input [160:0]bullets; // checks if any of the bullets were part of collision
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
    for (i = 0, i < 160, i = i + 1) begin
      // if the bullet hit an enemy
      if (bullets[i] == location && location == enemy)
        enemy = // have the enemy destroyed
    // if the bullets hit nothing, then nothing happens, bullet keeps moving
    end
  end

endmodule

// ------------------------------------------------------------------

// The following module creates a serial-in, parallel out shift register
// that is along one horizontal row of the screen which will allow the ship
// to generate bullets from wherever on the screen
module bullet_HSR(data_in, clk, resetn, data_out);
  input data_in;
  input clk;
  input resetn;
  output [160:0]data_out;
  wire [160:0]data_out;
  wire resetn;
  reg [160:0]d_out;

  always @ (posedge clk)
  begin
    if (resetn)
      // if the reset is on, do not fire anything
      d_out <= 0;
    else
      // set up the firing of the bullets
      d_out[160] <= data_in;
      for (i = 159, i != 0, i = i - 1) begin
       d_out[i] <= d_out[i + 1];
      end
  end

  assign data_out = d_out;

endmodule

// The following module is a shift register that will allow a bullet to
// move in the direction it was shot at, and move to the end of the screen

// This module is the shift register that will allow the bullet to go up
// since this is in regards to the player's bullets
module shift_up(data_in, clk, resetn, data_out);
  input data_in;
  input clk;
  input resetn;
  output [120:0]data_out;
  wire [120:0]sb_out;
  wire resetn;
  reg [120:0]d_out;

  // this is on per pixel basis, so in order to fill the whole screen
  // it will take a lot of shifter bits. So make a loop to make them all
  always @ (posedge clk)
  begin
    sb_out <= load_val;
    for (i = 119, i <= 0, i = i - 1) begin
      sb_out[i] <= sb_out[i + 1]
      end
  end

  assign Q = d_out;

endmodule

// The following module will allow the creation of a shifter that
// tracks the movement of enemy bullets
module shift_down(data_in, clk, resetn, data_out);
  input data_in;
  input clk;
  input resetn;
  output [120:0]data_out;
  reg [120:0]data_out;
  wire [120:0]d_out;
  wire resetn;

  // create the shifter bits that will allow bullets to move down
  always @ (posedge clk)
  begin
    sb_out <= load_val;
    for (i = 119, i <= 0, i = i - 1) begin
      sb_out[i] <= sb_out[i + 1]
      end
  end

  assign data_out = d_out;

endmodule
