#include "tft_display.h"

#include "driver/gpio.h"
#include "driver/spi_master.h"
#include "esp_err.h"

#include "freertos/FreeRTOS.h"
#include "freertos/task.h"


// SPI peripheral used for the TFT
#define TFT_SPI_HOST SPI2_HOST


// TFT pin assignments from PCB schematic
#define TFT_MOSI  GPIO_NUM_23
#define TFT_MISO  GPIO_NUM_19
#define TFT_SCLK  GPIO_NUM_18
#define TFT_CS    GPIO_NUM_21
#define TFT_DC    GPIO_NUM_22
#define TFT_RST   GPIO_NUM_17


// SPI device handle
static spi_device_handle_t tft_spi;


// Send a command byte to the TFT
void tft_display_write_command(uint8_t command)
{
    // DC LOW = command
    gpio_set_level(TFT_DC, 0);

    spi_transaction_t transaction = {
        .length = 8,
        .tx_buffer = &command
    };

    ESP_ERROR_CHECK(
        spi_device_transmit(
            tft_spi,
            &transaction
        )
    );
}


// Send data bytes to the TFT
void tft_display_write_data(
    const uint8_t *data,
    int length
)
{
    // DC HIGH = data
    gpio_set_level(TFT_DC, 1);

    spi_transaction_t transaction = {
        .length = length * 8,
        .tx_buffer = data
    };

    ESP_ERROR_CHECK(
        spi_device_transmit(
            tft_spi,
            &transaction
        )
    );
}


// Send the same RGB565 color many times
void tft_display_write_color_repeat(
    uint16_t color,
    int count
)
{
    // 64 pixels x 2 bytes each
    uint8_t buffer[128];

    uint8_t high_byte =
        (color >> 8) & 0xFF;

    uint8_t low_byte =
        color & 0xFF;


    // Fill buffer with one color
    for (int i = 0; i < 64; i++)
    {
        buffer[i * 2] =
            high_byte;

        buffer[(i * 2) + 1] =
            low_byte;
    }


    // Send pixels in groups
    while (count > 0)
    {
        int pixels_to_send;

        if (count > 64)
        {
            pixels_to_send = 64;
        }
        else
        {
            pixels_to_send = count;
        }

        tft_display_write_data(
            buffer,
            pixels_to_send * 2
        );

        count -= pixels_to_send;
    }
}


// Initialize TFT display
void tft_display_init(void)
{
    // Configure CS, DC, and RESET as outputs
    gpio_config_t io_config = {

        .pin_bit_mask =
            (1ULL << TFT_CS) |
            (1ULL << TFT_DC) |
            (1ULL << TFT_RST),

        .mode =
            GPIO_MODE_OUTPUT,

        .pull_up_en =
            GPIO_PULLUP_DISABLE,

        .pull_down_en =
            GPIO_PULLDOWN_DISABLE,

        .intr_type =
            GPIO_INTR_DISABLE
    };


    ESP_ERROR_CHECK(
        gpio_config(
            &io_config
        )
    );


    // Configure SPI bus
    spi_bus_config_t bus_config = {

        // ESP32 GPIO23 -> TFT MOSI
        .mosi_io_num =
            TFT_MOSI,

        // TFT MISO -> ESP32 GPIO19
        .miso_io_num =
            TFT_MISO,

        // ESP32 GPIO18 -> TFT SCK
        .sclk_io_num =
            TFT_SCLK,

        .quadwp_io_num =
            -1,

        .quadhd_io_num =
            -1,

        .max_transfer_sz =
            4096
    };


    ESP_ERROR_CHECK(
        spi_bus_initialize(
            TFT_SPI_HOST,
            &bus_config,
            SPI_DMA_CH_AUTO
        )
    );


    // Configure TFT SPI device
    spi_device_interface_config_t device_config = {

        // Start at 1 MHz for reliable testing
        .clock_speed_hz =
            1000000,

        // ILI9341 uses SPI Mode 0
        .mode =
            0,

        // ESP32 GPIO21 -> TFT CS
        .spics_io_num =
            TFT_CS,

        .queue_size =
            1
    };


    ESP_ERROR_CHECK(
        spi_bus_add_device(
            TFT_SPI_HOST,
            &device_config,
            &tft_spi
        )
    );


    // Hardware reset
    gpio_set_level(
        TFT_RST,
        0
    );

    vTaskDelay(
        pdMS_TO_TICKS(100)
    );


    gpio_set_level(
        TFT_RST,
        1
    );

    vTaskDelay(
        pdMS_TO_TICKS(100)
    );


    // Software reset
    tft_display_write_command(
        0x01
    );

    vTaskDelay(
        pdMS_TO_TICKS(150)
    );


    // Exit sleep mode
    tft_display_write_command(
        0x11
    );

    vTaskDelay(
        pdMS_TO_TICKS(150)
    );


    // Set RGB565 color mode
    tft_display_write_command(
        0x3A
    );

    uint8_t pixel_format =
        0x55;

    tft_display_write_data(
        &pixel_format,
        1
    );


    // Set display orientation
    tft_display_write_command(
        0x36
    );

    uint8_t memory_access =
        0x48;

    tft_display_write_data(
        &memory_access,
        1
    );


    // Turn display on
    tft_display_write_command(
        0x29
    );

    vTaskDelay(
        pdMS_TO_TICKS(100)
    );
}