## Synopsis

This is a personal FPGA project to use an ADC to get analog video and output to digital. The main benefit to this is that deinterlacers in TVs can be bypassed, which are probably the biggest source of input lag when running old analog equipment (gaming consoles).

## Motivation

I (used to) play Super Smash Bros. Melee for the Nintendo Gamecube competitively. The game was released in 2001, and the Gamecube only has analog out. Most Gamecubes only output in 480i (unless you wanted to spend 100+ on a component cable). What ends up happening is that the signals get deinterlaced on any modern display. According to Smashboards, this is typically the bottleneck in terms of input lag. For instance, if you have a Wii and run component to the same display (480p), the input lag situation is improved significantly. As a result of all of this, Smashers are notorious for hoarding CRT televisions for minimum input latency.

This project handles the deinterlacing on hardware. The signal can be output using VGA or HDMI, both of which are found on modern TVs. This project uses VGA since that's what is onboard the DE-1.

## Instructions

The .sof file is already compiled for DE-1 SoC. For other FPGAs, you may need to build your own project using the Verilog files. Non Altera users may have difficulty with the SRAM module, which was generated using Quartus.

## Status

Not currently working on this project. The output is in 4:2:2 format. 4:4:4 output would help. However I think there is still some input lag using the onboard ADV 7180 so I stopped pursuing this.