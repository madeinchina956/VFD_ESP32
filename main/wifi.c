#include <stdio.h>
#include <string.h>
#include "wifi.h"

#include "freertos/FreeRTOS.h"
#include "freertos/event_groups.h"

#include "esp_wifi.h"
#include "esp_event.h"
#include "esp_log.h"
#include "esp_netif.h"

#include "nvs_flash.h"

#define WIFI_SSID "VFD_Controller"
#define WIFI_PASSWORD "VFD_Motor_2026"

static const char *TAG = "WIFI";

void wifi_init(void)
{
    printf("Initializing Wi-Fi Access Point...\n");

    // Initialize NVS
    esp_err_t ret = nvs_flash_init();

    if (ret == ESP_ERR_NVS_NO_FREE_PAGES ||
        ret == ESP_ERR_NVS_NEW_VERSION_FOUND)
    {
        ESP_ERROR_CHECK(nvs_flash_erase());
        ret = nvs_flash_init();
    }

    ESP_ERROR_CHECK(ret);

    // Initialize network interface
    ESP_ERROR_CHECK(esp_netif_init());

    // Create the default event loop
    ESP_ERROR_CHECK(esp_event_loop_create_default());

    // Create Wi-Fi Access Point interface
    esp_netif_create_default_wifi_ap();

    // Initialize Wi-Fi
    wifi_init_config_t cfg = WIFI_INIT_CONFIG_DEFAULT();
    ESP_ERROR_CHECK(esp_wifi_init(&cfg));

    // Set Wi-Fi mode to Access Point
    ESP_ERROR_CHECK(esp_wifi_set_mode(WIFI_MODE_AP));

    // Configure Access Point
    wifi_config_t wifi_config = {
        .ap = {
            .ssid = WIFI_SSID,
            .ssid_len = strlen(WIFI_SSID),
            .channel = 1,
            .password = WIFI_PASSWORD,
            .max_connection = 4 ,
            .authmode = WIFI_AUTH_WPA2_PSK
        }
    };

    ESP_ERROR_CHECK(
        esp_wifi_set_config(WIFI_IF_AP, &wifi_config)
    );

    // Start Wi-Fi
    ESP_ERROR_CHECK(esp_wifi_start());

    ESP_LOGI(TAG, "Wi-Fi Access Point started");
    ESP_LOGI(TAG, "SSID: %s", WIFI_SSID);
    ESP_LOGI(TAG, "Password: %s", WIFI_PASSWORD);
}