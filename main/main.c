#include <stdio.h>

#include "esp_log.h"

#include "wifi.h"
#include "session_http.h"
#include "tft_display.h"
#include "vfd_ui.h"
#include "ui_home.h"
#include "encoder.h"
#include "ui_task.h"
#include "buttons.h"

void app_main(void)
{
    printf("Starting VFD ESP32 networking demo...\n");

    // Initialize Wi-Fi Access Point
    wifi_init();

    // Initialize HTTP session server
    esp_err_t result = session_http_start();

    if (result != ESP_OK)
    {
        ESP_LOGE(
            "SESSION",
            "HTTP server failed: %s",
            esp_err_to_name(result)
        );
    }
    else
    {
        ESP_LOGI(
            "SESSION",
            "HTTP session server started"
        );
    }

    // Initialize TFT display
    tft_display_init();

    // Draw Home screen
    ui_home_draw(0);

    // Initialize rotary encoder
    encoder_init();

    // Initialize buttons for existing UI simulation
    buttons_init();

    // Start UI task
    ui_task_start();
}