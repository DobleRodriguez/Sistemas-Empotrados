/*****************************************************************************/
/*                                                                           */
/* Sistemas Empotrados                                                       */
/* Prueba del driver de UART de nivel 0 para la Redwire EconoTAG             */
/*                                                                           */
/*****************************************************************************/

#include "system.h"

/*
 * Constantes relativas a la plataforma
 */

#define LED_RED		gpio_pin_44
#define LED_GREEN	gpio_pin_45
#define KBI0            gpio_pin_22
#define KBI1            gpio_pin_23
#define KBI4            gpio_pin_26
#define KBI5            gpio_pin_27


/*
 * Constantes relativas a la aplicacion
 */
uint32_t const delay = 0x10000;
 
/*****************************************************************************/

/*
 * Inicialización de los pines de E/S
 */
void gpio_init (void)
{
	/* Configuramos el GPIO44 y GPIO45 para que sean de salida */
        gpio_set_pin_dir_output (LED_RED);
        gpio_set_pin_dir_output (LED_GREEN);

        /* Configuramos los KBI0 y KBI1 para que sean de salida */
        /* y KBI4 y KBI5 para que sean de entrada */
        //gpio_set_port_dir_output (gpio_port_0, (1 << KBI0) | (1 << KBI1));
        //gpio_set_port_dir_input (gpio_port_0, (1 << KBI4) | (1 << KBI5));

        /* Fijamos un 1 en KBI0 y KBI1 */
        //gpio_set_port (gpio_port_0, (1 << KBI0) | (1 << KBI1));
}

/*****************************************************************************/

/*
 * Enciende el led indicado según su pin
 * @param pin Pin al que está conectado el led
 */
void led_on (uint32_t pin)
{
	gpio_set_pin (pin);
}

/*****************************************************************************/

/*
 * Apaga el led indicado según su pin
 * @param pin Pin al que está conectado el led
 */
void led_off (uint32_t pin)
{
	gpio_clear_pin (pin);
}

/*****************************************************************************/

/*
 * Retardo para el parpedeo
 */
void pause (void)
{
        uint32_t i;
	for (i=0 ; i<delay ; i++);
}

/*****************************************************************************/

/*
 * Selecciona el led que se debe parpadear en función del estado de los botones
 * @param current_led  Pin del led actualmente selecionado
 * @return             Pin del led que se seguirá parpadeando
 */
uint32_t select_led (uint32_t current_led)
{
	uint32_t the_led, port0_data;

        gpio_get_port (gpio_port_0, &port0_data);

        the_led = current_led;

        if (port0_data & (1 << KBI4))
            the_led = LED_GREEN;
        else if (port0_data & (1 << KBI5))
            the_led = LED_RED;

        return the_led;
}

void switch_led(gpio_pin_t led) {
    uint32_t estado;
    gpio_get_pin(led, &estado);
    if (estado) {
        gpio_clear_pin(led);
    } else {
        gpio_set_pin(led);
    }
}

/*****************************************************************************/

/*
 * Programa principal
 */
int main ()
{
    gpio_init();
    uint8_t caracter;
    uint32_t i;
    uint8_t string[45] = "Error: solo son validas las teclas 'r' o 'g'";
	while (1) {
		caracter = uart_receive_byte(uart_1);
        if (caracter == 'r') {
            switch_led(LED_RED);
        } else if (caracter == 'g') {
            switch_led(LED_GREEN);
        } else {
            i = 0;
            while (string[i] != '\0') {
                uart_send_byte(uart_1, string[i]);
                i++;
            }
        }
	}
    return 0;
}

/*****************************************************************************/
