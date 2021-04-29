/*
 * Sistemas Empotrados
 * Test del BSP
 */

#include <string.h>
#include "system.h"

#define LED_RED		gpio_pin_44
#define LED_GREEN	gpio_pin_45

/*
 * Constantes relativas a la aplicacion
 */
uint32_t const delay = 0x10000;

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

/**
 * Imprime una cadena de caracteres por la UART1
 * @param str La cadena
 */
void print_str(char * str)
{
        uart_send(UART1_ID, str, strlen(str));
}

/*****************************************************************************/

/**
 * Variables globales que controlan qué led debe parpadear
 */
uint32_t blink_red_led, blink_green_led;

/*****************************************************************************/

/**
 * Callback de entrada de la UART1. Implementa una consola de órdenes
 * rudimentaria para gestionar qué led debe parpadear
 *
 * Se ejecuta en el contexto de la ISR, por lo que debe ser ligera, ya que las
 * interrupciones están deshabilitadas
 */
void my_console ()
{
        char buf[100]; /* Búfer para recibir los datos */
        uint32_t len;
        uint32_t i;
        char c;

        /* Leemos los datos recibidos por la uart */
        len = uart_receive (uart_1, buf, 100);

        for (i = 0 ; i<len ; i++)
        {
                c = buf[i];
                if (c =='r' || c == 'R')
                {

                        if (blink_red_led)
                                print_str("Desactivando el led rojo\r\n");
                        else
                                print_str("Activando el led rojo\r\n");

                        blink_red_led = !blink_red_led;
                }
                else if (c =='g' || c == 'G')
                {
                        if (blink_green_led)
                                print_str("Desactivando el led verde\r\n");
                        else
                                print_str("Activando el led verde\r\n");

                        blink_green_led = !blink_green_led;
                }
                else
                        print_str("Pulsa 'g' o 'r'\r\n");

        }
}

/*****************************************************************************/

/**
 * Programa principal
 */
int main ()
{
        itc_disable_ints ();
        leds_init ();
        itc_restore_ints();

        blink_red_led = blink_green_led = 1;    /* Inicialmente activamos los dos */
        uart_set_receive_callback(uart_1, my_console);

        print_str("Pulsa 'g' o 'r'\r\n");

	while (1)
	{
                if (blink_red_led)
                        led_on(LED_RED);
                if (blink_green_led)
                        led_on(LED_GREEN);

                pause();

		led_off(LED_RED);
		led_off(LED_GREEN);
                pause();
	}

        return 0;
}

/*****************************************************************************/
