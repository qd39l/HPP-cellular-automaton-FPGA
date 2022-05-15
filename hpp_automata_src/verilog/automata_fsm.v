//----------------------------------
// automata_fsm.v
//
// Author: Kunpeng Huang (kh537), Owen Deng (qd39), Siqi Qian (sq85)
//
// Description: HPS code for mouse control and PIO communication. To be
// used with the HPP cellular automaton project.
//
//----------------------------------

module automata_fsm  (input clk,
                      input reset, // active low
                      input [9:0] switch,
                      input enter_v_front, // from VGA driver
                      input [9:0] next_x, // from VGA driver
                      input [9:0] next_y, // from VGA driver
                      input pause_animation, // from button
                      input artist_mode, // from button
                      input resize_mode, // from button
                      input [1:0] mouse_action, // HPS mouse signals
                      input mouse_trigger,
                      input [9:0] ptr_x_lo,
                      input [9:0] ptr_x_hi,
                      input [7:0] ptr_y_lo,
                      input [7:0] ptr_y_hi,
                      output reset_vga,
                      output [4:0] grid_info);
    
    wire [4:0] grid_info_arr [239:0];
    
    // used by the random number generator
    wire [63:0] random_seed;
    assign random_seed = 64'd12345678901234567;
    wire [15:0] rand_out; // random number at each clock cycle

    // ==  ==  ==  ==  ==  ==  ==  ==  ==  ==  ==  ==  ==  ==  ==  ==  ==  ==  ==  == 
    // PART 1: mux grid_info
    assign grid_info = grid_info_arr [next_y >> 1];
    
    wire pe_select;
    assign pe_select = next_y[0]; // this signal is visible to pe

    // ==  ==  ==  ==  ==  ==  ==  ==  ==  ==  ==  ==  ==  ==  ==  ==  ==  ==  ==  == 
    // PART 1.5: mux grid_info
    reg mouse_trigger_reg;
    reg [1:0] mouse_action_reg;

    always @(posedge clk) begin
        mouse_trigger_reg <= mouse_trigger;
        mouse_action_reg <= mouse_action;
    end

    // ==  ==  ==  ==  ==  ==  ==  ==  ==  ==  ==  ==  ==  ==  ==  ==  ==  ==  ==  == 
    // PART 2: Control FSM
    
    // FSM states
    parameter [4:0] RESET          = 0;
    parameter [4:0] INIT_MODE_SEL  = 1;
    parameter [4:0] INIT_URAND_1         = 2;
    parameter [4:0] INIT_COMM_2         = 3;
    parameter [4:0] INIT_RAIL_1    = 4;
    parameter [4:0] INIT_SQ_1    = 5;
    parameter [4:0] INIT_WALL_ONLY = 6;
    parameter [4:0] COLLISION_PREP = 7;
    parameter [4:0] COLLISION_PROCEED = 8;
    parameter [4:0] PROPAGATION_PREP1 = 9;
    parameter [4:0] PROPAGATION_PREP2 = 10;
    parameter [4:0] PROPAGATION_PROCEED = 11;
    parameter [4:0] MOUSE_TRIGGER_SEL = 12;
    parameter [4:0] ACTION_1 = 13;
    parameter [4:0] ACTION_COMM = 14;
    parameter [4:0] WAIT_VGA       = 15;
    
    // ==  ==  ==  ==  ==  ==  ==  ==  ==  ==  ==  ==  ==  ==  ==  ==  ==  ==  ==  == 
    // FSM START
    
    // state regs
    reg [4:0] state, state_next;
    
    // Sequential Always Block
    always @(posedge clk)
        begin: fsm_seq
        if (!reset) begin
            state <= RESET;
        end
        else begin// otherwise update the states
            state <= state_next;
        end
    end
    
    // Combinational Always Block
    reg [9:0] current_column;
    reg [7:0] init_row_idx;

    always @(state or current_column or init_row_idx or enter_v_front)
        begin: fsm_comb
        state_next = 5'bx;
        case(state)
            RESET: begin
                state_next = INIT_MODE_SEL;
            end

            INIT_MODE_SEL: begin
                if (switch[0]) begin
                    state_next = INIT_URAND_1;
                end else if (switch[1]) begin
                    state_next = INIT_RAIL_1;
                end else if (switch[2])begin
                    state_next = INIT_SQ_1;
                end else if (switch[2:0] == 3'd0)begin
                    state_next = INIT_WALL_ONLY;
                end
            end
            
            INIT_URAND_1: begin
                if (init_row_idx == 8'd239) begin
                    state_next = INIT_COMM_2;
                end else begin
                    state_next = state;
                end
            end

            INIT_COMM_2: begin
                if (current_column == 10'd639) begin
                    state_next = COLLISION_PREP;
                end else begin
                    if (switch[0]) begin
                        state_next = INIT_URAND_1;
                    end else if (switch[1]) begin
                        state_next = INIT_RAIL_1;
                    end else if (switch[2])begin
                        state_next = INIT_SQ_1;
                    end else if (switch[3:0] == 4'd0) begin
                        state_next = INIT_WALL_ONLY;
                    end
                end
            end

            INIT_RAIL_1: begin
                if (init_row_idx == 8'd239) begin
                    state_next = INIT_COMM_2;
                end else begin
                    state_next = state;
                end
            end

            INIT_WALL_ONLY: begin
                if (init_row_idx == 8'd239) begin
                    state_next = INIT_COMM_2;
                end else begin
                    state_next = state;
                end
            end

            INIT_SQ_1: begin
                if (init_row_idx == 8'd239) begin
                    state_next = INIT_COMM_2;
                end else begin
                    state_next = state;
                end
            end

            COLLISION_PREP: begin
                state_next = COLLISION_PROCEED;
            end

            COLLISION_PROCEED: begin
                if (current_column == 10'd639) begin
                    state_next = PROPAGATION_PREP1;
                end else begin
                    state_next = state;
                end
            end

            PROPAGATION_PREP1: begin
                state_next = PROPAGATION_PREP2;
            end

            PROPAGATION_PREP2: begin
                state_next = PROPAGATION_PROCEED;
            end

            PROPAGATION_PROCEED: begin
                if (current_column == 10'd639) begin
                    state_next = MOUSE_TRIGGER_SEL;
                end else begin
                    state_next = state;
                end
            end

            MOUSE_TRIGGER_SEL: begin
                if (mouse_trigger_reg && ~resize_mode) begin
                    state_next = ACTION_1;
                end else begin
                    state_next = WAIT_VGA;
                end
            end

            ACTION_1: begin
                if (init_row_idx == ptr_y_hi) begin
                    state_next = ACTION_COMM;
                end else begin
                    state_next = state;
                end
            end

            ACTION_COMM: begin
                if (current_column == ptr_x_hi) begin
                    state_next = WAIT_VGA;
                end else begin
                    state_next = ACTION_1;
                end
            end

            WAIT_VGA: begin
                if (enter_v_front && ~pause_animation) begin
                    state_next = COLLISION_PREP;
                end else begin
                    state_next = state;
                end
            end
        endcase
    end
    
    // FSM Output Generation (Reg)
    reg [9:0] init_val_arr [239:0];
    reg [3:0] init_val_counter;

    wire [9:0] non_wall_mask;
    assign non_wall_mask = 10'b0111101111;

    wire railgun_in_range;
    assign railgun_in_range = (init_row_idx >= 8'd100) && (init_row_idx < 8'd140) && (current_column <= 10'd160);

    reg halt_vga;

    reg [239:0] pe_we;

    always @(posedge clk)
        begin: fsm_out_reg_clk
        case (state)
            RESET: begin
                current_column <= 0;
                init_row_idx <= 0;
                init_val_counter <= 0;
                halt_vga <= 1;
                pe_we <= 240'd0;
            end

            INIT_URAND_1: begin
                if (init_row_idx == 8'd239) begin
                    init_row_idx <= 0;
                    pe_we <= {240{1'b1}};
                end else begin
                    init_row_idx <= init_row_idx + 1;
                end

                init_val_counter <= init_val_counter + 1;

                // need to take care of the walls
                init_val_arr[init_row_idx] <= (current_column == 10'd0 || current_column == 10'd639) ? 10'b10000_10000
                                            : (init_row_idx == 8'd239 || init_row_idx == 8'd0) ? 10'b10000_10000 
                                            : (rand_out[13:10] == 4'd0) ? (rand_out[9:0] & non_wall_mask)
                                            : 10'd0;
            end

            INIT_RAIL_1: begin
                if (init_row_idx == 8'd239) begin
                    init_row_idx <= 0;
                    pe_we <= {240{1'b1}};
                end else begin
                    init_row_idx <= init_row_idx + 1;
                end

                init_val_counter <= init_val_counter + 1;

                // need to take care of the walls
                init_val_arr[init_row_idx] <= (current_column == 10'd0 || current_column == 10'd639) ? 10'b10000_10000
                                            : (init_row_idx == 8'd239 || init_row_idx == 8'd0) ? 10'b10000_10000
                                            : (railgun_in_range && current_column >= 10'd120) ? 10'b00100_00100
                                            : (railgun_in_range && current_column >= 10'd80) ? (10'b00100_00100 & {10{rand_out[10]}})
                                            : (railgun_in_range && current_column >= 10'd40) ? (10'b00100_00100 & {10{(rand_out[11:10]==2'd0)}})
                                            : (railgun_in_range) ? (10'b00100_00100 & {10{(rand_out[12:10]==3'd0)}})
                                            : (current_column >= 10'd400 && current_column <= 10'd440 && (init_row_idx >= 8'd130 || init_row_idx <= 8'd110)) ? 10'b10000_10000
                                            : 10'd0;
            end

            INIT_WALL_ONLY: begin
                if (init_row_idx == 8'd239) begin
                    init_row_idx <= 0;
                    pe_we <= {240{1'b1}};
                end else begin
                    init_row_idx <= init_row_idx + 1;
                end

                init_val_counter <= init_val_counter + 1;

                // need to take care of the walls
                init_val_arr[init_row_idx] <= (current_column == 10'd0 || current_column == 10'd639) ? 10'b10000_10000
                                            : (init_row_idx == 8'd239 || init_row_idx == 8'd0) ? 10'b10000_10000
                                            : 10'd0;
            end

            INIT_SQ_1: begin
                if (init_row_idx == 8'd239) begin
                    init_row_idx <= 0;
                    pe_we <= {240{1'b1}};
                end else begin
                    init_row_idx <= init_row_idx + 1;
                end

                init_val_counter <= init_val_counter + 1;

                // need to take care of the walls
                init_val_arr[init_row_idx] <= (current_column == 10'd0 || current_column == 10'd639) ? 10'b10000_10000
                                            : (init_row_idx == 8'd239 || init_row_idx == 8'd0) ? 10'b10000_10000
                                            : (current_column >= 10'd200 && current_column <= 10'd440 && init_row_idx >= 8'd75 && init_row_idx <= 8'd165) ? (rand_out[9:0] & non_wall_mask & {10{rand_out[10]}})
                                            : 10'd0;
            end

            INIT_COMM_2: begin
                if (current_column == 10'd639) begin
                    current_column <= 0;
                end else begin
                    current_column <= current_column + 1;
                end
                pe_we <= {240{1'b0}};
            end

            COLLISION_PREP: begin
                pe_we <= {240{1'b1}};
            end

            COLLISION_PROCEED: begin
                if (current_column == 10'd639) begin
                    current_column <= 0;
                    pe_we <= {240{1'b0}};
                end else begin
                    current_column <= current_column + 1;
                end
            end

            PROPAGATION_PREP2: begin
                pe_we <= {240{1'b1}};
            end

            PROPAGATION_PROCEED: begin
                current_column <= current_column + 1;
            end

            MOUSE_TRIGGER_SEL: begin
                current_column <= ptr_x_lo;
                init_row_idx <= ptr_y_lo;
                pe_we <= {240{1'b0}};
            end

            ACTION_1: begin
                if (init_row_idx == ptr_y_hi) begin
                    init_row_idx <= ptr_y_lo;
                end else begin
                    init_row_idx <= init_row_idx + 1;
                end

                init_val_arr[init_row_idx] <= (mouse_action_reg == 2'd1 && switch[3]) ? 10'b00100_00100
                                            : (mouse_action_reg == 2'd1 && switch[4]) ? 10'b00001_00001
                                            : (mouse_action_reg == 2'd1 && switch[5]) ? 10'b01000_01000
                                            : (mouse_action_reg == 2'd1 && switch[6]) ? 10'b00010_00010
                                            : (mouse_action_reg == 2'd1 && switch[7]) ? 10'b01110_00111
                                            : (mouse_action_reg == 2'd1 && switch[8]) ? 10'b00101_01010
                                            : (mouse_action_reg == 2'd1 && switch[9]) ? 10'b01111_01111
                                            : (mouse_action_reg == 2'd2) ? 10'b00000_00000
                                            : (mouse_action_reg == 2'd3) ? 10'b10000_10000
                                            : 10'd0;
                pe_we[init_row_idx] <= 1'b1;
            end

            ACTION_COMM: begin
                if (current_column == ptr_x_hi) begin
                    current_column <= 0;
                    pe_we <= {240{1'b0}};
                end else begin
                    current_column <= current_column + 1;
                end
            end

            WAIT_VGA: begin
                current_column <= 0;
                init_row_idx <= 0;
                halt_vga <= 0;
                pe_we <= {240{1'b0}};
            end
        endcase
    end
    
    // FSM Output Generation (Wire)
    wire pe_reset;
    assign pe_reset = (state == WAIT_VGA) ? 1'b0 : 1'b1;

    wire [1:0] pe_mode;
    assign pe_mode = (state == INIT_URAND_1 || state == INIT_COMM_2 || state == INIT_RAIL_1 || state == INIT_SQ_1 || state == INIT_WALL_ONLY || state == ACTION_COMM) ? 0
                   : (state == WAIT_VGA) ? 1
                   : (state == COLLISION_PREP || state == COLLISION_PROCEED) ? 2
                   : (state == PROPAGATION_PREP1 || state == PROPAGATION_PREP2 || state == PROPAGATION_PROCEED) ? 3
                   : 1;

    wire [9:0] fsm_read_addr;
    assign fsm_read_addr = (state == COLLISION_PREP) ? 0
                         : (state == COLLISION_PROCEED) ? current_column + 1
                         : (state == PROPAGATION_PREP1) ? 0
                         : (state == PROPAGATION_PREP2) ? 1
                         : (state == PROPAGATION_PROCEED) ? current_column + 2
                         : (state == WAIT_VGA) ? next_x
                         : 0;

    assign reset_vga = halt_vga;

    // ==  ==  ==  ==  ==  ==  ==  ==  ==  ==  ==  ==  ==  ==  ==  ==  ==  ==  ==  == 
    // Create PEs
    wire [239:0] ain_arr, aout_arr, cin_arr, cout_arr;
    
    generate
    genvar i;
    for (i = 0; i < 240; i = i+1) begin: PE_array

    if (i == 0)
        pe pe_inst (
            // general signals
            .clk(clk),
            .reset(pe_reset), // should be reset after each propagation
            .mode(pe_mode),
            .artist_mode(artist_mode),

            // shared signals between modes
            .pe_we(pe_we[i]),
            .write_addr(current_column),
            .read_addr(fsm_read_addr),

            // init mode
            .init_val(init_val_arr[i]), // different pe has different arrays

            // vga mode
            .pe_select(pe_select),
            .vga_grid_info(grid_info_arr[i]),

            // interconnects
            .ain(ain_arr[i+1]),
            .cin(1'b0),
            .aout(ain_arr[i]),
            .cout(cin_arr[i])
        );

    else if (i == 239)
        pe pe_inst (
            // general signals
            .clk(clk),
            .reset(pe_reset), // should be reset after each propagation
            .mode(pe_mode),
            .artist_mode(artist_mode),

            // shared signals between modes
            .pe_we(pe_we[i]),
            .write_addr(current_column),
            .read_addr(fsm_read_addr),

            // init mode
            .init_val(init_val_arr[i]), // different pe has different arrays

            // vga mode
            .pe_select(pe_select),
            .vga_grid_info(grid_info_arr[i]),

            // interconnects
            .aout(ain_arr[i]),
            .cout(cin_arr[i]),
            .ain(1'b0),
            .cin(cin_arr[i-1])
        );

    else
        pe pe_inst (
            // general signals
            .clk(clk),
            .reset(pe_reset), // should be reset after each propagation
            .mode(pe_mode),
            .artist_mode(artist_mode),

            // shared signals between modes
            .pe_we(pe_we[i]),
            .write_addr(current_column),
            .read_addr(fsm_read_addr),

            // init mode
            .init_val(init_val_arr[i]), // different pe has different arrays

            // vga mode
            .pe_select(pe_select),
            .vga_grid_info(grid_info_arr[i]),

            // interconnects
            .aout(ain_arr[i]),
            .cout(cin_arr[i]),
            .ain(ain_arr[i+1]),
            .cin(cin_arr[i-1])
        );

    end
    
    endgenerate

    // instance of the random number generator
    rand63 random_mod (
        .clk(clk),
        .reset(reset), // connected to fsm reset
        .seed_in(random_seed),
        .rand_out(rand_out)
    );
endmodule

