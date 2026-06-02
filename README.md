# Real-Time Standalone HDMI Passthrough Video Pipeline (Zynq-7000 / PYNQ-Z2)

An SEO-optimized, pure hardware implementation of an unbuffered HDMI passthrough video pipeline on the **TUL PYNQ-Z2** development board. This project extracts incoming differential TMDS video data streams, paths them entirely within the FPGA Programmable Logic (PL) fabric, and reconstructs them into an active HDMI output signal.

> ⚠️ **Architecture Note:** This is a zero-latency, **unbuffered basic architecture**. It does not implement a FIFO or Frame Buffer (such as VDMA or Video Frame Buffer Write/Read). Therefore, the input pixel clock and output pixel clock are locked in absolute frequency synchronization; the output display automatically mirrors the input resolution and refresh rate.

---

## 🧩 IP Cores Used in this Project

The hardware architecture inside the Vivado Block Design utilizes the following Xilinx and Digilent IP cores:

*   **`dvi2rgb` (Digilent HDMI Input Decoder)**: Ingests raw TMDS differential signals from the physical HDMI-IN port, handles the DDC (I2C) handshake, and extracts a 24-bit parallel RGB video bus along with Horizontal Sync (`HSync`), Vertical Sync (`VSync`), and Video Data Enable (`VDE`).
*   **`rgb2dvi` (Digilent HDMI Output Encoder)**: Automatically multiplies the parallel video clock using an internal clock primitive to re-serialize the 24-bit RGB bus back into differential TMDS monitor streams for the physical HDMI-OUT port.
*   **`clk_wiz` (Xilinx Clocking Wizard)**: Ingests the on-board 125 MHz crystal oscillator signal and scales it up to provide a stable, dedicated 200 MHz reference clock (`RefClk`) required by the `dvi2rgb` oversampling logic.
*   **`proc_sys_reset` (Xilinx Processor System Reset)**: Automatically handles synchronous state-machine transitions and initialization timing rules across distinct clock domains to prevent state lockups.
*   **`ila` (Xilinx Integrated Logic Analyzer v6.2)**: A software-in-the-loop hardware debugging core used to tap, trigger, and view real-time digital wave traffic directly on the internal parallel video nets.

---

## 📋 Pin Configuration & Constraints (`constaint.xdc`)

This project implements a highly specialized layout to resolve Xilinx 7-series structural placement limitations (`BUFIO`/`MMCM` clock region cross-over boundaries) using a global routing backbone:

```xdc
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

set_property -dict { PACKAGE_PIN W20   IOSTANDARD TMDS_33  } [get_ports { TMDS_1_data_n[*] }]
set_property -dict { PACKAGE_PIN V20   IOSTANDARD TMDS_33  } [get_ports { TMDS_1_data_p[*] }]
set_property -dict { PACKAGE_PIN U20   IOSTANDARD TMDS_33  } [get_ports { TMDS_1_data_n[*] }]
set_property -dict { PACKAGE_PIN T20   IOSTANDARD TMDS_33  } [get_ports { TMDS_1_data_p[*] }]
set_property -dict { PACKAGE_PIN P20   IOSTANDARD TMDS_33  } [get_ports { TMDS_1_data_n[*] }]
set_property -dict { PACKAGE_PIN N20   IOSTANDARD TMDS_33  } [get_ports { TMDS_1_data_p[*] }]

## ====================================================================
## HDMI Tx / Output (Mapped to Block Design Port: TMDS_0)
## ====================================================================
set_property -dict { PACKAGE_PIN L17   IOSTANDARD TMDS_33  } [get_ports { TMDS_0_clk_n }]
set_property -dict { PACKAGE_PIN L16   IOSTANDARD TMDS_33  } [get_ports { TMDS_0_clk_p }]

set_property -dict { PACKAGE_PIN K18   IOSTANDARD TMDS_33  } [get_ports { TMDS_0_data_n[*] }]
set_property -dict { PACKAGE_PIN K17   IOSTANDARD TMDS_33  } [get_ports { TMDS_0_data_p[*] }]
set_property -dict { PACKAGE_PIN J19   IOSTANDARD TMDS_33  } [get_ports { TMDS_0_data_n[*] }]
set_property -dict { PACKAGE_PIN K19   IOSTANDARD TMDS_33  } [get_ports { TMDS_0_data_p[*] }]
set_property -dict { PACKAGE_PIN H18   IOSTANDARD TMDS_33  } [get_ports { TMDS_0_data_n[*] }]
set_property -dict { PACKAGE_PIN J18   IOSTANDARD TMDS_33  } [get_ports { TMDS_0_data_p[*] }]

## ====================================================================
## Display Data Channel / I2C (Mapped to Block Design Port: DDC_0)
## ====================================================================
set_property -dict { PACKAGE_PIN U14   IOSTANDARD LVCMOS33 } [get_ports { DDC_0_scl_io }]
set_property -dict { PACKAGE_PIN U15   IOSTANDARD LVCMOS33 } [get_ports { DDC_0_sda_io }]

## ====================================================================
## Hot Plug Detect (HPD) - Wake up the Host Video Driver
## ====================================================================
set_property -dict { PACKAGE_PIN T19   IOSTANDARD LVCMOS33 } [get_ports { hdmi_rx_hpd }]
```

---

## 🧠 Lessons Learnt & Engineering Journal

Developing this pipeline provided hands-on experience with hardware clock constraints, electrical handshake rules, and FPGA physical placement topologies. 

### 1. The Zynq Power Dependency Loop (Pure Hardware vs. Processor Software)
*   **The Mistake:** Relying on the Zynq ARM Processing System (`FCLK_CLK0`) to feed the design's master reference clocks. When programming the bitstream via Vivado JTAG alone, the clock line remained completely flatlined at 0 MHz because the processing system required separate software initialization code (`ps7_init.tcl` via Vitis) to activate the internal PLLs.
*   **The Fix:** Cut dependencies on the ARM processor entirely. Swapped the input clock source over to the PYNQ-Z2's physical, on-board **125 MHz crystal oscillator (Pin H16)**. This allows the video pipeline to boot autonomously the exact millisecond the bitstream finishes loading.

### 2. 7-Series Clock Region Architecture Constraints
*   **The Mistake:** Configuring the `rgb2dvi` core to use a standard `PLL` primitive while routing clocks across the chip. This triggered severe routing crashes (`Place 30-99: IO Clock Placer failed`). On Xilinx 7-series silicon, high-speed regional serial buffers (`BUFIO`/`BUFR`) must sit in the exact same physical clock column as the component driving them.
*   **The Fix:** 
    1. Reconfigured `rgb2dvi` from a `PLL` to an **`MMCM`** primitive to take advantage of wider frequency bands.
    2. Explicitly constrained the physical coordinates of the clock generator right next to the HDMI output pins using `set_property LOC MMCME2_ADV_X1Y2`.
    3. Granted Vivado routing flexibility using the `CLOCK_DEDICATED_ROUTE BACKBONE` attribute.

### 3. Electrical Handshaking & Host PC Blindness (DDC & HPD)
*   **The Mistake:** Programming the FPGA successfully but finding that connecting an Ubuntu/Windows laptop yielded a black screen and a flatlined ILA. Operating systems will turn off their HDMI graphics transmitters if they do not receive an automatic **Hot Plug Detect (HPD)** signal and an immediate response from the display adapter's **Display Data Channel (DDC)** RAM.
*   **The Fix:** 
    1. Modified the top-level Verilog wrapper to map the bidirectional `inout` DDC lines to physical tri-state buffers (`IOBUF`), allowing the laptop to read the EDID data structure inside the FPGA.
    2. Explicitly declared the physical Hot Plug Detect pin (`T19`) as a top-level output and hardwired it high (`assign hdmi_rx_hpd = 1'b1;`) to force the host PC to wake up its video port.

### 4. Vector / Bus Indexing in Constraints (DRC Errors)
*   **The Mistake:** Declaring multi-bit differential buses (like `TMDS_1_data_p`) as single lines inside the `.xdc` file. Vivado flagged a critical Design Rule Check violation (`[DRC UCIO-1] Unconstrained Logical Port`), blocking bitstream generation to protect the physical IO banks from voltage contention.
*   **The Fix:** Rewrote the constraint syntax to explicitly define separate mapping entries for array indicators, satisfying the DRC physical compilation rules.

