/*
 * Sistemas Empotrados
 * Test del BSP
 */

#include "system.h"

#define LED_RED		gpio_pin_44
#define LED_GREEN	gpio_pin_45

/*****************************************************************************/

/*
 * Inicialización de los pines de E/S que gestionan los leds
 */
void leds_init (void)
{
	/* Configuramos el GPIO44 y GPIO45 para que sean de salida */
        gpio_set_pin_dir_output (LED_RED);
        gpio_set_pin_dir_output (LED_GREEN);
}

/*****************************************************************************/

/**
 * Imprime una cadena de caracteres por la UART1
 * @param str La cadena
 */
void print_str(char * str)
{
        while (*str)
                uart_send_byte(UART1_ID, *str++);
}

/*****************************************************************************/

/**
 * Programa principal
 */
int main ()
{
        char c;
        uint32_t led_red_state, led_green_state;

        /* Inicializamos los pines de los leds, que inicialmente están apagados */
        leds_init ();
        led_red_state = led_green_state = 0;

        print_str("Pulsa 'g' o 'r'\n\r");

        while(1)
        {
                c = uart_receive_byte(UART1_ID);
                if (c =='r' || c == 'R')
                {

                        if (led_red_state)
                        {
                                gpio_clear_pin(LED_RED);
                                print_str("Apagando el led rojo\n\r");
                        }
                        else
                        {
                                gpio_set_pin(LED_RED);
                                print_str("Encendiendo el led rojo\n\r");
                        }

                        led_red_state = !led_red_state;
                }
                else if (c =='g' || c == 'G')
                {
                        if (led_green_state)
                        {
                                gpio_clear_pin(LED_GREEN);
                                print_str("Apagando el led verde\n\r");
                        }
                        else
                        {
                                gpio_set_pin(LED_GREEN);
                                print_str("Encendiendo el led verde\n\r");
                        }

                        led_green_state = !led_green_state;
                }
                else
                        print_str("Pulsa 'g' o 'r'\n\r");

        }

	return 0;
}

/*****************************************************************************/
