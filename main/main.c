#include <stdio.h>

#include "wifi.h"
#include "uart_test.h"
#include "tft_display.h"
#include "vfd_ui.h"
#include "encoder.h"

void app_main(void)
{
    printf("Starting VFD ESP32...\n");

    wifi_init();
    uart_loopback_test();

    tft_display_init();
    vfd_ui_show_home();
    encoder_init();
}