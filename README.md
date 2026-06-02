# HDMI Passthrough on PYNQ-Z2

A simple HDMI passthrough design for the **TUL PYNQ-Z2** that receives HDMI video through the onboard HDMI input and immediately retransmits it through the HDMI output using FPGA logic only.

The design operates entirely in Programmable Logic (PL) and does not use frame buffers, DDR memory, VDMA, or the ARM processor.

## Architecture

```text
HDMI Input
    │
    ▼
 dvi2rgb
    │
RGB + Sync Signals
    │
    ▼
 rgb2dvi
    │
    ▼
HDMI Output
```

Video data is passed directly from the HDMI receiver to the HDMI transmitter without intermediate storage.

## Features

* Pure FPGA implementation
* No DDR memory
* No VDMA
* No frame buffering
* No ARM software required
* Automatic resolution passthrough
* Near-zero latency

## Limitations

* Input and output clocks must remain synchronized
* No frame-rate conversion
* No resolution scaling
* No image processing
* Output resolution always matches input resolution

## IP Cores Used

| IP Core          | Purpose                                                     |
| ---------------- | ----------------------------------------------------------- |
| `dvi2rgb`        | HDMI/TMDS receiver                                          |
| `rgb2dvi`        | HDMI/TMDS transmitter                                       |
| `clk_wiz`        | Generates the 200 MHz reference clock required by `dvi2rgb` |
| `proc_sys_reset` | Reset synchronization                                       |
| `ila`            | Internal signal debugging                                   |

## Clocking

The design uses the PYNQ-Z2 onboard **125 MHz oscillator** as the primary clock source.

A Clock Wizard generates the **200 MHz reference clock** required by `dvi2rgb`.

The recovered pixel clock from `dvi2rgb` drives the HDMI transmit path.

## HDMI Support

* DDC (I²C) interface connected
* Hot-Plug Detect (HPD) asserted
* EDID communication supported through the Digilent HDMI IP

## Constraints

Additional placement and routing constraints are required to satisfy Xilinx 7-Series clocking requirements for the HDMI TX and RX paths.

These include:

* MMCM location constraints
* Dedicated clock routing overrides
* TMDS pin assignments
* HDMI DDC and HPD mappings

See `constraints.xdc` for implementation details.

## Tested Hardware

| Item      | Value                    |
| --------- | ------------------------ |
| Board     | TUL PYNQ-Z2              |
| FPGA      | XC7Z020-1CLG400C         |
| Toolchain | Vivado                   |
| Interface | HDMI Input → HDMI Output |

## Notes

This project is intended as a minimal HDMI passthrough reference design. It demonstrates TMDS reception, video extraction, and TMDS transmission entirely within FPGA fabric without external memory or software dependencies.

