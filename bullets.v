// CSCB58 Starflux project - bullets
// By: Saskia Tjioe, William Granados, Venkada Prasad
// ----------------------------------------------------------------------------

// This module will handle the bullets and the collision features
// I don't know how to code this one, let alone whether we need it or not
// I think we need it as all bullets must be displayed to the VGA
// It is not enough to just create the mechanics of the bullets
module bullets();
  // can't do much of anything with the bullet if it is not there at all
  // so draw the bullet

  // after the bullet is drawn, must now handle collisions
  // Since the bullet, either fired by the enemy or the player, will be
  // either from above or below, create two collision hotspots that will
  // determine the fate of the bullet that are positioned at the top
  // and bottom of the bullet

  // either from above or below:
  // if the bullet was hit by another bullet, both bullets disintegrate
  // if the bullet hits an enemy ship, destroy enemy ship, distintegrate bullet
  // if the bullet hits player ship, tick off 1'b1 health from player
  // and also distintegrate bullet

  // NOTE! This module was based by the following link :
  // http://www.fpga4fun.com/PongGame.html
  // in the Pong Game page, look under "Drawing the Ball"

endmodule

// ----------------------------------------------------------------------------
