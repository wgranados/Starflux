module hex(HEX0, HEX1, HEX2, HEX3, HEX4, HEX5, HEX6, HEX7, KEY, SW, load_all_time, load_score,CLOCK_50,LEDR, LEDG);
	output [6:0] HEX0, HEX1, HEX2, HEX3, HEX4, HEX5, HEX6, HEX7;
	input [3:0] KEY;
	output [17:9] LEDR;
	output [8:0] LEDG;
	input [7:0] load_all_time; // all time score.
	input [7:0] load_score;
	input [3:0] SW;	
	input CLOCK_50;
	all_time a(.hex0(HEX0), .hex1(HEX1), .load_current_score(8'b00000101) , .resetn(KEY[0]), .clk(~KEY[1]));
	current_score c(.hex2(HEX2), .hex3(HEX3),.resetn(KEY[0]), .clk(~KEY[3]));
	health h(.hex6(HEX6), .hex7(HEX7), .clk(~KEY[2]), .resetn(KEY[0]));
	gameover g(.ledr(LEDR), .ledg(LEDG), .clk(CLOCK_50), .resetn(KEY[0]) );
endmodule

module all_time(hex0, hex1, load_current_score, resetn, clk);
	input [7:0] load_current_score;
	input resetn;
	input clk;
	output [6:0]hex0;
	output [6:0]hex1;
	reg [7:0] all_time;
	
	always@(posedge clk) begin
	        if(!resetn) begin
	            all_time <= 8'b0; 
	        end
	        else begin
					if(load_current_score > all_time)
						all_time <= load_current_score; // storing the all time score.
	        end
    	end
		hex_decoder h1(.hex_digit(all_time[7:4]), .segments(hex1)); // displaying it on the hexes.
		hex_decoder h0(.hex_digit(all_time[3:0]), .segments(hex0));
endmodule

module current_score(hex2, hex3, resetn, clk);
	output [6:0]hex2;
	output [6:0]hex3;
	input resetn;
	input clk;
	reg [7:0] current_score;
	
	always@(posedge clk) begin
	        if(!resetn) begin
	            current_score <= 8'b0; 
	        end
	        else begin
				current_score <= current_score + 1; // increasing the current score.
	        end
    	end
	hex_decoder h3(.hex_digit(current_score[7:4]), .segments(hex3)); // displaying it on the hexes.
	hex_decoder h2(.hex_digit(current_score[3:0]), .segments(hex2));
endmodule

module gameover(ledr, ledg, clk, resetn);
	output [17:0]ledr;
	output [8:0] ledg;
	input clk;
	input resetn;
	reg [17:0] redout;
	reg [8:0] greenout;
	always@(posedge clk) begin
		if(!resetn) begin
			redout <= 18'b0;
			greenout <= 9'b0;
		end
		else begin
			case (redout)
				18'b0:
				begin
					redout <= 18'b101010101010101010;
					greenout <= 9'b101010101;
				end
				18'b101010101010101010:
				begin
					redout <= 18'b100010001000100010;
					greenout <= 9'b100010001;
				18'100010001000100010:
					redout <= 18'b100000001000000010;
					greenout <= 9'b100000001;
				18'10000000100000001:
					redout <= 18'b0;
					greenout <= 9'b0;
				default: 
				begin 
					redout <= 18'b0;
					greenout <= 9'b0;
				end
	end
	assign ledr = redout;
	assign ledg = greenout;
endmodule



module health(hex6, hex7, clk, resetn);
	output [6:0]hex6;
	output [6:0]hex7;
	input clk;
	input resetn;
	reg [7:0] health;
	
	always@(posedge clk) begin
		if(!resetn) begin
	            health <= 8'b1111_1111; // setting health to F.
	        end
	        else begin
			casez(health)
				 8'b0:
					health <= 8'b1111_1111; // increasing the current score.
				 8'b????????:
					health <= health - 1;
				default:
					health <= 8'b1111_1111;
	        end
    	end
	hex_decoder h7(.hex_digit(health[7:4]), .segments(hex7)); // displaying it on the hexes.
	hex_decoder h6(.hex_digit(health[3:0]), .segments(hex6));
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
	

