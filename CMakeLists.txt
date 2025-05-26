cmake_minimum_required(VERSION 3.10)    
project(hack_computer CXX)    
find_package(verilator HINTS $ENV{VERILATOR_ROOT})  
if (NOT verilator_FOUND)  
  message(FATAL_ERROR "Verilator was not found. Either install it, or set the VERILATOR_ROOT environment variable")  
endif()  
  
# Explicit list of SV files with their desired library names  
set(VERILOG_SOURCES    
    "rtl/Computer.sv"
)  

add_library(verilated_lib SHARED)
target_include_directories(verilated_lib INTERFACE $<BUILD_INTERFACE:${CMAKE_CURRENT_BINARY_DIR}>)

verilate(verilated_lib
    TOP_MODULE Computer
    SOURCES ${VERILOG_SOURCES}
    INCLUDE_DIRS "rtl"
	PREFIX VComputer
)

  
# Add the simulator subdirectory  
add_subdirectory(sim)  