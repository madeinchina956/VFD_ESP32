#include "encoder.h"

#include <stdio.h>

#include "driver/gpio.h"
#include "freertos/FreeRTOS.h"
#include "freertos/task.h"

#define ENCODER_A       GPIO_NUM_32
#define ENCODER_B       GPIO_NUM_33
#define ENCODER_BUTTON  GPIO_NUM_25

static int encoder_value = 0;

/*
 * Valid quadrature transitions.
 *
 * This filters out most mechanical bouncing
 * and lets us count complete encoder steps.
 */
static const int8_t transition_table[16] =
{
     0, -1,  1,  0,
     1,  0,  0, -1,
    -1,  0,  0,  1,
     0,  1, -1,  0
};

static void encoder_task(void *arg)
{
    int previous_state =
        (gpio_get_level(ENCODER_A) << 1) |
         gpio_get_level(ENCODER_B);

    int movement = 0;

    int last_button =
        gpio_get_level(ENCODER_BUTTON);

    while (1)
    {
        int current_state =
            (gpio_get_level(ENCODER_A) << 1) |
             gpio_get_level(ENCODER_B);

        /*
         * Look up the direction of the transition.
         */
        int index =
            (previous_state << 2) |
             current_state;

        movement +=
            transition_table[index];

        previous_state =
            current_state;

        /*
         * A KY-040 normally produces several
         * electrical transitions per physical click.
         *
         * Only update after a complete step.
         */
        if (movement >= 4)
        {
            encoder_value++;

            printf(
                "Encoder value: %d\n",
                encoder_value
            );

            movement = 0;
        }

        else if (movement <= -4)
        {
            encoder_value--;

            printf(
                "Encoder value: %d\n",
                encoder_value
            );

            movement = 0;
        }

        /*
         * Push button.
         */
        int current_button =
            gpio_get_level(ENCODER_BUTTON);

        if (
            last_button == 1 &&
            current_button == 0
        )
        {
            printf("Encoder: BUTTON\n");

            /*
             * Simple button debounce.
             */
            vTaskDelay(
                pdMS_TO_TICKS(30)
            );
        }

        last_button =
            current_button;

        vTaskDelay(
            pdMS_TO_TICKS(1)
        );
    }
}

void encoder_init(void)
{
    gpio_config_t encoder_config = {
        .pin_bit_mask =
            (1ULL << ENCODER_A) |
            (1ULL << ENCODER_B) |
            (1ULL << ENCODER_BUTTON),

        .mode =
            GPIO_MODE_INPUT,

        .pull_up_en =
            GPIO_PULLUP_ENABLE,

        .pull_down_en =
            GPIO_PULLDOWN_DISABLE,

        .intr_type =
            GPIO_INTR_DISABLE
    };

    gpio_config(
        &encoder_config
    );

    xTaskCreate(
        encoder_task,
        "encoder_task",
        2048,
        NULL,
        5,
        NULL
    );

    printf("Encoder initialized\n");
}

int encoder_get_value(void)
{
    return encoder_value;
}