// main.cpp - HACK Computer Simulator with SDL display  
#include <iostream>  
#include <fstream>  
#include <string> 
#include <cstring> 
#include <cstdint>  
#include <chrono>  
#include <thread>  
#include <SDL2/SDL.h>  
  
// Include the Verilated model (generated from your top SystemVerilog module)  
#include "VComputer.h"
#include "VComputer_Computer.h"
#include "VComputer_ROM.h"  
#include "verilated.h"  

  
// HACK Computer specifications  
#define SCREEN_WIDTH 512  
#define SCREEN_HEIGHT 256  
#define ROM_SIZE 32768  
#define RAM_SIZE 32768  
#define SCREEN_MEMORY_START 0  // 0x4000  
#define KEYBOARD_ADDRESS 24576     // 0x6000  
  
// Function prototypes  
bool loadProgram(VComputer* top, const std::string& filename);  
void updateScreen(VComputer* top, uint32_t* pixels);  
void handleKeyboard(VComputer* top, const SDL_Event& event);  
  
int main(int argc, char** argv) {  
    // Initialize Verilator  
    Verilated::commandArgs(argc, argv);  
      
    // Create Verilated model instance  
    VComputer* top = new VComputer;

    // Initialize VCD tracing (optional)  
   
      
    // Check if program file was provided  
    if (argc < 2) {  
        std::cerr << "Usage: " << argv[0] << " <program.hack>" << std::endl;  
        return 1;  
    }  
      
    // Load HACK program  
    if (!loadProgram(top, argv[1])) {  
        std::cerr << "Failed to load program." << std::endl;  
        return 1;  
    }  
      
    // Initialize SDL  
    if (SDL_Init(SDL_INIT_VIDEO) < 0) {  
        std::cerr << "SDL could not initialize! SDL_Error: " << SDL_GetError() << std::endl;  
        return 1;  
    }  
      
    // Create window  
    SDL_Window* window = SDL_CreateWindow("HACK Computer Display",  
                                         SDL_WINDOWPOS_UNDEFINED,  
                                         SDL_WINDOWPOS_UNDEFINED,  
                                         SCREEN_WIDTH, SCREEN_HEIGHT,  
                                         SDL_WINDOW_SHOWN);  
    if (!window) {  
        std::cerr << "Window could not be created! SDL_Error: " << SDL_GetError() << std::endl;  
        return 1;  
    }  
      
    // Create renderer  
    SDL_Renderer* renderer = SDL_CreateRenderer(window, -1, SDL_RENDERER_ACCELERATED);  
    if (!renderer) {  
        std::cerr << "Renderer could not be created! SDL_Error: " << SDL_GetError() << std::endl;  
        return 1;  
    }  
      
    // Create texture for screen  
    SDL_Texture* texture = SDL_CreateTexture(renderer,  
                                          SDL_PIXELFORMAT_ARGB8888,  
                                          SDL_TEXTUREACCESS_STREAMING,  
                                          SCREEN_WIDTH, SCREEN_HEIGHT);  
    if (!texture) {  
        std::cerr << "Texture could not be created! SDL_Error: " << SDL_GetError() << std::endl;  
        return 1;  
    }  
      
    // Allocate pixel buffer  
    uint32_t* pixels = new uint32_t[SCREEN_WIDTH * SCREEN_HEIGHT];  
      
    // Reset the CPU  
    top->reset = 1;  
    top->clk = 0;  
    top->eval();  
    top->clk = 1;  
    top->eval();  
    top->reset = 0;  
      
    // Simulation variables  
    bool quit = false;  
    SDL_Event e;  
    uint64_t cycle = 0;  
    uint64_t lastScreenUpdate = 0;  
    const uint64_t SCREEN_UPDATE_INTERVAL = 1'000; 
      
    std::cout << "Starting HACK computer simulation..." << std::endl;  
      
    // Main simulation loop  
    while (!quit) {  
        // Handle SDL events  
        while (SDL_PollEvent(&e) != 0) {  
            if (e.type == SDL_QUIT) {  
                quit = true;  
            } else if (e.type == SDL_KEYDOWN || e.type == SDL_KEYUP) {  
                handleKeyboard(top, e);  
            }  
        }  
          
        // Clock cycle  
        top->clk = 0;  
        top->eval();  
          
        top->clk = 1;  
        top->eval();  
          
        // Update screen periodically  
        if (cycle - lastScreenUpdate >= SCREEN_UPDATE_INTERVAL) {  
            updateScreen(top, pixels);  
              
            // Update texture with pixel data  
            SDL_UpdateTexture(texture, NULL, pixels, SCREEN_WIDTH * sizeof(uint32_t));  
            SDL_RenderClear(renderer);  
            SDL_RenderCopy(renderer, texture, NULL, NULL);  
            SDL_RenderPresent(renderer);  
              
            lastScreenUpdate = cycle;  
        }  
          
        // Slow down simulation if needed  
        //if (cycle % 1000 == 0) {  
        //    std::this_thread::sleep_for(std::chrono::microseconds(1));  
        //}  
          
        cycle++;  
    }  
      
    // Cleanup  
    delete[] pixels;  
    SDL_DestroyTexture(texture);  
    SDL_DestroyRenderer(renderer);  
    SDL_DestroyWindow(window);  
    SDL_Quit();  

    delete top;  
      
    std::cout << "Simulation ended after " << cycle << " cycles." << std::endl;  
      
    return 0;  
}  
  
// Load a HACK program into ROM  
bool loadProgram(VComputer* top, const std::string& filename) {  
    std::ifstream file(filename);  
    if (!file.is_open()) {  
        std::cerr << "Error: Could not open program file " << filename << std::endl;  
        return false;  
    }  
      
    std::string line;  
    int address = 0;  
      
    std::cout << "Loading program " << filename << "..." << std::endl;  
      
    while (std::getline(file, line) && address < ROM_SIZE) {  
        // Ignore empty lines and comments  
        if (line.empty() || line[0] == '/') continue;  
          
        // Check if it's a binary string (16 characters of 0s and 1s)  
        if (line.length() >= 16) {  
            uint16_t instruction = 0;  
            for (int i = 0; i < 16; i++) {  
                if (line[i] == '1') {  
                    instruction |= (1 << (15-i));  
                }  
            }  
              
            // Set instruction in ROM  
            // Note: Adjust this based on your actual module interface  
            top->Computer->rom->rom[address] = instruction;  
            address++;  
        }  
    }  
      
    std::cout << "Loaded " << address << " instructions from " << filename << std::endl;  
    return address > 0;  
}  
  
// Update the screen buffer from HACK memory  
void updateScreen(VComputer* top, uint32_t* pixels) {  
    //top->Computer->screen_out[0] = 0x8000; // Expect leftmost
    //top->Computer->screen_out[1] = 0x4000;
    //top->Computer->screen_out[0] = 0x0001; // Expect rightmost
    for (int y = 0; y < SCREEN_HEIGHT; y++) {  
        for (int x = 0; x < SCREEN_WIDTH/16; x++) {  
            // Calculate memory address in the screen memory map  
            int memAddr = y * (SCREEN_WIDTH/16) + x;  
              
            // Get the 16-bit word from memory  
            uint16_t word = top->Computer->screen_out[memAddr]; 
            // Convert each bit to a pixel  
            for (int bit = 0; bit < 16; bit++) {  
                bool pixel_on = (word & (1 <<  bit)) != 0;  
                uint32_t color = !pixel_on ? 0xFFFFFFFF : 0xFF000000; // White or black  
                pixels[memAddr * 16 + bit] = color;  
            }  
        }  
    }  
}  
  
// Handle keyboard input and update keyboard memory  
void handleKeyboard(VComputer* top, const SDL_Event& event) {  
    static uint16_t keycode = 0;  
      
    if (event.type == SDL_KEYDOWN) {  
        // Map SDL key codes to HACK key codes  
        switch (event.key.keysym.sym) {  
            case SDLK_BACKSPACE: keycode = 129; break;  
            case SDLK_LEFT:      keycode = 130; break;  
            case SDLK_UP:        keycode = 131; break;  
            case SDLK_RIGHT:     keycode = 132; break;  
            case SDLK_DOWN:      keycode = 133; break;  
            case SDLK_HOME:      keycode = 134; break;  
            case SDLK_END:       keycode = 135; break;  
            case SDLK_PAGEUP:    keycode = 136; break;  
            case SDLK_PAGEDOWN:  keycode = 137; break;  
            case SDLK_INSERT:    keycode = 138; break;  
            case SDLK_DELETE:    keycode = 139; break;  
            case SDLK_ESCAPE:    keycode = 140; break;  
            case SDLK_F1:        keycode = 141; break;  
            case SDLK_F2:        keycode = 142; break;  
            case SDLK_F3:        keycode = 143; break;  
            case SDLK_F4:        keycode = 144; break;  
            case SDLK_F5:        keycode = 145; break;  
            case SDLK_F6:        keycode = 146; break;  
            case SDLK_F7:        keycode = 147; break;  
            case SDLK_F8:        keycode = 148; break;  
            case SDLK_F9:        keycode = 149; break;  
            case SDLK_F10:       keycode = 150; break;  
            case SDLK_F11:       keycode = 151; break;  
            case SDLK_F12:       keycode = 152; break;  
            default:  
                // Regular ASCII characters  
                if (event.key.keysym.sym >= 32 && event.key.keysym.sym <= 126) {  
                    keycode = event.key.keysym.sym;  
                }  
                break;  
        }  
    } else if (event.type == SDL_KEYUP) {  
        keycode = 0; // Clear keycode when key is released  
    }  
      
    // Update keyboard memory location  
    // Note: Adjust this based on your actual memory interface  
    top->keyboard = keycode;  
}