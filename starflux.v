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
    output [17:0] LEDR; // no use for this yet, may be bonus
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
	
	wire resetn;
	assign resetn = KEY[0];

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

	// Put your code here. Your code should produce signals x,y,colour and writeEn/plot
	// for the VGA controller, in addition to any other functionality your design may require.

    // Instansiate datapath
    wire ld_x, ld_y, ld_col;

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
	hex_decoder H0(.hex_digit(x[3:0]), .segments(HEX0));
	hex_decoder H1(.hex_digit(y[3:0]), .segments(HEX1));



endmodule



module control(clk, resetn, go_load, go_draw, ld_x, ld_y, ld_col, writeEn);

	// this control must be able to take in the inputs for
	// x, y, and colour for the control x, y, and colour signals
	input clk;
	input resetn;
	input go_load, go_draw;
   output reg writeEn;

	output reg  ld_x, ld_y, ld_col;

    reg [3:0] current_state, next_state;
	 
    localparam  S_LOAD_X         = 5'd0,
                S_LOAD_X_WAIT    = 5'd1,
                S_LOAD_Y         = 5'd2,
                S_LOAD_Y_WAIT    = 5'd3,
                S_LOAD_COL       = 5'd4,
                S_LOAD_COL_WAIT  = 5'd5,
                S_DRAW           = 5'd6,
					 S_DRAW_WAIT      = 5'd7;

    // Next state logic aka our state table
		// just follow the state table made in the pre-lab
    always@(*)
    begin: state_table
            case (current_state)
                S_LOAD_X: next_state = go_load ? S_LOAD_X_WAIT : S_LOAD_X; // Loop in current state until value is input
                S_LOAD_X_WAIT: next_state = go_load ? S_LOAD_X_WAIT : S_LOAD_Y; // Loop in current state until go signal goes low
                S_LOAD_Y: next_state = go_load ? S_LOAD_Y_WAIT : S_LOAD_Y; // Loop in current state until value is input
                S_LOAD_Y_WAIT: next_state = go_load? S_LOAD_Y_WAIT : S_LOAD_COL; // Loop in current state until go signal goes low
                S_LOAD_COL: next_state = go_load ? S_LOAD_COL_WAIT : S_LOAD_COL; // Loop in current state until value is input
                S_LOAD_COL_WAIT: next_state = go_load ? S_LOAD_COL_WAIT : S_DRAW; // Loop in current state until go signal goes low
                S_DRAW: next_state = go_draw ? S_DRAW_WAIT : S_DRAW; // Loop in current state until value is input
					 S_DRAW_WAIT: next_state = go_draw ? S_DRAW_WAIT: S_LOAD_X;
				default:     next_state = S_LOAD_X;
        endcase
    end // state_table


    // Output logic aka all of our datapath control signals
	// this is for control x, y, and colour
    always @(*)
    begin: enable_signals
        // By default make all our signals 0
        ld_x = 1'b0;
        ld_y = 1'b0;
        ld_col = 1'b0;
		  writeEn = 1'b0;
        case (current_state)
            S_LOAD_X: begin
                ld_x = 1'b1;
                end
            S_LOAD_Y: begin
                ld_y = 1'b1;
                end
            S_LOAD_COL: begin
                ld_col = 1'b1;
                end
            S_DRAW: begin
                writeEn = 1'b1;
                end
				S_DRAW_WAIT: begin
                writeEn = 1'b1;
            end
        endcase
    end // enable_signals

    // current_state registers
    always@(posedge clk)
    begin: state_FFs
        if(!resetn)
            current_state <= S_LOAD_X;
        else
            current_state <= next_state;
    end // state_FFS
endmodule


module datapath(
    input clk,
    input resetn,
    input [2:0] colour_in,
    input [7:0] coord_in,
    input ld_x, ld_y, ld_col,
	 input enable,
    output [7:0]x_out,
    output [6:0]y_out,
    output [2:0]col_out
    );

    // input registers
    reg [7:0] x;
    reg [6:0] y;
    reg [2:0] col;

    // Registers x, y, col with respective input logic
    always@(posedge clk) begin
        if(!resetn) begin
            x <= 8'b0;
            y <= 8'b0;
            col <= 3'b0;
        end
        else begin
            if(ld_x)
                x <= {1'b0,  coord_in}; // concatinate to 8 bits with 0 in MSB
            if(ld_y)
                y <= coord_in;
            if(ld_col)
                col <= colour_in;
        end
    end

    reg [1:0]cnt_x, cnt_y;

    // counting for x
    always @(posedge clk) begin
        if (resetn)
            cnt_x <= 2'b00;
        else if (enable) begin 
            cnt_x <= cnt_x + 1'b1; // wraps around on 2'b11
        end
    end

    assign y_enable = (cnt_x == 2'b11) ? 1 : 0;
    
    // counter for y
    always @(posedge clk) begin
        if (resetn)
            cnt_y <= 2'b00;
        else if (enable) begin
            cnt_y <= cnt_y + 1'b1; // wraps around on 2'b11
        end
    end

    assign x_out = x + cnt_x;
    assign y_out = y + cnt_y;
    assign color_out = col;
    

endmodule


module hex_decoder(hex_digit, segments);
    input [3:0] hex_digit;
    output reg [6:0] segments;
   
    always @(*)
        case (hex_digit)
            4'h0: segments = 7'b100_0000;
            4'h1: segments = 7'b111_1001;
            4'h2: segments = 7'b010_0100;
            4'h3: segments = 7'b011_0000;
            4'h4: segments = 7'b001_1001;
            4'h5: segments = 7'b001_0010;
            4'h6: segments = 7'b000_0010;
            4'h7: segments = 7'b111_1000;
            4'h8: segments = 7'b000_0000;
            4'h9: segments = 7'b001_1000;
            4'hA: segments = 7'b000_1000;
            4'hB: segments = 7'b000_0011;
            4'hC: segments = 7'b100_0110;
            4'hD: segments = 7'b010_0001;
            4'hE: segments = 7'b000_0110;
            4'hF: segments = 7'b000_1110;   
            default: segments = 7'h7f;
        endcase
endmodule
