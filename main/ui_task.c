#include "ui_task.h"

#include <stdio.h>

#include "encoder.h"
#include "tft_graphics.h"

#include "freertos/FreeRTOS.h"
#include "freertos/task.h"


// Task that updates the display when the encoder changes
static void ui_task(void *arg)
{
    int last_value = -9999;

    while (1)
    {
        int current_value = encoder_get_value();

        if (current_value != last_value)
        {
            printf("Updating display: %d\n", current_value);

            tft_draw_number(
                120,
                100,
                current_value,
                COLOR_WHITE,
                COLOR_BLACK
            );

            last_value = current_value;
        }

        vTaskDelay(pdMS_TO_TICKS(20));
    }
}


// Start UI task
void ui_task_start(void)
{
    xTaskCreate(
        ui_task,
        "ui_task",
        4096,
        NULL,
        5,
        NULL
    );
}