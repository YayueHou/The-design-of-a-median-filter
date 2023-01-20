module sram_2Mx64 #(parameter DW = 64, BW=8, AW = 21, DEPTH = 2097152)(
 input clk
,input csn
,input [AW-1:0] adri
,input[AW-1:0]  adro
,input [BW-1:0] wen
,input [DW-1:0] din
,output [DW-1:0] dout
,output finish_sig
);

`ifdef _USE_TSMC_MODEL_
//todo, instantiate specific tsmc_memory_model;

`else 
// Generic single-port synchronous RAM model
reg	[DW-1:0]	mem [DEPTH-1:0];	// RAM content
reg	[AW-1:0]	addr_reg;		// RAM address register
reg [DW-1:0]    dout_mem;
reg finish;
integer i;

assign dout = mem[adri];

always @(posedge clk)begin
if (~csn)
	addr_reg <= adri;

end


always @(posedge clk) begin
	finish=0;
	if(~csn)
		if (wen)
		begin
			for (i=0;i<BW;i=i+1)
		 	{mem[adro][i*8+7],mem[adro][i*8+6],mem[adro][i*8+5],mem[adro][i*8+4],mem[adro][i*8+3],mem[adro][i*8+2],mem[adro][i*8+1],mem[adro][i*8]} <=
		 	 {din[i*8+7],din[i*8+6],din[i*8+5],din[i*8+4],din[i*8+3],din[i*8+2],din[i*8+1],din[i*8]};
		end
/*		else
		begin
			for (i=0;i<BW;i=i+1)
		  	{dout_mem[i*8+7],dout_mem[i*8+6],dout_mem[i*8+5],dout_mem[i*8+4],dout_mem[i*8+3],dout_mem[i*8+2],dout_mem[i*8+1],dout_mem[i*8]}<=
		  	{mem[adr][i*8+7],mem[adr][i*8+6],mem[adr][i*8+5],mem[adr][i*8+4],mem[adr][i*8+3],mem[adr][i*8+2],mem[adr][i*8+1],mem[adr][i*8]};
		end
    	finis=1;
*/
end

//assign dout=dout_mem;
assign finish_sig=finish;
`endif

endmodule

