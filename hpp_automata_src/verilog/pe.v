//----------------------------------
// pe.v
//
// Author: Kunpeng Huang (kh537), Owen Deng (qd39), Siqi Qian (sq85)
//
// Description: A single PE. Please refer to our documentation.
//
//----------------------------------

module pe (
            // general signal
            input clk, reset, // active low
            input [1:0] mode,
            input artist_mode,

            // shared signals between modes
            input pe_we,
            input [9:0] write_addr,
            input [9:0] read_addr,

            // init mode
            input [9:0] init_val,

            // vga mode
            input pe_select,
            output [4:0] vga_grid_info,

            input ain, cin,
            output aout, cout);
    
    // pe modes
    parameter [1:0] INIT_MODE = 0;
    parameter [1:0] VGA_MODE = 1;
    parameter [1:0] COLLISION_MODE = 2;
    parameter [1:0] PROPAGATION_MODE = 3;

    // M10K variables
    wire [9:0] read_val;
    wire [9:0] write_val;

    wire [9:0] collision_state_next;

    pe_collision collision0 (
        .state(read_val[4:0]),
        .artist_mode(artist_mode),
        .state_next(collision_state_next[4:0])
    );

    pe_collision collision1 (
        .state(read_val[9:5]),
        .artist_mode(artist_mode),
        .state_next(collision_state_next[9:5])
    );

    wire [9:0] propagation_write_state;

    pe_propagation propogation (
        .clk(clk),
        .reset(reset),
        .right_state(read_val),
        .ain(ain),
        .cin(cin),
        .aout(aout),
        .cout(cout),
        .write_state(propagation_write_state)
    );

    M10K memory (
        .q(read_val),
        .d(write_val),
        .write_address(write_addr),
        .read_address(read_addr),
        .we(pe_we),
        .clk(clk)
    );

    assign vga_grid_info = read_val;
    
    assign write_val = (mode == INIT_MODE) ? (init_val)
                     : (mode == COLLISION_MODE) ? (collision_state_next)
                     : (mode == PROPAGATION_MODE) ? (propagation_write_state)
                     : 10'b0;
    
endmodule
