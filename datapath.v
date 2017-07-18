module datapath(clk, reset, colour_in, coord_in, user_x, enemy_x, ld_col, x_out, y_out, col_out);
					 
    input clk; // default 50mhz clock
    input reset; // value given from KEY[0]
    input [2:0] colour_in; // register value given from SW[9:7]
    input [6:0] coord_in; // regster value given from SW[6:0]
    input ld_x, ld_y, ld_col; // state values given from datapath 
    input enable; // write enable signal decided by datapath

    output [7:0]x_out;   // output  value for x to write to screen
    output [6:0]y_out;   // output value for  y to write to screen
    output [2:0]col_out; // output value for colour to write to screen

   

endmodule
