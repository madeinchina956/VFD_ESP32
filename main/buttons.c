#include "buttons.h"

#include "driver/gpio.h"
#include "freertos/FreeRTOS.h"
#include "freertos/task.h"
#include "esp_timer.h"

// Match schematic
#define START_BUTTON GPIO_NUM_34
#define STOP_BUTTON  GPIO_NUM_35

// Button press events
static volatile bool start_event = false;
static volatile bool stop_event = false;


// Monitors Start and Stop buttons
static void button_task(void *arg)
{
    int last_start_raw = 1;
    int last_stop_raw = 1;

    int stable_start = 1;
    int stable_stop = 1;

    int64_t start_change_time = 0;
    int64_t stop_change_time = 0;


    while (1)
    {
        int start_raw =
            gpio_get_level(START_BUTTON);

        int stop_raw =
            gpio_get_level(STOP_BUTTON);

        int64_t now =
            esp_timer_get_time();


        /*
         * -------------------------
         * START button debounce
         * -------------------------
         */

        if (start_raw != last_start_raw)
        {
            last_start_raw = start_raw;
            start_change_time = now;
        }

        // State must stay stable for 30 ms
        if ((now - start_change_time) > 30000)
        {
            if (start_raw != stable_start)
            {
                stable_start = start_raw;

                // Button is active LOW
                if (stable_start == 0)
                {
                    start_event = true;
                }
            }
        }


        /*
         * -------------------------
         * STOP button debounce
         * -------------------------
         */

        if (stop_raw != last_stop_raw)
        {
            last_stop_raw = stop_raw;
            stop_change_time = now;
        }

        // State must stay stable for 30 ms
        if ((now - stop_change_time) > 30000)
        {
            if (stop_raw != stable_stop)
            {
                stable_stop = stop_raw;

                // Button is active LOW
                if (stable_stop == 0)
                {
                    stop_event = true;
                }
            }
        }


// Allow other FreeRTOS tasks to run
vTaskDelay(pdMS_TO_TICKS(10));    }
}


void buttons_init(void)
{
    gpio_config_t config =
    {
        .pin_bit_mask =
            (1ULL << START_BUTTON) |
            (1ULL << STOP_BUTTON),

        .mode = GPIO_MODE_INPUT,

        /*
         * GPIO34 and GPIO35 do NOT have
         * internal pull-up resistors.
         *
         * The schematic already provides
         * external 10k pull-ups to 3.3V.
         */
        .pull_up_en = GPIO_PULLUP_DISABLE,

        .pull_down_en = GPIO_PULLDOWN_DISABLE,

        .intr_type = GPIO_INTR_DISABLE
    };


    gpio_config(&config);


    xTaskCreate(
        button_task,
        "button_task",
        2048,
        NULL,
        5,
        NULL
    );
}


bool start_button_pressed(void)
{
    if (start_event)
    {
        start_event = false;
        return true;
    }

    return false;
}


bool stop_button_pressed(void)
{
    if (stop_event)
    {
        stop_event = false;
        return true;
    }

    return false;
}