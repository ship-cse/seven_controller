`timescale 1 ns / 1 ps
`default_nettype none

module sim_bcdmode( );

reg clk;
initial begin
    clk = 0;
    forever begin
        clk = #5 ~clk;
    end
end

reg areset;
initial begin
    areset = 0;
    #100;
    areset = 1;
end
 
 wire [8:0] anodes_out;
 wire [5:0] kathodes_out;
                
wire  S_AXI_ACLK;
assign S_AXI_ACLK = clk;

wire  S_AXI_ARESETN;
assign S_AXI_ARESETN = areset;

// Write address (issued by master, acceped by Slave)
reg [3 : 0] S_AXI_AWADDR;       //tb

// Write channel Protection type. This signal indicates the
// privilege and security level of the transaction, and whether
// the transaction is a data access or an instruction access.
reg [2 : 0] S_AXI_AWPROT = 3'b0;  //tb

// Write address valid. This signal indicates that the master signaling
// valid write address and control information.
reg  S_AXI_AWVALID;         // tb

// Write address ready. This signal indicates that the slave is ready
// to accept an address and associated control signals.
wire  S_AXI_AWREADY;        // tb
		
// Write data (issued by master, acceped by Slave) 
reg [31 : 0] S_AXI_WDATA;

// Write strobes. This signal indicates which byte lanes hold
// valid data. There is one write strobe bit for each eight
// bits of the write data bus.    
reg [3 : 0] S_AXI_WSTRB;    // tb

// Write valid. This signal indicates that valid write
// data and strobes are available.
reg  S_AXI_WVALID;          // tb

// Write ready. This signal indicates that the slave
// can accept the write data.
wire  S_AXI_WREADY;     // tb

// Write response. This signal indicates the status
// of the write transaction.
wire [1 : 0] S_AXI_BRESP;       // tb - ignore

// Write response valid. This signal indicates that the channel
// is signaling a valid write response.
wire  S_AXI_BVALID;     // raised when done

// Response ready. This signal indicates that the master
// can accept a write response.
reg  S_AXI_BREADY;      //tb

// Read address (issued by master, acceped by Slave)
reg [3 : 0] S_AXI_ARADDR = 4'b0;

// Protection type. This signal indicates the privilege
// and security level of the transaction, and whether the
// transaction is a data access or an instruction access.
reg [2 : 0] S_AXI_ARPROT = 3'b0;

// Read address valid. This signal indicates that the channel
// is signaling valid read address and control information.
reg  S_AXI_ARVALID = 0;

// Read address ready. This signal indicates that the slave is
// ready to accept an address and associated control signals.
wire  S_AXI_ARREADY;

// Read data (issued by slave)
wire [31 : 0] S_AXI_RDATA = 32'd0;

// Read response. This signal indicates the status of the
// read transfer.

wire [1 : 0] S_AXI_RRESP;

// Read valid. This signal indicates that the channel is
// signaling the required read data.
wire  S_AXI_RVALID;

// Read ready. This signal indicates that the master can
// accept the read data and response information.
reg  S_AXI_RREADY = 1;
		
sevenseg_controller_v1_0 UUT
	(
	     .anodes_out(anodes_out),
	     .kathodes_out(kathodes_out),
                
                         
         // Ports of Axi Slave Bus Interface S00_AXI
         .s00_axi_aclk(S_AXI_ACLK),
         .s00_axi_aresetn(S_AXI_ARESETN),
         .s00_axi_awaddr(S_AXI_AWADDR),
         .s00_axi_awprot(S_AXI_AWPROT),
         .s00_axi_awvalid(S_AXI_AWVALID),
         .s00_axi_awready(S_AXI_AWREADY),
         .s00_axi_wdata(S_AXI_WDATA),
         .s00_axi_wstrb(S_AXI_WSTRB),
         .s00_axi_wvalid(S_AXI_WVALID),
         .s00_axi_wready(S_AXI_WREADY),
         .s00_axi_bresp(S_AXI_BRESP),
         .s00_axi_bvalid(S_AXI_BVALID),
         .s00_axi_bready(S_AXI_BREADY),
         .s00_axi_araddr(S_AXI_ARADDR),
         .s00_axi_arprot(S_AXI_ARPROT),
         .s00_axi_arvalid(S_AXI_ARVALID),
         .s00_axi_arready(S_AXI_ARREADY),
         .s00_axi_rdata(S_AXI_RDATA),
         .s00_axi_rresp(S_AXI_RRESP),
         .s00_axi_rvalid(S_AXI_RVALID),
         .s00_axi_rready(S_AXI_RREADY)
	);


    task write_axi_register;
        input [3:0] address;
        input [31:0] data;
    begin
        $monitor("MONITOR S_AXI_BVALID: %h @ %0t", S_AXI_BVALID, $time);
        
        $display("AXI WRITE %x = %x\n", address, data);
        @(negedge clk);
        S_AXI_BREADY <= 1;          // we can take a write response
        S_AXI_WVALID <= 1;
        S_AXI_AWVALID <= 1;         // write address valid
    
        S_AXI_AWADDR <= address;      // slv_reg3
        S_AXI_WDATA <= data;       // colon period
        S_AXI_WSTRB <= 4'b1111;     // 32-bit write / store 
    
        wait(S_AXI_BVALID == 1);    // write is accepted
        $display("AXI Write accepted");
        
        S_AXI_AWVALID <= 0;         // write address valid
        S_AXI_WVALID <= 0;
        S_AXI_AWADDR <= 4'd0;
        S_AXI_WDATA <= 32'd0;
        wait(S_AXI_BVALID == 0);    // write is accepted
        $display("AXI Write complete");
        S_AXI_BREADY <= 0;
        
    end
    endtask
    // drive values into the 4 slave registers
    initial begin
    
        @(posedge areset);
        
        write_axi_register(4'd4, 32'h0434);
        
        write_axi_register(4'd0, 32'b1001_0000_0000_0011_0000_0000_0000_0010);
            
        $display("Waiting for digit 0");
        wait(anodes_out === 9'bZ_ZZ00_0000);  // 0x3f
        wait(anodes_out === 9'bZ_Z00Z_Z00Z); // 0x66
                            
        $finish;
    end

endmodule
