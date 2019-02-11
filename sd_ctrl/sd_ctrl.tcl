#-------------------------------------------------------------------------------
#TCL引脚分配文件
#-------------------------------------------------------------------------------#
#Setup pin setting 本段为注释，用#引导

set_global_assignment -name FAMILY "Cyclone"
set_global_assignment -name DEVICE EP1C3T144C8

#分配器件
set_global_assignment -name RESERVE_ALL_UNUSED_PINS "As input tri-stated" 

#以下语句为分配引脚
set_location_assignment PIN_16 -to clk
set_location_assignment PIN_144 -to rst_n

set_location_assignment PIN_61 -to led_run
set_location_assignment PIN_58 -to spi_clk
set_location_assignment PIN_55 -to spi_cs_n
set_location_assignment PIN_57 -to spi_miso
set_location_assignment PIN_59 -to spi_mosi














