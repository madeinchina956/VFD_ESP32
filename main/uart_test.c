#include "driver/uart.h"
#include "driver/gpio.h"
#include "esp_log.h"
#include <string.h>

#define UART_PORT       UART_NUM_1
#define UART_TX_PIN     GPIO_NUM_17
#define UART_RX_PIN     GPIO_NUM_16
#define UART_BAUD_RATE  115200

static const char *TAG = "UART_TEST";

void uart_loopback_test(void)
{
    const uart_config_t uart_config = {
        .baud_rate = UART_BAUD_RATE,
        .data_bits = UART_DATA_8_BITS,
        .parity = UART_PARITY_DISABLE,
        .stop_bits = UART_STOP_BITS_1,
        .flow_ctrl = UART_HW_FLOWCTRL_DISABLE,
        .source_clk = UART_SCLK_DEFAULT,
    };

    uart_driver_install(UART_PORT, 1024, 1024, 0, NULL, 0);
    uart_param_config(UART_PORT, &uart_config);
    uart_set_pin(
        UART_PORT,
        UART_TX_PIN,
        UART_RX_PIN,
        UART_PIN_NO_CHANGE,
        UART_PIN_NO_CHANGE
    );

    const char *message = "Hello from ESP32!\r\n";

    uart_write_bytes(UART_PORT, message, strlen(message));

    uint8_t data[128];

    int length = uart_read_bytes(
        UART_PORT,
        data,
        sizeof(data) - 1,
        pdMS_TO_TICKS(1000)
    );

    if (length > 0)
    {
        data[length] = '\0';

        ESP_LOGI(TAG, "Received: %s", (char *)data);
    }
    else
    {
        ESP_LOGE(TAG, "No data received!");
    }
}