module control(clk, reset, user_x, enemy_x, shipUpdateEn, gridUpdateEn, writeEn);
	input clk; // normal 50 Mhz clock passed by de2 board
	input reset; // reset signal given by SW[2] 
	
	output reg [7:0]user_x, [7:0]enemy_x; // ship positions on x axis
	output shipUpdateEn; // update the ship
	output gridUpdateEn; // update the grid
	output writeEn; // enable writes to vga output

   reg [3:0] current_state, next_state; // state map for our FSM
	 
   localparam  S_START_GAME      = 5'd0,
               S_DRAW_BACKGROUND = 5'd1,
               S_DRAW_SHIP       = 5'd2,
               S_DRAW_ENEMY      = 5'd3,
               S_DRAW_BULLETS    = 5'd4,
               S_UPDATE          = 5'd5;

					
	 wire [27:0]rd_2hz_out; 
	 rate_divider rd_2hz(
			.enable(1'b1),
			.countdown_start(28'b1011111010111100000111111), // 24,999,99 in dec
			.clock(clk),
			.reset(reset),
			.q(rd_2hz_out)
	 );
	 
	 wire go = (rd_2hz_out == 28'b0) ? 1:0;
				
	
  
    always@(*)
    begin
        case (current_state)
            S_START_GAME:      next_state = go ? S_DRAW_BACKGROUND: S_START_GAME;
            S_DRAW_BACKGROUND: next_state = go ? S_DRAW_SHIP: S_DRAW_BACKGROUND;
            S_DRAW_SHIP:       next_state = go ? S_DRAW_ENEMY: S_DRAW_SHIP;
            S_DRAW_ENEMY:      next_state = go ? S_DRAW_BULLETS: S_DRAW_ENEMY;
            S_DRAW_BULLETS:    next_state = go ? S_UPDATE: S_DRAW_BULLETS;
            S_UPDATE:          next_state = go ? S_DRAW_BACKGROUND: S_UPDATE;
            default:           next_state = S_START_GAME;
        endcase
    end 

	 
	 // Output logic to our datapath
	 // here we control when and what we're writing images to the vga screen
	 // and when we'll be be decide to update the grid and ship logic
    always @(*)
    begin
	 
	     writeEn = 1'b0;
		  shipUpdateEn = 1'b0;
		  shipUpdate = 1'b0;
		  
		  case (current_state)
            S_START_GAME: 		 writeEn = 1'b1;
            S_DRAW_BACKGROUND: writeEn = 1'b1;
            S_DRAW_SHIP: 		 writeEn = 1'b1;
            S_DRAW_ENEMY: 		 writeEn = 1'b1;
            S_DRAW_BULLETS: 	 writeEn = 1'b1;
            S_UPDATE: begin
					writeEn = 1'b1;
					shipUpdateEn = 1'b1;
					gridUpdateEn = 1'b1;
				end				
        endcase
    end 

    always@(posedge clk)
    begin
        if(!reset) begin
            current_state <= S_START_GAME;
				// reset both ships to start of the grid
				user_x <= 8'd80; 
				enemy_x <= 8'd80;
		  end
        else
            current_state <= next_state;
    end 

endmodule


