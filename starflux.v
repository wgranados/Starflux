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
                 HEX0, HEX1, HEX2, HEX3, HEX4, HEX5, HEX6, HEX7,
                 VGA_CLK, VGA_HS, VGA_VS, VGA_BLANK_N,
                 VGA_SYNC_N, VGA_R, VGA_G, VGA_B);

	input CLOCK_50; // Default 50 Mhz clock on De2 board
	input [9:0] SW; // Use SW[0] as firing, SW[1] as pause, SW[2] as reset
	input [3:0] KEY; // use KEY[0:3] as right, down, up, left respectively 
    output [9:0] LEDR; // no use for this yet, may be bonus
    output [6:0] HEX0, HEX1, // Display all time high score on HEX[0:1]
                 HEX2, HEX3, // Display current high score on HEX[2:3]
                 HEX4, HEX5, // Display gun's cooldown timer on HEX[4:5]
                 HEX6, HEX7; // Display ship's health on HEX[6:7]

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

    // input related signals
    wire shoot = SW[0]; // tells our game to shoot bullets from our ship
    wire pause = SW[1]; // tells our game to pause our current state
    wire reset = SW[2]; // tells our game to start from the beginning state

    wire right = ~KEY[0]; // tells our game to move our ship right
    wire down  = ~KEY[1]; // tells our game to move our ship down
    wire up    = ~KEY[2]; // tells our game to move our ship up
    wire left  = ~KEY[3]; // tells our game to move our ship left 


    assign LEDR[0] = shoot;


    // game logic related signals
    reg [7:0]ship_health;  // 8 bit value, we're to display lower four bits on 
                           // HEX6, and upper four bits on HEX7
    wire [7:0]gun_cooldown; // 8 bit value, we're to display lower four bits on 
                           // HEX4 and upper four bits HEX5

    reg [7:0]current_highscore; // 8 bit value, we're to display on lower four
                                // bits on HEX3 and upper four bits on HEX2

    reg [7:0]alltime_highscore; // 8 bit value, we're to display on lower four
                                // bits on HEX1 and upper four bits on HEX0

    // vga related signals

	// Create the colour, x, y and writeEn wires that are inputs to the controller.
	wire [2:0] colour;
	wire [7:0] x;
	wire [6:0] y;
	wire writeEn;

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

    // handles logic for  gun cooldown
	gun_cooldown_handler gc(
		.clock(CLOCK_50),
		.shoot(shoot),
		.reset(reset),
		.gun_cooldown_counter(gun_cooldown)
	);
	
	hex_decoder_always h4(.hex_digit(gun_cooldown[3:0]), .segments(HEX4));
	hex_decoder_always h5(.hex_digit(gun_cooldown[7:4]), .segments(HEX5));

    // Instansiate datapath
    wire ld_x, ld_y, ld_col;
	 
    // Instansiate FSM control
	 control C0(
        .clk(CLOCK_50),
        .resetn(KEY[0]),
        .go_load(KEY[1]),
        .go_draw(KEY[3]),
        .ld_x(ld_x),
        .ld_y(ld_y),
        .ld_col(ld_col),
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


endmodule



module control(clk, resetn, go_load, go_draw, ld_x, ld_y, ld_col, writeEn);
	input clk; // normal 50 Mhz clock passed by de2 board
	input resetn; // reset signal giHEX2ven by KEY[0]
	input go_load, go_draw;// state signals given by KEY[1] and KEY[3] 
	output reg ld_x, ld_y, ld_col; // state register values 
    output reg writeEn; // write signal to vga screen

    reg [3:0] current_state, next_state; // state map for our FSM
	 
    localparam  S_LOAD_X         = 5'd0,
                S_LOAD_X_WAIT    = 5'd1,
                S_LOAD_Y         = 5'd2,
                S_LOAD_Y_WAIT    = 5'd3,
                S_LOAD_COL       = 5'd4,
                S_LOAD_COL_WAIT  = 5'd5,
                S_DRAW           = 5'd6;

    // State table for the following steps
    // 1) load 7 bit value from SW[6:0] to register X
    // 2) load 7 bit value from SW[6:0] to register Y
    // 3) load 3 bit value from SW[9:7] to register colour
    always@(*)
    begin
        case (current_state)
            S_LOAD_X:        next_state = go_load ? S_LOAD_X_WAIT : S_LOAD_X;    // Loop in current state until value is input
            S_LOAD_X_WAIT:   next_state = go_load ? S_LOAD_X_WAIT : S_LOAD_Y;    // Loop in current state until go signal goes low
            S_LOAD_Y:        next_state = go_load ? S_LOAD_Y_WAIT : S_LOAD_Y;    // Loop in current state until value is input
            S_LOAD_Y_WAIT:   next_state = go_load ? S_LOAD_Y_WAIT : S_LOAD_COL;  // Loop in current state until go signal goes low
            S_LOAD_COL:      next_state = go_load ? S_LOAD_COL_WAIT : S_LOAD_COL;// Loop in current state until value is input
            S_LOAD_COL_WAIT: next_state = go_load ? S_LOAD_COL_WAIT : S_DRAW;    // Loop in current state until go signal goes low
            S_DRAW:          next_state = go_draw ? S_LOAD_X: S_DRAW;            // Loop in current state until value is input
            default:         next_state = S_LOAD_X;
        endcase
    end 


    // Output logic to our datapath, 
    // here we control x, y, and colour, and set writeEn to 1'b1 
    // in out S_DRAW state(for VGA screen)
    always @(*)
    begin
        ld_x = 1'b0;
        ld_y = 1'b0;
        ld_col = 1'b0;
		writeEn = 1'b0;
        case (current_state)
            S_LOAD_X:   ld_x = 1'b1;
            S_LOAD_Y:   ld_y = 1'b1;
            S_LOAD_COL: ld_col = 1'b1;
            S_DRAW:     writeEn = 1'b1;
        endcase
    end 

    always@(posedge clk)
    begin
        if(!resetn)
            current_state <= S_LOAD_X;
        else
            current_state <= next_state;
    end 

endmodule


module datapath(clk, resetn, colour_in, coord_in,
                ld_x, ld_y, ld_col, enable, 
                x_out, y_out, col_out);
    input clk; // default 50mhz clock
    input resetn; // value given from KEY[0]
    input [2:0] colour_in; // register value given from SW[9:7]
    input [6:0] coord_in; // regster value given from SW[6:0]
    input ld_x, ld_y, ld_col; // state values given from datapath 
    input enable; // write enable signal decided by datapath

    output [7:0]x_out;   // output  value for x to write to screen
    output [6:0]y_out;   // output value for  y to write to screen
    output [2:0]col_out; // output value for colour to write to screen

    reg [7:0] x;   // 7 bit value from SW[6:0], but we have to concatenate to 8
    reg [6:0] y;   // 7 bit value from SW[6:0]
    reg [2:0] col; // 3 bit value from SW[9:7]

    always@(posedge clk) 
    begin
        if(!resetn) 
        begin
            x <= 8'b0;
            y <= 8'b0;
            col <= 3'b0;
        end
        else 
        begin
            if(ld_x)
                x <= {1'b0,  coord_in}; // concatinate to 8 bits with 0 in MSB
            if(ld_y)
                y <= coord_in;
            if(ld_col)
                col <= colour_in;
        end
    end

    reg [1:0]x_offset, y_offset;

    // counting for x
    always @(posedge clk) 
    begin
        if (!resetn)
            x_offset <= 2'b00;
        else 
            x_offset <= x_offset + 1'b1; // wraps around on 2'b11
    end

    assign y_enable = (x_offset == 2'b11) ? 1 : 0;
    
    // counter for y
    always @(posedge clk) 
    begin
        if (!resetn)
            y_offset <= 2'b00;
        else if(y_enable)
            y_offset <= y_offset + 1'b1; // wraps around on 2'b11
    end

    assign x_out = x + x_offset;
    assign y_out = y + y_offset;
    assign color_out = col;
    

endmodule


