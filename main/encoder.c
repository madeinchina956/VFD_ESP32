#include "encoder.h"

#include <stdio.h>

#include "driver/gpio.h"
#include "freertos/FreeRTOS.h"
#include "freertos/task.h"


//    GPIO assignments for the rotary encoder (KY-040):
//    ENCODER_A:      GPIO32 Signal used to determine signal A
//    ENCODER_B:      GPIO33 Signal used to determine signal B
//    ENCODER_BUTTON: GPIO25 Push button signal

#define ENCODER_A       GPIO_NUM_32
#define ENCODER_B       GPIO_NUM_33
#define ENCODER_BUTTON  GPIO_NUM_25

// Stores the current position of the encoder
static int encoder_value = 0;
// Uses the previous and current A/B encoder states
// to determine the direction of rotation
// +1 = one direction
// -1 = the other direction
// 0 = no movement
static const int8_t transition_table[16] =
{
     0, -1,  1,  0,
     1,  0,  0, -1,
    -1,  0,  0,  1,
     0,  1, -1,  0
};

//Monitors the encoder and updates the encoder_value variable.
static void encoder_task(void *arg)
{   //Reads the initial encoder state
    int previous_state =
        (gpio_get_level(ENCODER_A) << 1) |
         gpio_get_level(ENCODER_B);
    //Tracks movement between encoder clicks
    int movement = 0;
    //Reads the initial button state
    int last_button =
        gpio_get_level(ENCODER_BUTTON);

    while (1)
    {   //Reads the initial encoder state
        int current_state =
            (gpio_get_level(ENCODER_A) << 1) |
             gpio_get_level(ENCODER_B);

        // Combines previous and current states
        int index =
            (previous_state << 2) |
             current_state;
        // Determines movement direction
        movement +=
            transition_table[index];

        previous_state =
            current_state;
        // One step clockwise
        if (movement >= 4)
        {
            encoder_value++;
            printf(
                "Encoder value: %d\n",
                encoder_value
            );
            movement = 0;
        }
        // One step counter-clockwise
        else if (movement <= -4)
        {
            encoder_value--;
            printf(
                "Encoder value: %d\n",
                encoder_value
            );
            movement = 0;
        }

        // Reads the encoder push-button
        int current_button =
            gpio_get_level(ENCODER_BUTTON);
        // Detect button press on the falling edge (1->0)
        if (
            last_button == 1 &&
            current_button == 0
        )
        {
            printf("Encoder: BUTTON\n");

            // Short delay to reduce the button bouncing
            vTaskDelay(
                pdMS_TO_TICKS(30)
            );
        }
        // Save button state for the next loop
        last_button =
            current_button;
        // Delay to reduce CPU usage
        vTaskDelay(
            pdMS_TO_TICKS(1)
        );
    }
}
//Initializes the encoder GPIO pins and starts the encoder task.
void encoder_init(void)
{
    gpio_config_t encoder_config = {
        // Configure encoder A, B, and button pins as inputs
        .pin_bit_mask =
            (1ULL << ENCODER_A) |
            (1ULL << ENCODER_B) |
            (1ULL << ENCODER_BUTTON),
        // Encoder signals are inputs
        .mode =
            GPIO_MODE_INPUT,
        // Enable internal pull-up resistors for the encoder pins
        .pull_up_en =
            GPIO_PULLUP_ENABLE,
        // Disable pull-down resistors for the encoder pins
        .pull_down_en =
            GPIO_PULLDOWN_DISABLE,
        // Encoder is read through polling, so interrupts are not needed
        .intr_type =
            GPIO_INTR_DISABLE
    };
    // Apply GPIO configuration for the encoder pins
    gpio_config(
        &encoder_config
    );
    // Starts the FreeRTOS task that monitors the encoder
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
{   //Returns the current encoder value
    return encoder_value;
}