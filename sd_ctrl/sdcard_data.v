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
// Description	: �ù�������sdcard��д����
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

input clk;		//FPAG����ʱ���ź�50MHz
input rst_n;	//FPGA���븴λ�ź�

output rs232_tx;	// RS232���������ź�

input spi_miso;		//SPI��������ӻ���������ź�
output spi_mosi;	//SPI��������ӻ����������ź�
output spi_clk;		//SPIʱ���źţ�����������
output spi_cs_n;	//SPI���豸ʹ���źţ������豸����

wire tx_start;		//���ڷ�������������־λ������Ч

//����FIFO����ź�
wire[7:0] fifo232_din;	//FIFOд������
wire fifo232_wrreq;		//FIFOд�����źţ�����Ч
wire fifo232_rdreq;		//FIFO�������źţ�����Ч
wire[7:0] fifo232_dout;	//FIFO�������ݣ������ڴ���������
//wire fifo232_empty;	//FIFO�ձ�־λ������Ч
wire[8:0] wrf_use;			//sd������д�뻺��FIFO���ô洢�ռ�����
wire fifo232_clr;

wire sd_rd_en;		//FIFO������sd�����������

assign sd_rd_en = (wrf_use < 9'd504);
assign tx_start = (wrf_use > 9'd0);	//���FIFO����8λ���ݣ����������ڶ�FIFO����������


`ifdef TO_BE_DEL
//�����������ݷ��Ϳ���ģ��
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
//sd����������д��SDRAM_wrfifo����vgaram
reg[10:0] cnt78;	//������1078
//cnt78����0-53��SD���ݲ����棩��54-1077��SD���ݱ����룩��1078����ֹͣ��SD����д��SDRAM��
always @(posedge clk or negedge rst_n)
	if(!rst_n) cnt78 <= 11'd0;
	else if(sdwrad_clr) cnt78 <= 11'd0;		//������һ��ͼƬ
	else if((cnt78 < 11'd1078) && fifo232_wrreq) cnt78 <= cnt78+1'b1;

//wire bmpvt_wren = (cnt78 > 11'd53) & (cnt78 < 11'd1078) & fifo232_wrreq;	//SD��������д��VGAɫ�ʱ�RAM
wire bmpsd_wren = (cnt78 == 11'd1078) & fifo232_wrreq;	//SD�������ݴ洢��SDRAM wrfifo*/

`ifdef TO_BE_DEL
//�������ڷ������ݻ���FIFOģ��*/
sdrd_fifo			sdrd_fifo_inst(
					.aclr(fifo232_clr),
					.data(fifo232_din),
					.rdclk(clk),
					.rdreq(fifo232_rdreq),
					.wrclk(clk),
					.wrreq(fifo232_wrreq),//sd��д׼����,sd�ڲ���һ��8λ���ݼ���Ϊ1
					.q(fifo232_dout),
					.wrusedw(wrf_use)					
					);
`endif

//sd����ģ��
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
