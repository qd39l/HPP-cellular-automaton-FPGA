//----------------------------------
// M10K.v
//
// Description:
// The M10K module. This should be synthesized into an M10K block on the FPGA.
// Configuration is controlled by params.
//
// Source: https://people.ece.cornell.edu/land/courses/ece5760/DE1_SOC/Memory/index.html
//----------------------------------


module M10K         (output reg [9:0] q,
                     input [9:0] d,
                     input [9:0] write_address,
                     read_address,
                     input we,
                     clk);
    // force M10K ram style
    reg [9:0] mem [639:0]  /* synthesis ramstyle = "no_rw_check, M10K" */;
    always @ (posedge clk) begin
        if (we) begin
            mem[write_address] <= d;
        end
        q <= mem[read_address];
    end
    
endmodule
