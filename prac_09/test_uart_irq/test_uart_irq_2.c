/*
 * Sistemas Empotrados
 * Test del BSP
 */

#include "system.h"

/*****************************************************************************/

/*
 * Constantes relativas a la plataforma
 */
#define LED_RED		gpio_pin_44
#define LED_GREEN	gpio_pin_45

/*****************************************************************************/

/**
 * Retardo para el parpedeo
 */
void esperar(void)
{
	int i, retardo = 100000;
	for (i=0 ; i<retardo ; i++);
}

/*****************************************************************************/

/**
 * Búfer para la función callback
 */
char buffer[26];

/**
 * Función callback de la uart
 * Manda imprimir un búfer en segundo plano
 */
void my_callback ()
{
	uart_send(uart_1,buffer, sizeof(buffer));
}

/*****************************************************************************/

/**
 * Programa principal
 * Se limita a parpadear leds
 * En segundo plano la ISR de la uart va transmitiendo el búffer
 */
int main ()
{
	uint32_t i;

	/* Inicializo el búfer */
	for (i=1, buffer[0]='a' ; i < sizeof(buffer) ; i++)
		buffer[i] = buffer[i-1] + 1;

	/* Configuro la función de callback */
	uart_set_send_callback(uart_1, my_callback);

	/* Comienza el envío */
	uart_send(uart_1,buffer, sizeof(buffer));

	/* Configuramos los pines de los leds para que sean de salida */
	gpio_set_pin_dir_output (LED_RED);
	gpio_set_pin_dir_output (LED_GREEN);

	while (1)
	{
		gpio_set_pin (LED_RED);
		gpio_clear_pin (LED_GREEN);
		esperar();
		gpio_set_pin (LED_GREEN);
		gpio_clear_pin (LED_RED);
		esperar();
	}

	return 0;
}

/*****************************************************************************/
