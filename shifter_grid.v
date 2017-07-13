module shifter_grid(reset, shoot, clock, Q, player_x, enemy_x);
    input reset; // reset the grid from SW[2]
    input shoot; // shoot input from SW[1]
    input clock; // default 50mhz clock input
    input [7:0]player_x; // players position on the x plane
    input [7:0]player_y; // players position on the y plane

    output reg [160:0]Q[120:0]; // 2d grid we're doing logic on

	wire load_val[120:0] = 120'b0;
    load_val[player_x] = 1'b1;
    
	wire [27:0]rd_1hz_out;
	rate_divider rd_1hz(
		.enable(1'b1),
		.countdown_start(28'b10111110101111000001111111), // 49,999,99 in dec
		.clock(clock),
		.reset(reset),
		.q(rd_1hz_out)
	);
	
	wire shift_right_clock = (rd_1hz_out == 28'b0) ? 1:0;


  	shifter shift(
            .load_val({load_val[0], 159'b0}),
            .load_n(1'b1),
            .shift_right(1'b1),
            .ASR(1'b0),
            .clk(shift_right_clock),
            .reset_n(reset),
            .Q(Q[0]));


endmodule


module lab_3(SW, LEDR, KEY);
  input [9:0] SW; // use SW[7:0] as inputs ffor LoadVal[7:0] and SW[9]  as the reset
  input [3:0] KEY; // use KEY[1] as Load_n input, KEY[2] as ShiftRight input,  KEY[3] as ASR input, and KEY[0] as clock
  output [9:0] LEDR; // outputs Q[7:0] from shifterbit should be displayed on LEDR[7:0]

  wire [7:0]Q;
  
  shifter shift(
            .load_val(SW[7:0]),
            .load_n(KEY[1]),
            .shift_right(~KEY[2]),
            .ASR(~KEY[3]),
            .clk(KEY[0]),
            .reset_n(~SW[9]),
            .Q(Q));
 
  assign LEDR = {2'b00, Q}; // concatenate 2 zero's to Q for LEDR[8], LEDR[9]
  
endmodule


module mux2to1(x, y, s, m);
  input x; // first value to choose from
  input y; // second value to choose from
  input s; // signal uses to determine which value to output
  output m; // where to store selection
  
  assign m = s & y | ~s & x;
  

endmodule

module flipflop(d, q, clock, reset_n);
   // note: that this is a 1 bit register
    input d;
    input clock, reset_n;
    output reg q;
    
    always @(posedge clock) // Triggered every time clock rises
    begin
        if(reset_n == 1'b0) // When reset_n is 0 (note this is tested on every rising clock edge)
            q <= 0;               // q is set to 0. Note that the assignment uses <= since this isn't a combintorial circuit
        else                      // when reset_n is not 0
            q <= d;           // value of d passes through to output q
    end
endmodule

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

module shifter(load_val, load_n, shift_right, ASR, clk, reset_n, Q);
  input [7:0]load_val; // input given from sW[7:0]
  input load_n; // global load_n value for all shifter bits, indicates whether to load values from load_val into each shifter bit
  input shift_right; // global shift value for all shifter bits, indicates to shift bits value to next shifter_bit
  input ASR; // determine if we are to perform sign extension; i.e. 101 (-1 signed) -> 110 (-2 signed), instead of 101 (6 unsigned) -> 010 (2 unsigned)
  input clk; // global clock to use for all of our flip flops
  input reset_n; // global reset_n value for all our flip fops in shifter_bits, which sets their output/value to 0
  
  output [7:0]Q; // output register (generally LEDR[7:0]) we're to show value of shifter on
  
  wire [7:0]sb_out;
  
  shifter_bit sb_7(.in(ASR), .load_val(load_val[7]), .shift(shift_right), .load_n(load_n), .clk(clk), .reset_n(reset_n), .out(sb_out[7]) );
  shifter_bit sb_6(.in(sb_out[7]), .load_val(load_val[6]), .shift(shift_right), .load_n(load_n), .clk(clk), .reset_n(reset_n), .out(sb_out[6]) );
  shifter_bit sb_5(.in(sb_out[6]), .load_val(load_val[5]), .shift(shift_right), .load_n(load_n), .clk(clk), .reset_n(reset_n), .out(sb_out[5]) );
  shifter_bit sb_4(.in(sb_out[5]), .load_val(load_val[4]), .shift(shift_right), .load_n(load_n), .clk(clk), .reset_n(reset_n), .out(sb_out[4]) );
  shifter_bit sb_3(.in(sb_out[4]), .load_val(load_val[3]), .shift(shift_right), .load_n(load_n), .clk(clk), .reset_n(reset_n), .out(sb_out[3]) );
  shifter_bit sb_2(.in(sb_out[3]), .load_val(load_val[2]), .shift(shift_right), .load_n(load_n), .clk(clk), .reset_n(reset_n), .out(sb_out[2]) );
  shifter_bit sb_1(.in(sb_out[2]), .load_val(load_val[1]), .shift(shift_right), .load_n(load_n), .clk(clk), .reset_n(reset_n), .out(sb_out[1]) );
  shifter_bit sb_0(.in(sb_out[1]), .load_val(load_val[0]), .shift(shift_right), .load_n(load_n), .clk(clk), .reset_n(reset_n), .out(sb_out[0]) );

  assign Q = sb_out[7:0];
  
  
endmodule

