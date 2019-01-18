`timescale 1ns / 1ps
////////////////////////////////////////////////////////////////////////////////
// Company		: WNL
// Engineer		: Diego L
// Create Date	: 2019.1.6
// Design Name	: Sdcard Data
// Module Name	: sdcard_data
// Project Name	: Fgpa_led
// Target Device: Cyclone EP1C3T144C8 
// Tool versions: Quartus II 9.1
// Description	: 该工程用于sdcard读写回环测试
//					
// Revision		: V1.0
// Additional Comments	:  
// 
////////////////////////////////////////////////////////////////////////////////
module sdc_loop(
                clk,rst_n,
                spi_miso,spi_mosi,spi_clk,spi_cs_n				
);
input clk;		//FPAG输入时钟信号50MHz
input rst_n;	//FPGA输入复位信号

input spi_miso;		//SPI主机输入从机输出数据信号
output spi_mosi;	//SPI主机输出从机输入数据信号
output spi_clk;		//SPI时钟信号，由主机产生
output spi_cs_n;	//SPI从设备使能信号，由主设备控制

wire[7:0] ffsdc_din;	//SD卡FIFO写入数据
wire ffsdc_wrreq;		//SD卡FIFO写请求信号，高有效
wire ffsdc_rdreq;		//SD卡FIFO读请求信号，高有效
wire[7:0] ffsdc_dout;	//SD卡FIFO读出数据
wire[8:0] ffsdc_used;	    //SD卡数据写入缓存FIFO已用存储空间数量
wire ffsdc_clr;

wire sdc_rd_en;		//FIFO不满，sd卡读使能信号
wire sdc_wr_en;    
assign sdc_rd_en = (ffsdc_used < 9'd504);
assign sdc_wr_en = (ffsdc_used > 9'd16);	//检测FIFO大于8位数据，就启动SD写入

//例化SD卡数据读写缓存FIFO模块*/
sdc_fifo			sdc_fifo_inst(
					.aclr(ffsdc_clr),
					.data(ffsdc_din),
					.rdclk(clk),
					.rdreq(ffsdc_rdreq),
					.wrclk(clk),
					.wrreq(ffsdc_wrreq),//sd卡写准备好,sd内部，一有8位数据即置为1
					.q(ffsdc_dout),
					.wrusedw(ffsdc_used)					
					);
					
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
					.sdc_rd_en(sdc_rd_en),//add
					.sdwrad_clr(ffsdc_clr)
				);
				
endmodule