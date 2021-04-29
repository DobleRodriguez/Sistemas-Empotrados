#include "system.h"

#define LED_RED     gpio_pin_44
#define LED_GREEN   gpio_pin_45
#define KBI0        gpio_pin_22
#define KBI1        gpio_pin_23
#define KBI4        gpio_pin_26
#define KBI5        gpio_pin_27

void esperar (void) {
    int i, retardo = 100000;
    for (i=0; i < retardo; i++);
}

gpio_pin_t select_led () {
    uint32_t data0;
    gpio_pin_t the_led;
    gpio_get_port(gpio_port_0, &data0);
    if (data0 & (1 << KBI4)) {
        the_led = LED_GREEN;
    } else if (data0 & (1 << KBI5)) {
        the_led = LED_RED;
    }
    return the_led;
}

int main () {

    gpio_pin_t the_led;

    gpio_set_port_func (gpio_port_0, gpio_func_alternate_1, 1);
    gpio_set_pin_dir_output (LED_RED);
    gpio_set_pin_dir_output (LED_GREEN);
    gpio_set_pin_dir_output (KBI0);
    gpio_set_pin_dir_output (KBI1);
    gpio_set_pin (KBI0);
    gpio_set_pin (KBI1);

    the_led = LED_RED;

    while (1) {
        the_led = select_led();
        gpio_set_pin (the_led);
        esperar();
        gpio_clear_pin (the_led);
        the_led = select_led();    
        esperar();
    }

    return 0;
}