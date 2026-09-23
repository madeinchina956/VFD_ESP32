#include <stdio.h>

#include "wifi.h"
#include "uart_test.h"
#include "tft_display.h"
#include "vfd_ui.h"
#include "encoder.h"
#include "ui_task.h"


void app_main(void)
{printf("Starting VFD ESP32...\n");

    // Initialize Wi-Fi
    wifi_init();

    // Run UART loopback test
    uart_loopback_test();

    // Initialize TFT
    tft_display_init();

    // Show VFD home screen
    vfd_ui_show_home();

    // Initialize rotary encoder
    encoder_init();

    // Start UI update task
    ui_task_start();
}