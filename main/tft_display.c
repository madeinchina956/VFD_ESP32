#include "tft_display.h"

#include "driver/gpio.h"
#include "driver/spi_master.h"
#include "esp_err.h"
#include "freertos/FreeRTOS.h"
#include "freertos/task.h"

#define TFT_SPI_HOST SPI2_HOST

#define TFT_MOSI  GPIO_NUM_23
#define TFT_SCLK  GPIO_NUM_18
#define TFT_CS    GPIO_NUM_5
#define TFT_DC    GPIO_NUM_2
#define TFT_RST   GPIO_NUM_4

static spi_device_handle_t tft_spi;

void tft_display_write_command(uint8_t command)
{
    gpio_set_level(TFT_DC, 0);

    spi_transaction_t transaction = {
        .length = 8,
        .tx_buffer = &command
    };

    ESP_ERROR_CHECK(spi_device_transmit(tft_spi, &transaction));
}

void tft_display_write_data(const uint8_t *data, int length)
{
    gpio_set_level(TFT_DC, 1);

    spi_transaction_t transaction = {
        .length = length * 8,
        .tx_buffer = data
    };

    ESP_ERROR_CHECK(spi_device_transmit(tft_spi, &transaction));
}

void tft_display_init(void)
{
    gpio_config_t io_config = {
        .pin_bit_mask =
            (1ULL << TFT_CS) |
            (1ULL << TFT_DC) |
            (1ULL << TFT_RST),
        .mode = GPIO_MODE_OUTPUT
    };

    ESP_ERROR_CHECK(
        gpio_config(&io_config)
    );

    spi_bus_config_t bus_config = {
        .mosi_io_num = TFT_MOSI,
        .miso_io_num = -1,
        .sclk_io_num = TFT_SCLK,
        .quadwp_io_num = -1,
        .quadhd_io_num = -1,
        .max_transfer_sz = 4096
    };

    spi_device_interface_config_t device_config = {
        .clock_speed_hz = 1000000,
        .mode = 0,
        .spics_io_num = TFT_CS,
        .queue_size = 1
    };

    ESP_ERROR_CHECK(
        spi_bus_initialize(TFT_SPI_HOST, &bus_config, SPI_DMA_CH_AUTO)
    );

    ESP_ERROR_CHECK(
        spi_bus_add_device(TFT_SPI_HOST, &device_config, &tft_spi)
    );

    // Hardware reset
    gpio_set_level(TFT_RST, 0);
    vTaskDelay(pdMS_TO_TICKS(100));

    gpio_set_level(TFT_RST, 1);
    vTaskDelay(pdMS_TO_TICKS(100));

    // Software reset
    tft_display_write_command(0x01);
    vTaskDelay(pdMS_TO_TICKS(150));

    // Exit sleep
    tft_display_write_command(0x11);
    vTaskDelay(pdMS_TO_TICKS(150));

    // RGB565
    tft_display_write_command(0x3A);

    uint8_t pixel_format = 0x55;
    tft_display_write_data(&pixel_format, 1);

    // Screen orientation
    tft_display_write_command(0x36);

    uint8_t memory_access = 0x48;
    tft_display_write_data(&memory_access, 1);

    // Display ON
    tft_display_write_command(0x29);
    vTaskDelay(pdMS_TO_TICKS(100));
}