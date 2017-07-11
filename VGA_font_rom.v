// This file takes care of the VGA text display for the game
// The following code has been based off of this source:
// https://github.com/yzheng624/verilog-pong/blob/master/pong/front_rom.v

// Made by: Saskia Tjioe, William Granados, and Vankada Prasad

// ----------------------------------------------------------------------------

// The following module allows text to be drawn to the VGA display
// This section creates the VGA font_Rom module, that will make the title
module VGA_font_rom(clk, add, data);
  input clk;
  input [10:0]add;
  output [7:0]data;

  wire clk;
  wire add;
  reg [10:0]add_reg;

  always @ (posedge clk)
  begin
    add_reg <= add;
  end

  always @ (*)
  begin
      case (add_reg)
        // create the title: Starflux, one letter at a time
        11'h000: data = 8'b00000000; //
        11'h001: data = 8'b00000000; //
        11'h002: data = 8'b01111100; //  *****
        11'h003: data = 8'b11000110; // **   **
        11'h004: data = 8'b11000110; // **   **
        11'h005: data = 8'b01100000; //  **
        11'h006: data = 8'b00111000; //   ***
        11'h007: data = 8'b00001100; //     **
        11'h008: data = 8'b00000110; //      **
        11'h009: data = 8'b11000110; // **   **
        11'h00a: data = 8'b11000110; // **   **
        11'h00b: data = 8'b01111100; //  *****
        11'h00c: data = 8'b00000000; //
        11'h00d: data = 8'b00000000; //
        11'h00e: data = 8'b00000000; //
        11'h00f: data = 8'b00000000; //

        // create the t in the title
        11'h010: data = 8'b00000000; //
        11'h011: data = 8'b00000000; //
        11'h012: data = 8'b00111000; //   ***
        11'h013: data = 8'b00111000; //   ***
        11'h014: data = 8'b00111000; //   ***
        11'h015: data = 8'b11111111; // ********
        11'h016: data = 8'b11111111; // ********
        11'h017: data = 8'b00111000; //   ***
        11'h018: data = 8'b00111000; //   ***
        11'h019: data = 8'b00111000; //   ***
        11'h01a: data = 8'b00111000; //   ***
        11'h01b: data = 8'b00111000; //   ***
        11'h01c: data = 8'b00011100; //    ***
        11'h01d: data = 8'b00001110; //     ***
        11'h01e: data = 8'b00000000; //
        11'h01f: data = 8'b00000000; //

        // create the a for the title
        11'h020: data = 8'b00000000; //
        11'h021: data = 8'b00000000; //
        11'h022: data = 8'b00000000; //
        11'h023: data = 8'b00000000; //
        11'h024: data = 8'b00000000; //
        11'h025: data = 8'b00000000; //
        11'h026: data = 8'b01111100; //  *****
        11'h027: data = 8'b00000110; //      **
        11'h028: data = 8'b01111110; //  ******
        11'h029: data = 8'b11000110; // **   **
        11'h02a: data = 8'b11000110; // **   **
        11'h02b: data = 8'b11000110; // **   **
        11'h02c: data = 8'b11111011; // ***** **
        11'h02d: data = 8'b00000000; //
        11'h02e: data = 8'b00000000; //
        11'h02f: data = 8'b00000000; //

        // create the r for the title
        11'h030: data = 8'b00000000; //
        11'h031: data = 8'b00000000; //
        11'h032: data = 8'b00000000; //
        11'h033: data = 8'b00000000; //
        11'h034: data = 8'b00000000; //
        11'h035: data = 8'b00000000; //
        11'h036: data = 8'b00000000; //
        11'h037: data = 8'b11000000; // **
        11'h038: data = 8'b11011110; // ** ****
        11'h039: data = 8'b11000011; // **    **
        11'h03a: data = 8'b11000000; // **
        11'h03b: data = 8'b11000000; // **
        11'h03c: data = 8'b11000000; // **
        11'h03d: data = 8'b00000000; //
        11'h03e: data = 8'b00000000; //
        11'h03f: data = 8'b00000000; //

        // create the f in the title
        11'h040: data = 8'b00000000; //
        11'h041: data = 8'b00000000; //
        11'h042: data = 8'b00000000; //
        11'h043: data = 8'b00001110; //     ***
        11'h044: data = 8'b00111001; //   ***  *
        11'h045: data = 8'b00111000; //   ***
        11'h046: data = 8'b11111111; // ********
        11'h047: data = 8'b11111111; // ********
        11'h048: data = 8'b00111000; //   ***
        11'h049: data = 8'b00111000; //   ***
        11'h04a: data = 8'b00111000; //   ***
        11'h04b: data = 8'b00111000; //   ***
        11'h04c: data = 8'b00111000; //   ***
        11'h04d: data = 8'b00111000; //   ***
        11'h04e: data = 8'b01110000; //  ***
        11'h04f: data = 8'b00000000; //

        // create the l in the title
        11'h050: data = 8'b00000000; //
        11'h051: data = 8'b00000000; //
        11'h052: data = 8'b00111000; //  ***
        11'h053: data = 8'b00111000; //  ***
        11'h054: data = 8'b00111000; //  ***
        11'h055: data = 8'b00111000; //  ***
        11'h056: data = 8'b00111000; //  ***
        11'h057: data = 8'b00111000; //  ***
        11'h058: data = 8'b00111000; //  ***
        11'h059: data = 8'b00111000; //  ***
        11'h05a: data = 8'b00111000; //  ***
        11'h05b: data = 8'b00111000; //  ***
        11'h05c: data = 8'b00111000; //  ***
        11'h05d: data = 8'b00011100; //   ***
        11'h05e: data = 8'b00000000; //
        11'h05f: data = 8'b00000000; //

        // create the u in the title
        11'h060: data = 8'b00000000; //
        11'h061: data = 8'b00000000; //
        11'h062: data = 8'b00000000; //
        11'h063: data = 8'b00000000; //
        11'h064: data = 8'b00000000; //
        11'h065: data = 8'b00000000; //
        11'h066: data = 8'b00000000; //
        11'h067: data = 8'b11000110; // **   **
        11'h068: data = 8'b11000110; // **   **
        11'h069: data = 8'b11000110; // **   **
        11'h06a: data = 8'b01111101; //  ***** *
        11'h06b: data = 8'b00000000; //
        11'h06c: data = 8'b00000000; //
        11'h06d: data = 8'b00000000; //
        11'h06e: data = 8'b00000000; //
        11'h06f: data = 8'b00000000; //

        // create the x in the title
        11'h070: data = 8'b00000000; //
        11'h071: data = 8'b00000000; //
        11'h072: data = 8'b00000000; //
        11'h073: data = 8'b00000000; //
        11'h074: data = 8'b00000000; //
        11'h075: data = 8'b11100011; // ***    **
        11'h076: data = 8'b01100110; //  **   **
        11'h077: data = 8'b00111100; //    ***
        11'h078: data = 8'b01100110; //  **   **
        11'h079: data = 8'b11000111; // **     ***
        11'h07a: data = 8'b00000000; //
        11'h07b: data = 8'b00000000; //
        11'h07c: data = 8'b00000000; //
        11'h07d: data = 8'b00000000; //
        11'h07e: data = 8'b00000000; //
        11'h07f: data = 8'b00000000; //

      endcase
  end

endmodule

// ----------------------------------------------------------------------------
