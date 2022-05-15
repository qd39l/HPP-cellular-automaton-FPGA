//----------------------------------
// DE1_SoC_Computer.v
//
// Author: Kunpeng Huang (kh537), Owen Deng (qd39), Siqi Qian (sq85)
//
// Description: System integration
//
//----------------------------------

module DE1_SoC_Computer (CLOCK_50,
                         CLOCK2_50,
                         CLOCK3_50,
                         CLOCK4_50,
                         ADC_CS_N,
                         ADC_DIN,
                         ADC_DOUT,
                         ADC_SCLK,
                         AUD_ADCDAT,
                         AUD_ADCLRCK,
                         AUD_BCLK,
                         AUD_DACDAT,
                         AUD_DACLRCK,
                         AUD_XCK,
                         DRAM_ADDR,
                         DRAM_BA,
                         DRAM_CAS_N,
                         DRAM_CKE,
                         DRAM_CLK,
                         DRAM_CS_N,
                         DRAM_DQ,
                         DRAM_LDQM,
                         DRAM_RAS_N,
                         DRAM_UDQM,
                         DRAM_WE_N,
                         FPGA_I2C_SCLK,
                         FPGA_I2C_SDAT,
                         GPIO_0,
                         GPIO_1,
                         HEX0,
                         HEX1,
                         HEX2,
                         HEX3,
                         HEX4,
                         HEX5,
                         IRDA_RXD,
                         IRDA_TXD,
                         KEY,
                         LEDR,
                         PS2_CLK,
                         PS2_DAT,
                         PS2_CLK2,
                         PS2_DAT2,
                         SW,
                         TD_CLK27,
                         TD_DATA,
                         TD_HS,
                         TD_RESET_N,
                         TD_VS,
                         VGA_B,
                         VGA_BLANK_N,
                         VGA_CLK,
                         VGA_G,
                         VGA_HS,
                         VGA_R,
                         VGA_SYNC_N,
                         VGA_VS,
                         HPS_DDR3_ADDR,
                         HPS_DDR3_BA,
                         HPS_DDR3_CAS_N,
                         HPS_DDR3_CKE,
                         HPS_DDR3_CK_N,
                         HPS_DDR3_CK_P,
                         HPS_DDR3_CS_N,
                         HPS_DDR3_DM,
                         HPS_DDR3_DQ,
                         HPS_DDR3_DQS_N,
                         HPS_DDR3_DQS_P,
                         HPS_DDR3_ODT,
                         HPS_DDR3_RAS_N,
                         HPS_DDR3_RESET_N,
                         HPS_DDR3_RZQ,
                         HPS_DDR3_WE_N,
                         HPS_ENET_GTX_CLK,
                         HPS_ENET_INT_N,
                         HPS_ENET_MDC,
                         HPS_ENET_MDIO,
                         HPS_ENET_RX_CLK,
                         HPS_ENET_RX_DATA,
                         HPS_ENET_RX_DV,
                         HPS_ENET_TX_DATA,
                         HPS_ENET_TX_EN,
                         HPS_FLASH_DATA,
                         HPS_FLASH_DCLK,
                         HPS_FLASH_NCSO,
                         HPS_GSENSOR_INT,
                         HPS_GPIO,
                         HPS_I2C_CONTROL,
                         HPS_I2C1_SCLK,
                         HPS_I2C1_SDAT,
                         HPS_I2C2_SCLK,
                         HPS_I2C2_SDAT,
                         HPS_KEY,
                         HPS_LED,
                         HPS_SD_CLK,
                         HPS_SD_CMD,
                         HPS_SD_DATA,
                         HPS_SPIM_CLK,
                         HPS_SPIM_MISO,
                         HPS_SPIM_MOSI,
                         HPS_SPIM_SS,
                         HPS_UART_RX,
                         HPS_UART_TX,
                         HPS_CONV_USB_N,
                         HPS_USB_CLKOUT,
                         HPS_USB_DATA,
                         HPS_USB_DIR,
                         HPS_USB_NXT,
                         HPS_USB_STP);
    
    // ==  ==  ==  ==  ==  ==  ==  ==  ==  ==  ==  ==  ==  ==  ==  ==  ==  ==  ==  ==  ==  ==  ==  ==  ==  ==  ==  = 
    //  PARAMETER declarations
    // ==  ==  ==  ==  ==  ==  ==  ==  ==  ==  ==  ==  ==  ==  ==  ==  ==  ==  ==  ==  ==  ==  ==  ==  ==  ==  ==  = 
    
    
    // ==  ==  ==  ==  ==  ==  ==  ==  ==  ==  ==  ==  ==  ==  ==  ==  ==  ==  ==  ==  ==  ==  ==  ==  ==  ==  ==  = 
    //  PORT declarations
    // ==  ==  ==  ==  ==  ==  ==  ==  ==  ==  ==  ==  ==  ==  ==  ==  ==  ==  ==  ==  ==  ==  ==  ==  ==  ==  ==  = 
    
    ////////////////////////////////////
    // FPGA Pins
    ////////////////////////////////////
    
    // Clock pins
    input						CLOCK_50;
    input						CLOCK2_50;
    input						CLOCK3_50;
    input						CLOCK4_50;
    
    // ADC
    inout						ADC_CS_N;
    output					ADC_DIN;
    input						ADC_DOUT;
    output					ADC_SCLK;
    
    // Audio
    input						AUD_ADCDAT;
    inout						AUD_ADCLRCK;
    inout						AUD_BCLK;
    output					AUD_DACDAT;
    inout						AUD_DACLRCK;
    output					AUD_XCK;
    
    // SDRAM
    output 		[12: 0]	DRAM_ADDR;
    output		[1: 0]	DRAM_BA;
    output					DRAM_CAS_N;
    output					DRAM_CKE;
    output					DRAM_CLK;
    output					DRAM_CS_N;
    inout			[15: 0]	DRAM_DQ;
    output					DRAM_LDQM;
    output					DRAM_RAS_N;
    output					DRAM_UDQM;
    output					DRAM_WE_N;
    
    // I2C Bus for Configuration of the Audio and Video-In Chips
    output					FPGA_I2C_SCLK;
    inout						FPGA_I2C_SDAT;
    
    // 40-pin headers
    inout			[35: 0]	GPIO_0;
    inout			[35: 0]	GPIO_1;
    
    // Seven Segment Displays
    output		[6: 0]	HEX0;
    output		[6: 0]	HEX1;
    output		[6: 0]	HEX2;
    output		[6: 0]	HEX3;
    output		[6: 0]	HEX4;
    output		[6: 0]	HEX5;
    
    // IR
    input						IRDA_RXD;
    output					IRDA_TXD;
    
    // Pushbuttons
    input			[3: 0]	KEY;
    
    // LEDs
    output		[9: 0]	LEDR;
    
    // PS2 Ports
    inout						PS2_CLK;
    inout						PS2_DAT;
    
    inout						PS2_CLK2;
    inout						PS2_DAT2;
    
    // Slider Switches
    input			[9: 0]	SW;
    
    // Video-In
    input						TD_CLK27;
    input			[7: 0]	TD_DATA;
    input						TD_HS;
    output					TD_RESET_N;
    input						TD_VS;
    
    // VGA
    output		[7: 0]	VGA_B;
    output					VGA_BLANK_N;
    output					VGA_CLK;
    output		[7: 0]	VGA_G;
    output					VGA_HS;
    output		[7: 0]	VGA_R;
    output					VGA_SYNC_N;
    output					VGA_VS;
    
    
    
    ////////////////////////////////////
    // HPS Pins
    ////////////////////////////////////
    
    // DDR3 SDRAM
    output		[14: 0]	HPS_DDR3_ADDR;
    output		[2: 0]  HPS_DDR3_BA;
    output					HPS_DDR3_CAS_N;
    output					HPS_DDR3_CKE;
    output					HPS_DDR3_CK_N;
    output					HPS_DDR3_CK_P;
    output					HPS_DDR3_CS_N;
    output		[3: 0]	HPS_DDR3_DM;
    inout			[31: 0]	HPS_DDR3_DQ;
    inout			[3: 0]	HPS_DDR3_DQS_N;
    inout			[3: 0]	HPS_DDR3_DQS_P;
    output					HPS_DDR3_ODT;
    output					HPS_DDR3_RAS_N;
    output					HPS_DDR3_RESET_N;
    input						HPS_DDR3_RZQ;
    output					HPS_DDR3_WE_N;
    
    // Ethernet
    output					HPS_ENET_GTX_CLK;
    inout						HPS_ENET_INT_N;
    output					HPS_ENET_MDC;
    inout						HPS_ENET_MDIO;
    input						HPS_ENET_RX_CLK;
    input			[3: 0]	HPS_ENET_RX_DATA;
    input						HPS_ENET_RX_DV;
    output		[3: 0]	HPS_ENET_TX_DATA;
    output					HPS_ENET_TX_EN;
    
    // Flash
    inout			[3: 0]	HPS_FLASH_DATA;
    output					HPS_FLASH_DCLK;
    output					HPS_FLASH_NCSO;
    
    // Accelerometer
    inout						HPS_GSENSOR_INT;
    
    // General Purpose I/O
    inout			[1: 0]	HPS_GPIO;
    
    // I2C
    inout						HPS_I2C_CONTROL;
    inout						HPS_I2C1_SCLK;
    inout						HPS_I2C1_SDAT;
    inout						HPS_I2C2_SCLK;
    inout						HPS_I2C2_SDAT;
    
    // Pushbutton
    inout						HPS_KEY;
    
    // LED
    inout						HPS_LED;
    
    // SD Card
    output					HPS_SD_CLK;
    inout						HPS_SD_CMD;
    inout			[3: 0]	HPS_SD_DATA;
    
    // SPI
    output					HPS_SPIM_CLK;
    input						HPS_SPIM_MISO;
    output					HPS_SPIM_MOSI;
    inout						HPS_SPIM_SS;
    
    // UART
    input						HPS_UART_RX;
    output					HPS_UART_TX;
    
    // USB
    inout						HPS_CONV_USB_N;
    input						HPS_USB_CLKOUT;
    inout			[7: 0]	HPS_USB_DATA;
    input						HPS_USB_DIR;
    input						HPS_USB_NXT;
    output					HPS_USB_STP;
    
    // ==  ==  ==  ==  ==  ==  ==  ==  ==  ==  ==  ==  ==  ==  ==  ==  ==  ==  ==  ==  ==  ==  ==  ==  ==  ==  ==  = 
    //  REG/WIRE declarations
    // ==  ==  ==  ==  ==  ==  ==  ==  ==  ==  ==  ==  ==  ==  ==  ==  ==  ==  ==  ==  ==  ==  ==  ==  ==  ==  ==  = 
    
    wire			[15: 0]	hex3_hex0;
    
    assign HEX4 = 7'b1111111;
    assign HEX5 = 7'b1111111;
    
    HexDigit Digit0(HEX0, hex3_hex0[3:0]);
    HexDigit Digit1(HEX1, hex3_hex0[7:4]);
    HexDigit Digit2(HEX2, hex3_hex0[11:8]);
    HexDigit Digit3(HEX3, hex3_hex0[15:12]);
    
    // ==  ==  ==  ==  ==  ==  ==  ==  ==  ==  ==  ==  ==  ==  ==  ==  ==  ==  ==  ==  ==  ==  ==  ==  ==  ==  ==  = 
    //  WIRE
    // ==  ==  ==  ==  ==  ==  ==  ==  ==  ==  ==  ==  ==  ==  ==  ==  ==  ==  ==  ==  ==  ==  ==  ==  ==  ==  ==  = 
    
    // CLK and reset
    wire myCLOCK25;
    wire hpp_reset, vga_driver_reset, pause_animation, artist_mode;
    assign hpp_reset = (~KEY[0]) ? 1'b0 : 1'b1;
    assign pause_animation = (~KEY[1]) ? 1'b1 : 1'b0;
    assign artist_mode = (~KEY[2]) ? 1'b1 : 1'b0;
    assign resize_mode = (~KEY[3]) ? 1'b1 : 1'b0;
    
    // connection from vga driver module
    wire [9:0] next_x;
    wire [9:0] next_y;
    wire [4:0] grid_info;
	 wire enter_v_front;

    wire [31:0] ptr_x_lo, ptr_x_hi, ptr_y_lo, ptr_y_hi, mouse_action, mouse_trigger;
    
    // LED sanity check
    assign LEDR = {mouse_action[1:0], mouse_trigger[0], 7'd0};
    
    // ==  ==  ==  ==  ==  ==  ==  ==  ==  ==  ==  ==  ==  ==  ==  ==  ==  ==  ==  ==  ==  ==  ==  ==  ==  ==  ==  = 
    //  TOP module
    // ==  ==  ==  ==  ==  ==  ==  ==  ==  ==  ==  ==  ==  ==  ==  ==  ==  ==  ==  ==  ==  ==  ==  ==  ==  ==  ==  = 
    automata_fsm hpp_simulation (
    .clk(CLOCK_50),
    .reset(hpp_reset),
    .reset_vga(vga_driver_reset),
    .pause_animation(pause_animation),
    .switch(SW),
    .artist_mode(artist_mode),
    .resize_mode(resize_mode),
	.enter_v_front(enter_v_front),
    .next_x(next_x),
    .next_y(next_y),
	.grid_info(grid_info),
    .mouse_action(mouse_action[1:0]),
    .mouse_trigger(mouse_trigger[0]),
    .ptr_x_lo(ptr_x_lo[9:0]),
    .ptr_x_hi(ptr_x_hi[9:0]),
    .ptr_y_lo(ptr_y_lo[8:0] >> 1),
    .ptr_y_hi(ptr_y_hi[8:0] >> 1)
    );
    
    // ==  ==  ==  ==  ==  ==  ==  ==  ==  ==  ==  ==  ==  ==  ==  ==  ==  ==  ==  ==  ==  ==  ==  ==  ==  ==  ==  = 
    //  VGA module
    // ==  ==  ==  ==  ==  ==  ==  ==  ==  ==  ==  ==  ==  ==  ==  ==  ==  ==  ==  ==  ==  ==  ==  ==  ==  ==  ==  = 
    vga_driver my_vga_driver (
    .clock(myCLOCK25),            // 25 MHz
    .reset(vga_driver_reset),     // Active high
    .grid_info(grid_info),
    .enter_v_front(enter_v_front),
	.next_x(next_x),              // X-coordinate (range [0, 639]) of next pixel to be drawn
    .next_y(next_y),              // Y-coordinate (range [0, 479]) of next pixel to be drawn
    .hsync(VGA_HS),               // All of the connections to the VGA screen below
    .vsync(VGA_VS),
    .red(VGA_R),
    .green(VGA_G),
    .blue(VGA_B),
    .sync(VGA_SYNC_N),
    .clk(VGA_CLK),
    .blank(VGA_BLANK_N),
    .ptr_x_lo(ptr_x_lo[9:0]),
    .ptr_x_hi(ptr_x_hi[9:0]),
    .ptr_y_lo(ptr_y_lo[9:0]),
    .ptr_y_hi(ptr_y_hi[9:0])
    );
    
    
    // ==  ==  ==  ==  ==  ==  ==  ==  ==  ==  ==  ==  ==  ==  ==  ==  ==  ==  ==  ==  ==  ==  ==  ==  ==  ==  ==  = 
    //  Structural coding
    // ==  ==  ==  ==  ==  ==  ==  ==  ==  ==  ==  ==  ==  ==  ==  ==  ==  ==  ==  ==  ==  ==  ==  ==  ==  ==  ==  = 
    
    Computer_System The_System (
    ////////////////////////////////////
    // FPGA Side
    ////////////////////////////////////
    
    // Global signals
    .system_pll_ref_clk_clk			    (CLOCK_50),
    .system_pll_ref_reset_reset			 (1'b0),
    
    // PLL
    .pll_0_outclk0_clk                  (myCLOCK25),
    .pll_0_refclk_clk                   (CLOCK_50),

    // PIO
    .ptr_x_hi_external_connection_export (ptr_x_hi), // ptr_x_hi_external_connection.export
    .ptr_x_lo_external_connection_export (ptr_x_lo), // ptr_x_lo_external_connection.export
    .ptr_y_hi_external_connection_export (ptr_y_hi), // ptr_y_hi_external_connection.export
    .ptr_y_lo_external_connection_export (ptr_y_lo),
    .mouse_action_external_connection_export (mouse_action),
    .mouse_trigger_external_connection_export (mouse_trigger),
    

    ////////////////////////////////////
    // HPS Side
    ////////////////////////////////////
    // DDR3 SDRAM
    .memory_mem_a			(HPS_DDR3_ADDR),
    .memory_mem_ba			(HPS_DDR3_BA),
    .memory_mem_ck			(HPS_DDR3_CK_P),
    .memory_mem_ck_n		(HPS_DDR3_CK_N),
    .memory_mem_cke		(HPS_DDR3_CKE),
    .memory_mem_cs_n		(HPS_DDR3_CS_N),
    .memory_mem_ras_n		(HPS_DDR3_RAS_N),
    .memory_mem_cas_n		(HPS_DDR3_CAS_N),
    .memory_mem_we_n		(HPS_DDR3_WE_N),
    .memory_mem_reset_n	(HPS_DDR3_RESET_N),
    .memory_mem_dq			(HPS_DDR3_DQ),
    .memory_mem_dqs		(HPS_DDR3_DQS_P),
    .memory_mem_dqs_n		(HPS_DDR3_DQS_N),
    .memory_mem_odt		(HPS_DDR3_ODT),
    .memory_mem_dm			(HPS_DDR3_DM),
    .memory_oct_rzqin		(HPS_DDR3_RZQ),
    
    // Ethernet
    .hps_io_hps_io_gpio_inst_GPIO35	(HPS_ENET_INT_N),
    .hps_io_hps_io_emac1_inst_TX_CLK	(HPS_ENET_GTX_CLK),
    .hps_io_hps_io_emac1_inst_TXD0	(HPS_ENET_TX_DATA[0]),
    .hps_io_hps_io_emac1_inst_TXD1	(HPS_ENET_TX_DATA[1]),
    .hps_io_hps_io_emac1_inst_TXD2	(HPS_ENET_TX_DATA[2]),
    .hps_io_hps_io_emac1_inst_TXD3	(HPS_ENET_TX_DATA[3]),
    .hps_io_hps_io_emac1_inst_RXD0	(HPS_ENET_RX_DATA[0]),
    .hps_io_hps_io_emac1_inst_MDIO	(HPS_ENET_MDIO),
    .hps_io_hps_io_emac1_inst_MDC		(HPS_ENET_MDC),
    .hps_io_hps_io_emac1_inst_RX_CTL	(HPS_ENET_RX_DV),
    .hps_io_hps_io_emac1_inst_TX_CTL	(HPS_ENET_TX_EN),
    .hps_io_hps_io_emac1_inst_RX_CLK	(HPS_ENET_RX_CLK),
    .hps_io_hps_io_emac1_inst_RXD1	(HPS_ENET_RX_DATA[1]),
    .hps_io_hps_io_emac1_inst_RXD2	(HPS_ENET_RX_DATA[2]),
    .hps_io_hps_io_emac1_inst_RXD3	(HPS_ENET_RX_DATA[3]),
    
    // Flash
    .hps_io_hps_io_qspi_inst_IO0	(HPS_FLASH_DATA[0]),
    .hps_io_hps_io_qspi_inst_IO1	(HPS_FLASH_DATA[1]),
    .hps_io_hps_io_qspi_inst_IO2	(HPS_FLASH_DATA[2]),
    .hps_io_hps_io_qspi_inst_IO3	(HPS_FLASH_DATA[3]),
    .hps_io_hps_io_qspi_inst_SS0	(HPS_FLASH_NCSO),
    .hps_io_hps_io_qspi_inst_CLK	(HPS_FLASH_DCLK),
    
    // Accelerometer
    .hps_io_hps_io_gpio_inst_GPIO61	(HPS_GSENSOR_INT),
    
    // General Purpose I/O
    .hps_io_hps_io_gpio_inst_GPIO40	(HPS_GPIO[0]),
    .hps_io_hps_io_gpio_inst_GPIO41	(HPS_GPIO[1]),
    
    // I2C
    .hps_io_hps_io_gpio_inst_GPIO48	(HPS_I2C_CONTROL),
    .hps_io_hps_io_i2c0_inst_SDA		(HPS_I2C1_SDAT),
    .hps_io_hps_io_i2c0_inst_SCL		(HPS_I2C1_SCLK),
    .hps_io_hps_io_i2c1_inst_SDA		(HPS_I2C2_SDAT),
    .hps_io_hps_io_i2c1_inst_SCL		(HPS_I2C2_SCLK),
    
    // Pushbutton
    .hps_io_hps_io_gpio_inst_GPIO54	(HPS_KEY),
    
    // LED
    .hps_io_hps_io_gpio_inst_GPIO53	(HPS_LED),
    
    // SD Card
    .hps_io_hps_io_sdio_inst_CMD	(HPS_SD_CMD),
    .hps_io_hps_io_sdio_inst_D0	(HPS_SD_DATA[0]),
    .hps_io_hps_io_sdio_inst_D1	(HPS_SD_DATA[1]),
    .hps_io_hps_io_sdio_inst_CLK	(HPS_SD_CLK),
    .hps_io_hps_io_sdio_inst_D2	(HPS_SD_DATA[2]),
    .hps_io_hps_io_sdio_inst_D3	(HPS_SD_DATA[3]),
    
    // SPI
    .hps_io_hps_io_spim1_inst_CLK		(HPS_SPIM_CLK),
    .hps_io_hps_io_spim1_inst_MOSI	(HPS_SPIM_MOSI),
    .hps_io_hps_io_spim1_inst_MISO	(HPS_SPIM_MISO),
    .hps_io_hps_io_spim1_inst_SS0		(HPS_SPIM_SS),
    
    // UART
    .hps_io_hps_io_uart0_inst_RX	(HPS_UART_RX),
    .hps_io_hps_io_uart0_inst_TX	(HPS_UART_TX),
    
    // USB
    .hps_io_hps_io_gpio_inst_GPIO09	(HPS_CONV_USB_N),
    .hps_io_hps_io_usb1_inst_D0		(HPS_USB_DATA[0]),
    .hps_io_hps_io_usb1_inst_D1		(HPS_USB_DATA[1]),
    .hps_io_hps_io_usb1_inst_D2		(HPS_USB_DATA[2]),
    .hps_io_hps_io_usb1_inst_D3		(HPS_USB_DATA[3]),
    .hps_io_hps_io_usb1_inst_D4		(HPS_USB_DATA[4]),
    .hps_io_hps_io_usb1_inst_D5		(HPS_USB_DATA[5]),
    .hps_io_hps_io_usb1_inst_D6		(HPS_USB_DATA[6]),
    .hps_io_hps_io_usb1_inst_D7		(HPS_USB_DATA[7]),
    .hps_io_hps_io_usb1_inst_CLK		(HPS_USB_CLKOUT),
    .hps_io_hps_io_usb1_inst_STP		(HPS_USB_STP),
    .hps_io_hps_io_usb1_inst_DIR		(HPS_USB_DIR),
    .hps_io_hps_io_usb1_inst_NXT		(HPS_USB_NXT)
    );
    
    
endmodule
