# Find SDL2  
find_package(SDL2 REQUIRED)  
  
# Create simulator executable  
add_executable(hack_simulator main.cpp)  
  
# Link with the verilated library and SDL2  
target_link_libraries(hack_simulator  
    PRIVATE  
    verilated_lib  
    ${SDL2_LIBRARIES}  
)  
  
# Include directories for SDL2  
target_include_directories(hack_simulator  
    PRIVATE  
    ${SDL2_INCLUDE_DIRS}  
)  
  
