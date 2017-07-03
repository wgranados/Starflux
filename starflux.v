// Part 2 skeleton

module starflux
	(
		CLOCK_50,						//	On Board 50 MHz
        	KEY,
        	SW,
		VGA_CLK,   						//	VGA Clock
		VGA_HS,							//	VGA H_SYNC
		VGA_VS,							//	VGA V_SYNC
		VGA_BLANK_N,						//	VGA BLANK
		VGA_SYNC_N,						//	VGA SYNC
		VGA_R,   						//	VGA Red[9:0]
		VGA_G,	 						//	VGA Green[9:0]
		VGA_B   						//	VGA Blue[9:0]
	);

	input	CLOCK_50;				//	50 MHz
	input   [9:0]   SW;
	input   [3:0]   KEY;

	// Declare your inputs and outputs here
	// Do not change the following outputs
	output		VGA_CLK;   				//	VGA Clock
	output		VGA_HS;					//	VGA H_SYNC
	output		VGA_VS;					//	VGA V_SYNC
	output		VGA_BLANK_N;				//	VGA BLANK
	output		VGA_SYNC_N;				//	VGA SYNC
	output	[9:0]	VGA_R;   				//	VGA Red[9:0]
	output	[9:0]	VGA_G;	 				//	VGA Green[9:0]
	output	[9:0]	VGA_B;   				//	VGA Blue[9:0]
	
	wire resetn;
	wire go;
    	assign go = ~KEY[1];
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
	// datapath d0(...);
	wire ld_x, ld_y, ld_colour;
   	wire ld_alu_out;
    	wire [1:0]  alu_select_x, alu_select_y;
    	wire alu_op;
datapath d0(
    .clk(CLOCK_50),
    .resetn(resetn),
    .data_in(SW[6:0]),
    .data_colour(SW[9:7]),
    .ld_alu_out(ld_alu_out), 
    .ld_x(ld_x), .ld_y(ld_y), .ld_colour(ld_colour),
    .alu_op(alu_op),
    .result_x(x),
    .result_y(y),
    .result_colour(colour),
    );

    // Instansiate FSM control
    // control c0(...);
	control c0(.clk(CLOCK_50), 
		   .resetn(resetn), .go(go), .ld_x(ld_x), .ld_y(ld_y), 
		   .ld_colour(ld_colour), ld_r(write_En), ld_alu_out(ld_alu_out), .alu_select_x(alu_select_x), 
                   .alu_select_y(alu_select_y), .alu_op(alu_op) );
endmodule

module control(
    input clk,
    input resetn,
    input go,

    output reg  ld_x, ld_y, ld_colour, ld_r
    output reg  ld_alu_out,
    output reg [1:0]  alu_select_x, alu_select_y,
    output reg alu_op
    );

    reg [5:0] current_state, next_state; 
    
    localparam  S_LOAD_X       	= 5'd0,
		S_LOAD_X_WAIT   = 5'd1,
		S_LOAD_Y	= 5'd2,
		S_LOAD_Y_WAIT   = 5'd3,
		S_LOAD_COLOUR   = 5'd4,
		S_LOAD_COLOUR_WAIT = 5'd5,
                S_CYCLE_1   	= 5'd6,
                S_CYCLE_2       = 5'd7,
                S_CYCLE_3   	= 5'd8,
                S_CYCLE_4       = 5'd9,
                S_CYCLE_5   	= 5'd10,
                S_CYCLE_6 	= 5'd11,
                S_CYCLE_7   	= 5'd12,
                S_CYCLE_8       = 5'd13,
                S_CYCLE_9       = 5'd14,
                S_CYCLE_10     	= 5'd15;
		S_CYCLE_11     	= 5'd16;
		S_CYClE_12	= 5'd17;
		S_CYCLE_13	= 5'd18;
		S_CYCLE_14	= 5'd19;
		S_CYCLE_15	= 5'd20;
		S_CYCLE_16 	= 5'd21;
    
    // Next state logic aka our state table
    always@(*)
    begin: state_table 
            case (current_state)
                S_LOAD_X: next_state = go ? S_LOAD_X_WAIT : S_LOAD_X; // Loop in current state until value is input
                S_LOAD_X_WAIT: next_state = go ? S_LOAD_X_WAIT : S_LOAD_Y; // Loop in current state until go signal goes low
                S_LOAD_Y: next_state = go ? S_LOAD_Y_WAIT : S_LOAD_Y; // Loop in current state until value is input
                S_LOAD_Y_WAIT: next_state = go ? S_LOAD_Y_WAIT : S_CYCLE_0; // Loop in current state until go signal goes low
		S_LOAD_COLOUR: next_state = go ? S_LOAD_COLOUR_WAIT : S_LOAD_COLOUR; // Loop in current state until value is input
                S_LOAD_COLOUR_WAIT: next_state = go ? S_LOAD_COLOUR_WAIT : S_CYCLE_0; // Loop in current state until go signal goes low
                S_CYCLE_0: next_state = S_CYCLE_1;
                S_CYCLE_1: next_state = S_LOAD_2;
		S_CYCLE_2: next_state = S_LOAD_3;
		S_CYCLE_3: next_state = S_LOAD_4;
		S_CYCLE_4: next_state = S_LOAD_5;
		S_CYCLE_5: next_state = S_LOAD_6;
		S_CYCLE_6: next_state = S_LOAD_7;
		S_CYCLE_7: next_state = S_LOAD_8;
		S_CYCLE_8: next_state = S_LOAD_9;
		S_CYCLE_9: next_state = S_LOAD_10;
		S_CYCLE_10: next_state = S_LOAD_11;
		S_CYCLE_11: next_state = S_LOAD_12;
		S_CYCLE_13: next_state = S_LOAD_14;
		S_CYCLE_14: next_state = S_LOAD_15;
		S_CYCLE_15: next_state = S_LOAD_X;
            default:     next_state = S_LOAD_X;
        endcase
    end // state_tab
   

    // Output logic aka all of our datapath control signals
    always @(*)
    begin: enable_signals
        // By default make all our signals 0
        ld_alu_out = 1'b0;
        ld_x = 1'b0;
        ld_y = 1'b0;
	ld_colour = 1'b0;
	ld_r = 1'b0;
        alu_select_a = 2'b0;
        alu_select_b = 2'b0;
        alu_op       = 1'b0;

        case (current_state)
            S_LOAD_X: begin
                ld_x = 1'b1;
                end
            S_LOAD_Y: begin
                ld_y = 1'b1;
                end
	    S_LOAD_COLOUR: begin
		ld_alu_out = 1'b1; ld_x = 1'b1;
		ld_y = 1'b1;
		ld_colour = 1'b1;
		alu_select_x = 2'd0; // Select register x
                alu_select_y = 2'd1; // Also select register y
                alu_op = 2'd0; // Do add
		ld_r = 1'b1;
	    	end
            S_CYCLE_0: begin // Do A <- A * A 
                ld_alu_out = 1'b1; ld_x = 1'b1; // store result back into x
		ld_y = 1'b1;
		ld_r = 1'b1;
                alu_select_x = 2'd0; // Select register x
                alu_select_y = 2'd1; // Also select register y
                alu_op = 2'd0; // Do add
            end
            S_CYCLE_1: begin
		ld_alu_out = 1'b1; ld_x = 1'b1;
                ld_r = 1'b1; // store result in result register
                alu_select_a = 2'b00; // Select register x
                alu_select_b = 2'b10; // Select register y
                alu_op = 1'b0; // Do Add operation
            end
	    S_CYCLE_2: begin
		ld_alu_out = 1'b1; ld_x = 1'b1;
                ld_r = 1'b1; // store result in result register
                alu_select_a = 2'b00; // Select register A
                alu_select_b = 2'b10; // Select register C
                alu_op = 1'b1; // Do Add operation
            end
	    S_CYCLE_3: begin
		ld_alu_out = 1'b1; ld_x = 1'b1;
		ld_y = 1'b1;
		alu_select_x = 2'd0; // Select register x
                alu_select_y = 2'd1; // Also select register y
                alu_op = 2'd0; // Do add
		ld_r = 1'b1;
	    	end
            S_CYCLE_4: begin // Do A <- A * A 
                ld_alu_out = 1'b1; ld_x = 1'b1; // store result back into x
		ld_y = 1'b1;
		ld_r = 1'b1;
                alu_select_x = 2'd0; // Select register x
                alu_select_y = 2'd1; // Also select register y
                alu_op = 2'd0; // Do add
            end
            S_CYCLE_5: begin
		ld_alu_out = 1'b1; ld_x = 1'b1;
                ld_r = 1'b1; // store result in result register
                alu_select_a = 2'b00; // Select register x
                alu_select_b = 2'b10; // Select register y
                alu_op = 1'b0; // Do Add operation
            end
	    S_CYCLE_6: begin
		ld_alu_out = 1'b1; ld_x = 1'b1;
                ld_r = 1'b1; // store result in result register
                alu_select_a = 2'b00; // Select register A
                alu_select_b = 2'b10; // Select register C
                alu_op = 1'b1; // Do Add operation
            end
	    S_CYCLE_7: begin
		ld_alu_out = 1'b1; ld_x = 1'b1;
		ld_y = 1'b1;
		alu_select_x = 2'd0; // Select register x
                alu_select_y = 2'd1; // Also select register y
                alu_op = 2'd0; // Do add
		ld_r = 1'b1;
	    	end
            S_CYCLE_8: begin // Do A <- A * A 
                ld_alu_out = 1'b1; ld_x = 1'b1; // store result back into x
		ld_y = 1'b1;
		ld_r = 1'b1;
                alu_select_x = 2'd0; // Select register x
                alu_select_y = 2'd1; // Also select register y
                alu_op = 2'd0; // Do add
            end
            S_CYCLE_9: begin
		ld_alu_out = 1'b1; ld_x = 1'b1;
                ld_r = 1'b1; // store result in result register
                alu_select_a = 2'b00; // Select register x
                alu_select_b = 2'b10; // Select register y
                alu_op = 1'b0; // Do Add operation
            end
	    S_CYCLE_10: begin
		ld_alu_out = 1'b1; ld_x = 1'b1;
                ld_r = 1'b1; // store result in result register
                alu_select_a = 2'b00; // Select register A
                alu_select_b = 2'b10; // Select register C
                alu_op = 1'b1; // Do Add operation
            end
            S_CYCLE_11: begin
		ld_alu_out = 1'b1; ld_x = 1'b1;
		ld_y = 1'b1;
		alu_select_x = 2'd0; // Select register x
                alu_select_y = 2'd1; // Also select register y
                alu_op = 2'd0; // Do add
		ld_r = 1'b1;
	    	end
            S_CYCLE_12: begin // Do A <- A * A 
                ld_alu_out = 1'b1; ld_x = 1'b1; // store result back into x
		ld_y = 1'b1;
		ld_r = 1'b1;
                alu_select_x = 2'd0; // Select register x
                alu_select_y = 2'd1; // Also select register y
                alu_op = 2'd0; // Do add
            end
            S_CYCLE_13: begin
		ld_alu_out = 1'b1; ld_x = 1'b1;
                ld_r = 1'b1; // store result in result register
                alu_select_a = 2'b00; // Select register x
                alu_select_b = 2'b10; // Select register y
                alu_op = 1'b0; // Do Add operation
            end
	    S_CYCLE_14: begin
		ld_alu_out = 1'b1; ld_x = 1'b1;
                ld_r = 1'b1; // store result in result register
                alu_select_a = 2'b00; // Select register A
                alu_select_b = 2'b10; // Select register C
                alu_op = 1'b1; // Do Add operation
            end
        // default:    // don't need default since we already made sure all of our outputs were assigned a value at the start of the always block
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
    input [6:0] data_in,
    input [2:0] data_colour,
    input ld_alu_out, 
    input ld_x, ld_y, ld_colour,
    input alu_op,
    output reg [7:0] result_x,
    output reg [6:0] result_y,
    output reg [2:0] result_colour,
    );
    
    // input registers
    reg [7:0] x;
    reg [6:0] y;
    reg [2:0] colour;

    // output of the alu
    reg [7:0] out_x;
    reg [6:0] out_y;
    reg [2:0] out_colour;
    // alu input muxes
    reg [7:0] alu_x
    reg [6:0] alu_y;

    
    // Registers a, b, c, x with respective input logic
    always@(posedge clk) begin
        if(!resetn) begin
            x <= 8'b0; 
	    y <= 7'b0;
        end
        else begin
            if(ld_x)
                x <= ld_alu_out ? out_x : {1'b0, data_in}; // load alu_out if load_alu_out signal is high, otherwise load from data_in
            if(ld_y)
                y <= ld_alu_out ? out_y: data_in; // load alu_out if load_alu_out signal is high, otherwise load from data_in
	    if(ld_colour)
		colour <= data_colour[2:0];
        end
    end
 
    // Output result register
    always@(posedge clk) begin
        if(!resetn) begin
            x <= 8'b0; 
	    y <= 7'b0;
        end
        else 
            if(ld_r) begin
                x <= out_x;
		y <= out_y;
	end
    end

    always@(posedge clk) begin
        if(!resetn) begin
            result_x <= 8'b0; 
	    result_y <= 7'b0;
        end
        else 
		if(ld_r)
		    result_x <= out_x;
		    result_y <= out_y;
		    result_colour <= colour;
    end

    // The ALU input multiplexers
    always @(*)
    begin
        case (alu_select_x)
            2'd0:
                alu_x = x;
            2'd1:
                alu_x = y;
            default: alu_x = 8'b0;
        endcase

        case (alu_select_y)
            2'd0:
                alu_y = x;
            2'd1:
                alu_y = y;
            default: alu_y = 7'b0;
        endcase
    end


    // The ALU input multiplexers

    // The ALU 
    always @(*)
    begin : ALU
        // alu
        case (alu_op)
            0: begin
                   out_x = alu_x + 8'd1; //performs addition to x
               end
            1: begin
                   out_y = alu_y + 7'd1; //performs addition to y and reduces x
		   out_x = alu_x - 8'd4;
               end
            default: alu_out = 8'b0;
        endcase
    end
endmodule
