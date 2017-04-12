`timescale 1 ns / 1 ps
`default_nettype none
    
	module sevenseg_controller_v1_0 #
	(
		// Users to add parameters here

		// User parameters ends
		// Do not modify the parameters beyond this line


		// Parameters of Axi Slave Bus Interface S00_AXI
		parameter integer C_S00_AXI_DATA_WIDTH	= 32,
		parameter integer C_S00_AXI_ADDR_WIDTH	= 4
	)
	(
		// Users to add ports here
         inout wire [8:0] anodes_out,
         inout wire [5:0] kathodes_out,
         
		// User ports ends
		// Do not modify the ports beyond this line


		// Ports of Axi Slave Bus Interface S00_AXI
		input wire  s00_axi_aclk,
		input wire  s00_axi_aresetn,
		input wire [C_S00_AXI_ADDR_WIDTH-1 : 0] s00_axi_awaddr,
		input wire [2 : 0] s00_axi_awprot,
		input wire  s00_axi_awvalid,
		output wire  s00_axi_awready,
		input wire [C_S00_AXI_DATA_WIDTH-1 : 0] s00_axi_wdata,
		input wire [(C_S00_AXI_DATA_WIDTH/8)-1 : 0] s00_axi_wstrb,
		input wire  s00_axi_wvalid,
		output wire  s00_axi_wready,
		output wire [1 : 0] s00_axi_bresp,
		output wire  s00_axi_bvalid,
		input wire  s00_axi_bready,
		input wire [C_S00_AXI_ADDR_WIDTH-1 : 0] s00_axi_araddr,
		input wire [2 : 0] s00_axi_arprot,
		input wire  s00_axi_arvalid,
		output wire  s00_axi_arready,
		output wire [C_S00_AXI_DATA_WIDTH-1 : 0] s00_axi_rdata,
		output wire [1 : 0] s00_axi_rresp,
		output wire  s00_axi_rvalid,
		input wire  s00_axi_rready
	);
	
	wire [1:0] mode;
	
	wire [15:0] bcd_values;
	
	wire [14:0] bitmap_values;
	
	
    wire [31:0] seconds_period; 
    wire [31:0] colon_period;
    wire set_time;
    wire time12or24;
    wire [7:0] set_hours, set_minutes, set_seconds;
    wire [7:0] curr_hours, curr_minutes, curr_seconds;
    
    
	
// Instantiation of Axi Bus Interface S00_AXI
	sevenseg_controller_v1_0_S00_AXI # ( 
		.C_S_AXI_DATA_WIDTH(C_S00_AXI_DATA_WIDTH),
		.C_S_AXI_ADDR_WIDTH(C_S00_AXI_ADDR_WIDTH)
	) sevenseg_controller_v1_0_S00_AXI_inst (
		.S_AXI_ACLK(s00_axi_aclk),
		.S_AXI_ARESETN(s00_axi_aresetn),
		.S_AXI_AWADDR(s00_axi_awaddr),
		.S_AXI_AWPROT(s00_axi_awprot),
		.S_AXI_AWVALID(s00_axi_awvalid),
		.S_AXI_AWREADY(s00_axi_awready),
		.S_AXI_WDATA(s00_axi_wdata),
		.S_AXI_WSTRB(s00_axi_wstrb),
		.S_AXI_WVALID(s00_axi_wvalid),
		.S_AXI_WREADY(s00_axi_wready),
		.S_AXI_BRESP(s00_axi_bresp),
		.S_AXI_BVALID(s00_axi_bvalid),
		.S_AXI_BREADY(s00_axi_bready),
		.S_AXI_ARADDR(s00_axi_araddr),
		.S_AXI_ARPROT(s00_axi_arprot),
		.S_AXI_ARVALID(s00_axi_arvalid),
		.S_AXI_ARREADY(s00_axi_arready),
		.S_AXI_RDATA(s00_axi_rdata),
		.S_AXI_RRESP(s00_axi_rresp),
		.S_AXI_RVALID(s00_axi_rvalid),
		.S_AXI_RREADY(s00_axi_rready),

        // the mode selection
		.mode(mode),

        // bitmap
        .bitmap_values(bitmap_values),
        
        // bcd
        .bcd_values(bcd_values),
               
        // time control lines
        .seconds_period(seconds_period),
        .colon_period(colon_period),
        .set_time(set_time),
        .time12or24(time12or24),
        .set_hours(set_hours),
        .set_minutes(set_minutes),
        .set_seconds(set_seconds),
        .curr_hours(curr_hours),
        .curr_minutes(curr_minutes),
        .curr_seconds(curr_seconds)
	);

    wire reset;
    assign reset = ~s00_axi_aresetn;

    wire [15:0] selected_bcd_values;
    assign selected_bcd_values = (mode == 2'b10) ? bcd_values : { curr_hours, curr_minutes };
        
    wire [8:0] bcd_anodes;
    wire [5:0] bcd_kathodes;
    
    bcd_controller bcd_control (
        .clk(s00_axi_aclk),
        .reset(reset),
        .bcd_values(selected_bcd_values),
        .kathodes(bcd_kathodes),
        .anodes(bcd_anodes)
        );
        
    
    wire [5:0] bitmap_kathodes;
    wire [8:0] bitmap_anodes;
    
    bitmap_controller bitmap_control (
                .clk(s00_axi_aclk),
                .reset(reset),
                .bitmap(bitmap_values),
                .kathodes(bitmap_kathodes),
                .anodes(bitmap_anodes)
             );        
        
    wire colon_out;
    timekeeper tk1 (
        .clk(s00_axi_aclk), .reset(reset),
        .seconds_period( seconds_period ),
        .colon_period(colon_period),
        
        .set_time( set_time ),
        .time12or24(time12or24),                 
        .hours_in( set_hours ),
        .minutes_in( set_minutes ),
        .seconds_in( set_seconds ),
        .hours_out(curr_hours),
        .minutes_out(curr_minutes),
        .seconds_out(curr_seconds),
        .colon_out(colon_out)
        
        );

    wire [5:0] selected_kathodes;
    wire [8:0] selected_anodes;
                 
   assign selected_kathodes = (mode == 2'b00) ? 6'bzz_zzzz :
                              (mode == 2'b01) ? bitmap_kathodes : bcd_kathodes;
                              
   assign selected_anodes =   (mode == 2'b00) ? 9'bz_zzzz_zzzz :
                              (mode == 2'b01) ? bitmap_anodes : bcd_anodes;        
    
        
    genvar bit;
    generate
        for (bit = 0; bit <= 8; bit = bit + 1)
        begin: ASSIGN_ANODES
            assign anodes_out[bit] = (selected_anodes[bit] == 1) ? 1'b0 : 1'bz;                                                                        
        end
    endgenerate
    
    generate
       for (bit = 0; bit <= 5; bit = bit + 1)
       begin: ASSIGN_KATHODES
            assign kathodes_out[bit] = (selected_kathodes[bit] == 1) ? 1'b0 : 1'bz;                                                                        
       end
    endgenerate
        
 endmodule
