## ====================================================================
## Physical Location Constraints (Forces MMCM to align with HDMI Tx Pins)
## ====================================================================
set_property LOC MMCME2_ADV_X1Y2 [get_cells design_1_i/rgb2dvi_0/U0/ClockGenInternal.ClockGenX/GenMMCM.DVI_ClkGenerator]

## ====================================================================
## Clock Routing Overrides (Bypasses Regional Placement Rules)
## ====================================================================
set_property CLOCK_DEDICATED_ROUTE FALSE [get_nets design_1_i/rgb2dvi_0/U0/ClockGenInternal.ClockGenX/PixelClkIn]
set_property CLOCK_DEDICATED_ROUTE FALSE [get_nets design_1_i/rgb2dvi_0/U0/ClockGenInternal.ClockGenX/PixelClkInX5]
set_property CLOCK_DEDICATED_ROUTE FALSE [get_nets design_1_i/dvi2rgb_0/U0/TMDS_Clock_w]
set_property CLOCK_DEDICATED_ROUTE BACKBONE [get_nets design_1_i/clk_wiz_0/inst/clk_in1_design_1_clk_wiz_0_0]

## ====================================================================
## System Clock (On-Board 125 MHz Crystal Oscillator)
## ====================================================================
set_property -dict { PACKAGE_PIN H16   IOSTANDARD LVCMOS33 } [get_ports { sys_clk }]
create_clock -add -name sys_clk_pin -period 8.00 -waveform {0 4} [get_ports { sys_clk }]

## ====================================================================
## HDMI Rx / Input (Mapped to Block Design Port: TMDS_1)
## ====================================================================
create_clock -period 6.734 -waveform {0.000 4.167} [get_ports TMDS_1_clk_p]

set_property -dict { PACKAGE_PIN P19   IOSTANDARD TMDS_33  } [get_ports { TMDS_1_clk_n }]
set_property -dict { PACKAGE_PIN N18   IOSTANDARD TMDS_33  } [get_ports { TMDS_1_clk_p }]

set_property -dict { PACKAGE_PIN W20   IOSTANDARD TMDS_33  } [get_ports { TMDS_1_data_n[0] }]
set_property -dict { PACKAGE_PIN V20   IOSTANDARD TMDS_33  } [get_ports { TMDS_1_data_p[0] }]
set_property -dict { PACKAGE_PIN U20   IOSTANDARD TMDS_33  } [get_ports { TMDS_1_data_n[1] }]
set_property -dict { PACKAGE_PIN T20   IOSTANDARD TMDS_33  } [get_ports { TMDS_1_data_p[1] }]
set_property -dict { PACKAGE_PIN P20   IOSTANDARD TMDS_33  } [get_ports { TMDS_1_data_n[2] }]
set_property -dict { PACKAGE_PIN N20   IOSTANDARD TMDS_33  } [get_ports { TMDS_1_data_p[2] }]

## ====================================================================
## HDMI Tx / Output (Mapped to Block Design Port: TMDS_0)
## ====================================================================
set_property -dict { PACKAGE_PIN L17   IOSTANDARD TMDS_33  } [get_ports { TMDS_0_clk_n }]
set_property -dict { PACKAGE_PIN L16   IOSTANDARD TMDS_33  } [get_ports { TMDS_0_clk_p }]

set_property -dict { PACKAGE_PIN K18   IOSTANDARD TMDS_33  } [get_ports { TMDS_0_data_n[0] }]
set_property -dict { PACKAGE_PIN K17   IOSTANDARD TMDS_33  } [get_ports { TMDS_0_data_p[0] }]
set_property -dict { PACKAGE_PIN J19   IOSTANDARD TMDS_33  } [get_ports { TMDS_0_data_n[1] }]
set_property -dict { PACKAGE_PIN K19   IOSTANDARD TMDS_33  } [get_ports { TMDS_0_data_p[1] }]
set_property -dict { PACKAGE_PIN H18   IOSTANDARD TMDS_33  } [get_ports { TMDS_0_data_n[2] }]
set_property -dict { PACKAGE_PIN J18   IOSTANDARD TMDS_33  } [get_ports { TMDS_0_data_p[2] }]

## ====================================================================
## Display Data Channel / I2C (Mapped to Block Design Port: DDC_0)
## ====================================================================
set_property -dict { PACKAGE_PIN U14   IOSTANDARD LVCMOS33 } [get_ports { DDC_0_scl_io }]
set_property -dict { PACKAGE_PIN U15   IOSTANDARD LVCMOS33 } [get_ports { DDC_0_sda_io }]

## ====================================================================
## Hot Plug Detect (HPD) - Wake up the Ubuntu Video Driver
## ====================================================================
set_property -dict { PACKAGE_PIN T19   IOSTANDARD LVCMOS33 } [get_ports { hdmi_rx_hpd }]
