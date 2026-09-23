// Registers all source files used by the ESP32 
idf_component_register(
    SRCS
        "main.c"            // Main program 
        "wifi.c"            // Wi-Fi access point setup
        "uart_test.c"       // UART Loopback Testing
        "tft_display.c"     // TFT SPI communication and initialization
        "tft_graphics.c"    // Drawing functions for shapes and numbers
        "tft_font.c"        // Character and text Drawing
        "vfd_ui.c"          // VFD User interface layout
        "encoder.c"         // Rotary encoder input handling
        "ui_task.c"         // Updates the display based on encoder input
    // Allow header files in this folder to be included
    INCLUDE_DIRS
        "."
)