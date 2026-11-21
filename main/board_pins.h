
#ifndef BOARD_PINS_H
#define BOARD_PINS_H

// TFT ILI9341 Display
#define TFT_MISO       23
#define TFT_MOSI       21
#define TFT_SCLK       19
#define TFT_CS         18
#define TFT_DC          5
#define TFT_RST        17

// KY-040 Rotary Encoder
#define ENCODER_SW     25
#define ENCODER_DT     26
#define ENCODER_CLK    27

// ESP32 to dsPIC UART
#define DSPIC_UART_RX  14
#define DSPIC_UART_TX  12

// Start / Stop Buttons
#define START_BUTTON   34
#define STOP_BUTTON    35

// Boot Button
#define BOOT_BUTTON     0

#endif
