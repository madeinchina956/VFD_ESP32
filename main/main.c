#include <stdio.h>

#include "wifi.h"
#include "uart_common.h"
#include "tft_display.h"
#include "vfd_ui.h"
#include "ui_home.h"
#include "encoder.h"
#include "ui_task.h"
#include "buttons.h"

void app_main(void)
{
    printf("Starting VFD ESP32...\n");

    // Initialize Wi-Fi
    wifi_init();

    // Initialize UART
    uart_loopback_test();

    // Initialize TFT display
    tft_display_init();

    // Draw home screen
    // 0 means the first menu item starts selected
    ui_home_draw(0);

    // Initialize rotary encoder
    encoder_init();

    // Initialize Start/Stop buttons
    buttons_init();

    // Start UI task
    ui_task_start();
}