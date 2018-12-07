`define OE_L_DLY      5'd16

`SCAN_HS:
		    if(hs_dly_cnt == `OE_L_DLY + 1)

wire oe_line;
assign oe_line = (led_line_dly > oe_cnt[frame_cnt]*`LINE_INT/16)? 1'b0: 1'b1;
