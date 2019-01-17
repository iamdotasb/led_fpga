`timescale 1ns / 1ps
////////////////////////////////////////////////////////////////////////////////
// Company		: WNL
// Engineer		: Diego L
// Create Date	: 2016.01.09
// Design Name	: Sdcard Data
// Module Name	: sdcard_data
// Project Name	: Fgpa_led
// Target Device: Cyclone EP1C3T144C8 
// Tool versions: Quartus II 8.1
// Description	: 该工程用于sdcard读写数据
//					
// Revision		: V1.0
// Additional Comments	:  
// 
////////////////////////////////////////////////////////////////////////////////
module sdcard_data(
				clk,rst_n,
				rs232_tx,
				spi_miso,spi_mosi,spi_clk,spi_cs_n/*,led*/
			);

input clk;		//FPAG输入时钟信号50MHz
input rst_n;	//FPGA输入复位信号

output rs232_tx;	// RS232发送数据信号

input spi_miso;		//SPI主机输入从机输出数据信号
output spi_mosi;	//SPI主机输出从机输入数据信号
output spi_clk;		//SPI时钟信号，由主机产生
output spi_cs_n;	//SPI从设备使能信号，由主设备控制

wire tx_start;		//串口发送数据启动标志位，高有效

//串口FIFO相关信号
wire[7:0] fifo232_din;	//FIFO写入数据
wire fifo232_wrreq;		//FIFO写请求信号，高有效
wire fifo232_rdreq;		//FIFO读请求信号，高有效
wire[7:0] fifo232_dout;	//FIFO读出数据，即串口待发送数据
//wire fifo232_empty;	//FIFO空标志位，高有效
wire[8:0] wrf_use;			//sd卡数据写入缓存FIFO已用存储空间数量
wire fifo232_clr;

wire sd_rd_en;		//FIFO不满，sd卡允许读数据

assign sd_rd_en = (wrf_use < 9'd504);
assign tx_start = (wrf_use > 9'd0);	//检测FIFO大于8位数据，就启动串口读FIFO并发送数据


`ifdef TO_BE_DEL
//例化串口数据发送控制模块
uart_ctrl		uut_uartctrl(
					.clk(clk),
					.rst_n(rst_n),
					.tx_data(fifo232_dout),
					.tx_start(tx_start),
					.fifo232_rdreq(fifo232_rdreq),
					.rs232_tx(rs232_tx)
					);
`endif

/*					//------------------------------------------------
//sd卡读出数据写入SDRAM_wrfifo或者vgaram
reg[10:0] cnt78;	//计数到1078
//cnt78计数0-53（SD数据不缓存）和54-1077（SD数据表译码），1078计数停止（SD数据写入SDRAM）
always @(posedge clk or negedge rst_n)
	if(!rst_n) cnt78 <= 11'd0;
	else if(sdwrad_clr) cnt78 <= 11'd0;		//重新下一幅图片
	else if((cnt78 < 11'd1078) && fifo232_wrreq) cnt78 <= cnt78+1'b1;

//wire bmpvt_wren = (cnt78 > 11'd53) & (cnt78 < 11'd1078) & fifo232_wrreq;	//SD接收数据写入VGA色彩表RAM
wire bmpsd_wren = (cnt78 == 11'd1078) & fifo232_wrreq;	//SD接收数据存储到SDRAM wrfifo*/

`ifdef TO_BE_DEL
//例化串口发送数据缓存FIFO模块*/
sdrd_fifo			sdrd_fifo_inst(
					.aclr(fifo232_clr),
					.data(fifo232_din),
					.rdclk(clk),
					.rdreq(fifo232_rdreq),
					.wrclk(clk),
					.wrreq(fifo232_wrreq),//sd卡写准备好,sd内部，一有8位数据即置为1
					.q(fifo232_dout),
					.wrusedw(wrf_use)					
					);
`endif

//sd控制模块
sdcard_ctrl		uut_sdcartctrl(
					.clk(clk),
					.rst_n(rst_n),
					.spi_miso(spi_miso),
					.spi_mosi(spi_mosi),
					.spi_clk(spi_clk),
					.spi_cs_n(spi_cs_n),
					.sd_dout(fifo232_din),
					.sd_fifowr(fifo232_wrreq),
					.sd_rd_en(sd_rd_en),//add
					.sdwrad_clr(fifo232_clr)
				);


endmodule
