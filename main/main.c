#include <stdio.h>

#include "wifi.h"
#include "uart_test.h"
#include "tft_display.h"
#include "encoder.h"
#include "ui_task.h"


void app_main(void)
{
    printf("Starting VFD ESP32...\n");
    // Initialize Wi-Fi
    wifi_init();
    // Run UART loopback test
    uart_loopback_test();
    // Initialize TFT display
    tft_display_init();
    // Initialize rotary encoder
    encoder_init();
    // Start the local TFT user interface
    ui_task_start();
    printf("VFD ESP32 initialized.\n");
}