module control(clk, reset, user_x, enemy_x, shipUpdateEn, gridUpdateEn, writeEn, gameOverEn, ship_health);
	input clk; // normal 50 Mhz clock passed by de2 board
	input reset; // reset signal given by SW[2] 
	input [3:0]ship_health; // stores the current ship's health.
	
	output reg [7:0]user_x;
	output reg [7:0]enemy_x; // ship positions on x axis
	output reg shipUpdateEn; // update the ship
	output reg gridUpdateEn; // update the grid
	output reg writeEn; // enable writes to vga output
	output reg gameOverEn; // enable output the ledg and ledr patterns
	

   reg [3:0] current_state, next_state; // state map for our FSM
	 
   localparam  S_START_GAME      = 5'd0,
               S_DRAW			   = 5'd1,
               S_UPDATE          = 5'd2,
               S_GAMEOVER        = 5'd3;

					
	 wire [27:0]rd_16hz_out; 
	 rate_divider rd_16hz(
			.enable(1'b1),
			.countdown_start(28'b1011111010111100001000), // 3,125,000 in dec
			.clock(clk),
			.reset(reset),
			.q(rd_16hz_out)
	 );
	 
	 wire go = (rd_16hz_out == 28'b0) ? 1:0;
				
	
  
    always@(*)
    begin: state_table
        case (current_state)
            S_START_GAME:      next_state = go ? S_DRAW: S_START_GAME;
            S_DRAW: 				 next_state = go ? S_UPDATE: S_UPDATE;
            S_UPDATE:          next_state = ((ship_health == 8'b0) ? S_GAMEOVER: (go ? S_DRAW : S_UPDATE));
				S_GAMEOVER:        next_state = go ? S_START_GAME:S_GAMEOVER;
            default:           next_state = S_START_GAME;
        endcase
    end 

	 
	 // Output logic to our datapath
	 // here we control when and what we're writing images to the vga screen
	 // and when we'll be be decide to update the grid and ship logic
    always @(*)
    begin: enable_signals
	 
	     writeEn = 1'b0;
		  shipUpdateEn = 1'b0;
		  gridUpdateEn = 1'b0;
		  gameOverEn = 1'b0;
		  
		  case (current_state)
            S_START_GAME: begin
					writeEn = 1'b1;
				end
            S_DRAW: begin
					writeEn = 1'b1;
            end
				S_UPDATE: begin
					shipUpdateEn = 1'b1;
					gridUpdateEn = 1'b1;
				end	
            S_GAMEOVER: begin
					gameOverEn = 1'b1;
				end		
        endcase
    end 

    always@(posedge clk)
    begin
        if(reset) begin
            current_state <= S_START_GAME;
				// reset both ships to start of the grid
				user_x <= 8'd80; 
				enemy_x <= 8'd80;
		  end
        else
				current_state <= next_state;
    end 

endmodule


