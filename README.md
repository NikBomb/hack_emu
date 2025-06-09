## SystemVerilog and C++ Nand2Tetris Hack platform Simulator using Verilator.

This repo contains the SystemVerilog files describing the HACK Platform 

<img src ="/assets/Hack_Computer_Block_Diagram_2.png" width="500" style="display: block; margin: 0 auto">
<em>Hack Computer Architecture. By Rleininger - Own work, CC BY-SA 4.0, https://commons.wikimedia.org/w/index.php?curid=109499961</em>

This project has been tested on Ubuntu 24.04.2 LTS, VSCode and CMake.

## Dependencies 

* Verilator:`sudo apt-get install verilator`
* SDL2 : `sudo apt install libsdl2-dev`

## Build Instructions

* `mkdir build`
* `cd build`
* `cmake ..`
* `make`

## Run Simulator 

Pass the path of a hack program to `hack_simulator` executable

`hack_simulator Pong.Hack`

<img src ="/assets/Pong.png" width="500" style="display: block; margin: 0 auto">
<em>Simulator running Pong</em>