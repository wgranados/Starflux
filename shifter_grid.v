module shifter_grid(startGameEn, shoot, clock, gridUpdateEn, user_x, enemy_x, grid);
    input startGameEn; // reset the grid from SW[2]
    input shoot; // shoot input from SW[1]
    input clock; // default 50mhz clock input
	 input gridUpdateEn;
    input [7:0]user_x; // player's position on the x plane
	 input [7:0]enemy_x; // enemy's position on the x plane

    output [160*120-1:0]grid; // 2d grid we're doing logic on, interperet it as paritions of 120
	 
	 
	 // lets try slowing down the shifter bit
	 wire [27:0]rd_1hz_out; 
	 rate_divider rd_1hz(
		.enable(1'b1),
		.countdown_start(28'd3_125_000),
		.clock(clock),
		.reset(startGameEn),
		.q(rd_1hz_out)
	 );
	 

	 wire shift_right_enable = rd_1hz_out == 28'b0 ? 1'b1 : 1'b0;
	 
	 // generate 160 shifter bit lines, each consisting of 
	 // 120 shifter bits.
	 genvar i;
	 generate

		 for(i = 0;i < 160;i = i+1) begin: shifter_grids
				shifter shift_i(
					// only load_val value we care about is at the first shifter bit
					.load_val(user_x == i & shoot),
					.load_n(shoot),
					.shift_right(shift_right_enable),
					.ASR(1'b0),
					.clk(clock),
					.reset_n(startGameEn),
					// interpret partitions like 0..120, 121...140, and
					// have the shifterbit logic be outputed on these parts
					// of the 2d grid 
					.Q(grid[120*(i+1)-1: 120*i])
				);
		 end
	 
	 endgenerate

endmodule

module mux2to1(x, y, s, m);
	input x; // first value to choose from
	input y; // second value to choose from
	input s; // signal uses to determine which value to output
	output m; // where to store selection
  
   // s = 1'b0 => x
	// s = 1'b1 => y
	assign m = s & y | ~s & x;

endmodule

module flipflop(d, q, clock, reset_n);
   // note: that this is a 1 bit register
    input d; // input d we're going to store in our flip flop
    input clock; // clock input
	 input reset_n; // reset signal, synchronous high reset
    output reg q; // register value we're going to store values in
    
    always @(posedge clock) // Triggered every time clock rises
    begin
        if(reset_n == 1'b1) // When reset_n is 0 (note this is tested on every rising clock edge)
            q <= 0;               // q is set to 0. Note that the assignment uses <= since this isn't a combintorial circuit
        else                      // when reset_n is not 0
            q <= d;           // value of d passes through to output q
    end
endmodule

module shifter_bit(in, load_val, shift, load_n, ignore_load_n, clk, reset_n, out);
	// Note that these should all be 1 bit inputs as we're really only handling/storing one bit of information in shifter bit
	input in; // connected to out port of left shifter, 0 otherwise on left most shifter bit
	input load_val; // input given from switches, used onlywhen shift = 0
	input shift;  // indicates to shift all bits right 
	input load_n; // indicates to load input from switches
	input ignore_load_n; // ignore signal from load_n
	input clk;  // clock used for flip flop
	input reset_n;  // reset signal to set shifter bit's value to 0 
	output out; // output of value in shifter bit, generally sent to shifter bit on right
  
	wire mux_one_out, mux_two_out;

	wire load_val_decider = (load_n) & (~ignore_load_n); // if ignore_load_n is high we load values from mux_one_out
  
	// determine's whether to shift the bit or not
	mux2to1 mux_one(
		.x(out),
		.y(in),
		.s(shift),
		.m(mux_one_out)
	);
	// determine's whether to load the value from load_val or from in(from left shifter_bit)
	mux2to1 mux_two(
		.x(mux_one_out),
		.y(load_val),
		.s(load_val_decider),
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

module shifter(load_val, load_n, shift_right, ASR, clk, reset_n, Q);
	input load_val; // loadval to be loaded into first bit in shifter bit column
	input load_n; // global load_n value for all shifter bits, indicates whether to load values from load_val into each shifter bit
	input shift_right; // global shift value for all shifter bits, indicates to shift bits value to next shifter_bit
	input ASR; // determine if we are to perform sign extension; i.e. 101 (-1 signed) -> 110 (-2 signed), instead of 101 (6 unsigned) -> 010 (2 unsigned)
	input clk; // global clock to use for all of our flip flops
	input reset_n; // global reset_n value for all our flip fops in shifter_bits, which sets their output/value to 0
  
	output [120:0]Q; // output register (in this case grid, which is to be displayed on VGA) we're to show value of shifter on
  
	wire [120:0]sb_out;
  
	genvar i;
	generate
  
		for(i = 0;i <= 120;i = i+1) begin: shifter_bit_init
			  shifter_bit sb_i(
				  .in( (i == 0 ? ASR & load_val : sb_out[i-1]) ), 
				  .load_val(load_val), 
				  .shift(shift_right), 
				  .load_n(load_n), 
				  .ignore_load_n(~(i == 0)), // ignore load_n on every shifter bit but the first one at Q[0]
				  .clk(clk), 
				  .reset_n(reset_n), 
				  .out(sb_out[i]) 
			  );
		end

  
	endgenerate
  
	assign Q = sb_out[120:0];
  
  
endmodule
