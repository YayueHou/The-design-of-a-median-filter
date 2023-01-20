//

`timescale 1ns/10ps

module testbench;

localparam PCLK_HALF_PERIOD   = 10; //250MHz,
localparam PIXCLK_HALF_PERIOD = 10; //250MHz,

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

/////////
reg pclk ;
reg prstn;
/////////////
reg pixel_clk ;
reg pixel_rstn;

///apb in/out signals
reg [31:0] paddr ;
reg [31:0] pwdata;
reg penable      ;
reg pwrite       ;
reg psel         ;
wire [31:0] prdata;
//////
wire frame_start;
reg frame_done;
reg [31:0] frame_number;
reg [31:0] frame_cycle;
reg [31:0] frame_cycle_sum;

wire [31:0] baseImageI;
wire [31:0] baseImageO;
wire [15:0] frame_width=20;
wire [15:0] frame_height=16;
wire pixel_size;
wire int_out;

integer i=0,j=0;
integer fd,err1;
reg [320:0] str1;
reg [31:0] pix_num=320;

initial begin
	pclk = 1'b0;
	prstn= 1'b0;
	pixel_clk = 1'b0;
	pixel_rstn= 1'b0;
	//ir_strobe_i=1'b0;
	#1;
	prstn= 1'b1;
	#1;
	pixel_rstn= 1'b1;	
end
initial begin
    paddr=1'b0;
    pwdata=1'b0;
    penable=1'b0      ;
    pwrite=1'b0       ;
    psel =1'b0       ;
//////
   
    frame_done=0;
    frame_number=1;
    frame_cycle=0;
    frame_cycle_sum=0;

end

always #(PCLK_HALF_PERIOD  ) pclk     =~pclk     ;
always #(PIXCLK_HALF_PERIOD) pixel_clk=~pixel_clk;

filter_apb_if u_if(
 .pclk(pclk)
,.prstn(prstn)
///apb in/out signals
,.paddr(paddr)
,.pwdata(pwdata)
,.penable(penable)
,.pwrite(pwrite)
,.psel(psel)
,.prdata(prdata)
/// register output
,.frame_start(frame_start)
,.frame_done(frame_done)
,.frame_number(1)
,.frame_cycle(frame_cycle)
,.frame_cycle_sum(frame_cycle_sum)
///////////
,.baseImageI(baseImageI)
,.baseImageO(baseImageO)
,.frame_width(frame_width)
,.frame_height(frame_height)
,.pixel_size(pixel_size)
,.int_out(int_out)
);

median_filter_top u_top(
.pclk(pclk),
.prstn(prstn),
.frame_width(frame_width),
.frame_height(frame_height),
.result(result)
);

initial begin	
 if(1) begin
     
      pwrite<=1'b1;
	  psel<=1'b1;
	  #8
	  penable<=1'b1;
	  #1
	  paddr<=REG_FRAME_WIDTH;
	  pwdata[23:0]<=24'd20;
      #7
      pwrite<=1'b1;
	  psel<=1'b1;
	  #8
	  penable<=1'b1;
	  #1
      paddr<=REG_FRAME_HEIGHT;
	  pwdata[23:0]<=24'd16;
      #7
      pwrite<=1'b1;
	  psel<=1'b1;
	  #8
	  penable<=1'b1;
	  #1
      paddr<=REG_BASE_FRAME_IN;
	  pwdata[23:0]<=24'h00;
      #7
      pwrite<=1'b1;
	  psel<=1'b1;
	  #8
	  penable<=1'b1;
	  #1
      paddr<=REG_BASE_FRAME_OUT;
	  pwdata[23:0]<=24'h0010bdc3;
      $display("frame start!");
      #5
	  $finish(2);
	end
end

initial begin	
  if(1) begin
  
  
      $display("frame start!");
	  fd=$fopen("H:/Grade3Term2/DigitalDe/MedFil/testdata.txt","r");
      err1=$ferror(fd,str1);
    for(i=0;i<pix_num;i=i+1)begin
        $fscanf(fd, "%d", u_top.u_t2.u_mem.mem[i][15:0]);
        $fscanf(fd, "%d", u_top.u_t2.u_mem.mem[i][31:16]);
        $fscanf(fd, "%d", u_top.u_t2.u_mem.mem[i][47:32]);
        $fscanf(fd, "%d", u_top.u_t2.u_mem.mem[i][63:48]);
     end
	$display("begin finish!");
     #100
	$finish(2);
	end
end

endmodule
