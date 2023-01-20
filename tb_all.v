//
`timescale 1ns/10ps

module tb;

localparam PCLK_HALF_PERIOD   = 8; //250MHz,
localparam PIXCLK_HALF_PERIOD = 8; //250MHz,

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
reg read_start=0;
wire [31:0] baseImageI;
wire [31:0] baseImageO;
wire [15:0] frame_width=20;
wire [15:0] frame_height=16;
wire pixel_size=16;
wire int_out=0;
integer fd,err1;

integer i=0,j=0,len=2,wid=1;
//reg [15:0] d0,d1,d2,d3;
//integer err1;
reg [320:0] str1;

reg [31:0] pix_num;

initial begin
	pclk = 1'b0;
	prstn= 1'b1;
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



reg finish_begin=0;

wire write_finish=0;
reg [7:0] wen=0;
wire [15:0] dataout1;
wire [15:0] dataout2;
wire [63:0] data1;
wire [63:0] data2;
wire [63:0] data3;
//reg read_start=0;
//wire [63:0] data4;
//wire [63:0] data5;
//wire [63:0] data6;
reg [20:0] block_adr;
reg right_edge=0;
wire read_finish;
wire ave_finish;
reg nxt_flag=1;
reg [63:0]result=0;
reg [20:0]w_adr=21'd1097152;



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


PixelRead u_t2(
.wen(wen),
.pclk(pclk),
.prstn(prstn),
.w_adr(w_adr),
.block_adr(block_adr), 
//.nxt_pixel(nxt_pixel),
.read_start(read_start),
.frame_width(frame_width),
.frame_height(frame_hight),
.read_finish(read_finish),
.write_finish(write_finish),
.right_edge(right_edge),
.result(result),
.out1(data1),
.out2(data2),
.out3(data3)
);

wire data_get;
median_top median(
.clk(pclk),
.rst_n(prstn),
.four_pixel1(data1),
.four_pixel2(data2),  
.four_pixel3(data3),  
.nxt_data_flag(nxt_flag),
.medfilt_data_out(dataout1),
.medfilt_data_out2(dataout2),
.medfilt_done_flag(ave_finish),
.data_get_flag(data_get)
    );

initial begin	

  if(1) begin
      init_data;
      $display("frame start!");
      block_adr<=21'b0;
      #10
      read_start<=1;
      #5
	    $finish(2);
	end
end

reg t1=0;
reg t2=0;
reg q=0;
always@(posedge pclk or negedge pclk)begin
  t1<=ave_finish;
  t2<=t1;
if((t1!=t2)&&(t1==1))begin
    read_start<=1;
     wen<=0;
    q<=~q;
    if(len>2)begin
    if(q==1)
    begin
       result[47:32]<=dataout1;
       result[63:48]<=dataout2;
      
    end
    else
    begin
       result[15:0]<=dataout1;
       result[31:16]<=dataout2;
    end
    end
    if(len<frame_width-2)begin
     right_edge<=0;
     len<=len+2;
     if((len%4==0)&&(len>2))begin
        block_adr<=block_adr+1;
     end
    end
    else
    begin
      len<=2;
      right_edge<=1;
      if(wid<frame_height-2)begin
        wid<=wid+1;
        block_adr<=block_adr+1;
      end
      else begin
        read_start<=0;
      end    
     end
end
end
reg t4=0;
reg t3=0;
always@(posedge pclk or negedge pclk)
begin
  t3<=read_finish;
  t4<=t3;
  if((t3!=t4)&&(t3!=0))begin
    read_start<=0;
    if(q==1)begin
    wen<=1;
    w_adr<= w_adr+1;
    end
  end
end

//integer j=0;
task init_data;
begin
  fd=$fopen("H:/Grade3Term2/DigitalDe/MedFil/testdata.txt","r");
  err1=$ferror(fd,str1);
  for(i=0;i<pix_num;i=i+1)begin
    $fscanf(fd, "%d", u_t2.u_mem.mem[i][15:0]);
    $fscanf(fd, "%d", u_t2.u_mem.mem[i][31:16]);
    $fscanf(fd, "%d", u_t2.u_mem.mem[i][47:32]);
    $fscanf(fd, "%d", u_t2.u_mem.mem[i][63:48]);
  end
//  $fread(u_t2.u_mem.mem,fd);
	//$readmemh("H:/Grade3Term2/DigitalDe/MedFil/testdata.txt", u_t2.u_mem.mem);
	$display("begin finish!");
end



endtask


endmodule
  