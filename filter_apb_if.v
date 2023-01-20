//
//apb host if, register configuation.
//
module filter_apb_if (
 input pclk
,input prstn
///apb in/out signals
,input [ 7:0] paddr
,input [31:0] pwdata
,input penable
,input pwrite
,input psel
,output reg [31:0] prdata
/// register output
,output frame_start
,input  frame_done
,input [31:0] frame_number
,input [31:0] frame_cycle
,input [31:0] frame_cycle_sum
///////////
,output reg [31:0] baseImageI
,output reg [31:0] baseImageO
,output reg [15:0] frame_width
,output reg [15:0] frame_height
,output pixel_size
,output int_out
);
localparam REG_SYS_CTRL        = 8'h00;
localparam REG_FRAME_WIDTH     = 8'h04;
localparam REG_FRAME_HEIGHT    = 8'h08;
localparam REG_BASE_FRAME_IN   = 8'h0c;
localparam REG_BASE_FRAME_OUT  = 8'h10;
localparam REG_FRAME_NUMBER    = 8'h14;
localparam REG_FRAME_CYCLE     = 8'h18;
localparam REG_FRAME_CYCLE_SUM = 8'h1c;
localparam REG_INT_STATUS      = 8'h20;
localparam REG_INT_ENABLE      = 8'h24;

wire reg_wr = penable & psel & pwrite ;
wire reg_rd =~penable & psel & ~pwrite;

wire sel_sys_ctrl          = psel & (paddr == REG_SYS_CTRL         );
wire sel_frame_width       = psel & (paddr == REG_FRAME_WIDTH      );
wire sel_frame_height      = psel & (paddr == REG_FRAME_HEIGHT     );
wire sel_base_frame_in     = psel & (paddr == REG_BASE_FRAME_IN    );
wire sel_base_frame_out    = psel & (paddr == REG_BASE_FRAME_OUT   );
wire sel_frame_number      = psel & (paddr == REG_FRAME_NUMBER     );
wire sel_frame_cycle       = psel & (paddr == REG_FRAME_CYCLE      );
wire sel_frame_cycle_sum   = psel & (paddr == REG_FRAME_CYCLE_SUM  );
wire sel_int_status        = psel & (paddr == REG_INT_STATUS       );
wire sel_int_enable        = psel & (paddr == REG_INT_ENABLE       );


reg [ 1:0] sys_ctrl   ;
reg int_status;
reg int_enable;

assign int_out = |(int_enable & int_status);

always@(posedge pclk or negedge prstn)
if(~prstn) begin
	int_status <= 1'd0;
end
else begin
	if(frame_done) int_status <= 1'b1; else if(reg_wr & sel_int_status & pwdata[0]) int_status <= 1'b0;
end

assign frame_start = reg_wr & sel_sys_ctrl & pwdata[0]; //
assign pixel_size  = sys_ctrl[1];

always@(posedge pclk or negedge prstn)
if(~prstn) begin
	sys_ctrl    <=  2'h0;
	int_enable  <=  1'h0;
	frame_width <= 16'd1280;
	frame_height<= 16'd1024;
	baseImageI  <= 32'h0;
	baseImageO  <= 32'h0;
end
else begin
	if(reg_wr & sel_sys_ctrl       ) sys_ctrl     <= pwdata[1:0];
	if(reg_wr & sel_frame_width    ) frame_width  <= pwdata[15:0];
	if(reg_wr & sel_frame_height   ) frame_height <= pwdata[15:0];
	if(reg_wr & sel_base_frame_in  ) baseImageI   <= pwdata[31:0];
	if(reg_wr & sel_base_frame_out ) baseImageO   <= pwdata[31:0];
	if(reg_wr & sel_int_enable     ) int_enable   <= pwdata[0];
end

wire [31:0] reg32_sys_ctrl       = {30'b0,sys_ctrl};
wire [31:0] reg32_frame_width    = {16'b0,frame_width};
wire [31:0] reg32_frame_height   = {16'b0,frame_height};
wire [31:0] reg32_base_frame_in  = {baseImageI};
wire [31:0] reg32_base_frame_out = {baseImageO};
wire [31:0] reg32_frame_number   = {frame_number};
wire [31:0] reg32_frame_cycle    = {frame_cycle};
wire [31:0] reg32_frame_cycle_sum= {frame_cycle_sum};
wire [31:0] reg32_int_status     = {31'b0,int_status};
wire [31:0] reg32_int_enable     = {31'b0,int_enable};

wire [31:0] prdata_w = ({32{sel_sys_ctrl       }} & reg32_sys_ctrl        ) |
                       ({32{sel_frame_width    }} & reg32_frame_width     ) |
                       ({32{sel_frame_height   }} & reg32_frame_height    ) |
                       ({32{sel_base_frame_in  }} & reg32_base_frame_in   ) |
                       ({32{sel_base_frame_out }} & reg32_base_frame_out  ) |
                       ({32{sel_frame_number   }} & reg32_frame_number    ) |
                       ({32{sel_frame_cycle    }} & reg32_frame_cycle     ) |
                       ({32{sel_frame_cycle_sum}} & reg32_frame_cycle_sum ) |
                       ({32{sel_int_status     }} & reg32_int_status      ) |
                       ({32{sel_int_enable     }} & reg32_int_enable      ) ;

always@(posedge pclk or negedge prstn)
if(~prstn)
	prdata <= 32'b0;
else if(reg_rd)
	prdata <= prdata_w;

endmodule