#include "encoder.h"

#include "driver/gpio.h"
#include "freertos/FreeRTOS.h"
#include "freertos/task.h"
#include "esp_timer.h"

#define ENCODER_A       GPIO_NUM_32
#define ENCODER_B       GPIO_NUM_33
#define ENCODER_BUTTON  GPIO_NUM_25

// Encoder position in detents
static volatile int encoder_value = 0;

// Button event
static volatile bool button_event = false;


// Quadrature transition table
static const int8_t transition_table[16] =
{
     0, -1,  1,  0,
     1,  0,  0, -1,
    -1,  0,  0,  1,
     0,  1, -1,  0
};


static void encoder_task(void *arg)
{
    int previous_state;

    int accumulator = 0;

    // Button debounce variables
    int last_button_raw = 1;
    int stable_button = 1;

    int64_t button_change_time = 0;


    int a = gpio_get_level(ENCODER_A);
    int b = gpio_get_level(ENCODER_B);

    previous_state = (a << 1) | b;


    while (1)
    {
        /*
         * -------------------------
         * Read rotary encoder
         * -------------------------
         */

        a = gpio_get_level(ENCODER_A);
        b = gpio_get_level(ENCODER_B);

        int current_state = (a << 1) | b;

        int table_index =
            (previous_state << 2) |
            current_state;

        accumulator += transition_table[table_index];

        previous_state = current_state;


        /*
         * KY-040 normally produces about
         * four quadrature transitions
         * for one physical detent.
         */

        if (accumulator >= 4)
        {
            encoder_value++;

            accumulator = 0;
        }
        else if (accumulator <= -4)
        {
            encoder_value--;

            accumulator = 0;
        }


        /*
         * -------------------------
         * Read encoder push button
         * -------------------------
         */

        int raw_button =
            gpio_get_level(ENCODER_BUTTON);

        int64_t now =
            esp_timer_get_time();


        // Raw state changed
        if (raw_button != last_button_raw)
        {
            last_button_raw = raw_button;

            button_change_time = now;
        }


        /*
         * State must remain unchanged
         * for 30 ms before accepting it.
         */
        if ((now - button_change_time) > 30000)
        {
            if (raw_button != stable_button)
            {
                stable_button = raw_button;

                // Active LOW
                if (stable_button == 0)
                {
                    button_event = true;
                }
            }
        }


// Allow other FreeRTOS tasks to run
    vTaskDelay(pdMS_TO_TICKS(10));    }
}


void encoder_init(void)
{
    gpio_config_t config =
    {
        .pin_bit_mask =
            (1ULL << ENCODER_A) |
            (1ULL << ENCODER_B) |
            (1ULL << ENCODER_BUTTON),

        .mode = GPIO_MODE_INPUT,

        .pull_up_en = GPIO_PULLUP_ENABLE,

        .pull_down_en = GPIO_PULLDOWN_DISABLE,

        .intr_type = GPIO_INTR_DISABLE
    };


    gpio_config(&config);


    xTaskCreate(
        encoder_task,
        "encoder_task",
        2048,
        NULL,
        5,
        NULL
    );
}


int encoder_get_value(void)
{
    return encoder_value;
}


bool encoder_button_pressed(void)
{
    if (button_event)
    {
        button_event = false;

        return true;
    }
    return false;
}