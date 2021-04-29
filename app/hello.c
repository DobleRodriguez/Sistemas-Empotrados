/*****************************************************************************/
/*                                                                           */
/* Sistemas Empotrados                                                       */
/* El "hola mundo" en la Redwire EconoTAG en C                               */
/*                                                                           */
/*****************************************************************************/

#include <stdint.h>
#include "system.h"

/*
 * Constantes relativas a la plataforma
 */

/* Dirección del registro de control de dirección del GPIO32-GPIO63 */
volatile uint32_t * const reg_gpio_pad_dir0    = (uint32_t *) 0x80000000;
volatile uint32_t * const reg_gpio_pad_dir1    = (uint32_t *) 0x80000004;

volatile uint32_t * const reg_gpio_data0   = (uint32_t *) 0x80000008;

/* Dirección del registro de activación de bits del GPIO32-GPIO63 */
volatile uint32_t * const reg_gpio_data_set0   = (uint32_t *) 0x80000048;
volatile uint32_t * const reg_gpio_data_set1   = (uint32_t *) 0x8000004c;

/* Dirección del registro de limpieza de bits del GPIO32-GPIO63 */
volatile uint32_t * const reg_gpio_data_reset1 = (uint32_t *) 0x80000054;



/* El led rojo está en el GPIO 44 (el bit 12 de los registros GPIO_X_1) */
uint32_t const led_red_mask = (1 << (44-32));
uint32_t const led_green_mask = (1 << (45-32));

uint32_t const button_input0 = (1 << 22);
uint32_t const button_output0 = (1 << 26);
uint32_t const button_input1 = (1 << 23);
uint32_t const button_output1 = (1 << 27);

/*
 * Constantes relativas a la aplicacion
 */
uint32_t const delay = 0x10000;
 
/*****************************************************************************/


/*
 * Inicialización de los pines de E/S
 */
void gpio_init(void)
{
	/* Configuramos el GPIO44 para que sea de salida */
	*reg_gpio_pad_dir0 = button_output0 + button_output1;
	*reg_gpio_pad_dir1 = led_red_mask + led_green_mask;
	*reg_gpio_data_set0 = button_output0 + button_output1;
}

/*****************************************************************************/

/*
 * Enciende los leds indicados en la máscara
 * @param mask Máscara para seleccionar leds
 */
void leds_on (uint32_t mask)
{
	/* Encendemos los leds indicados en la máscara */
	*reg_gpio_data_set1 = mask;
}

/*****************************************************************************/

/*
 * Apaga los leds indicados en la máscara
 * @param mask Máscara para seleccionar leds
 */
void leds_off (uint32_t mask)
{
	/* Apagamos los leds indicados en la máscara */
	*reg_gpio_data_reset1 = mask;
}

/*****************************************************************************/

/*
 * Retardo para el parpedeo
 */
void pause(void)
{
        uint32_t i;
	for (i=0 ; i<delay ; i++);
}

__attribute__((interrupt ("UNDEF")))
void my_handler ()
{
	leds_on(led_green_mask);
}

/*****************************************************************************/

/*
 * Máscara del led que se hará parpadear
 */
uint32_t the_led;

/*
 * Programa principal
 */
int main ()
{	
	excep_set_handler (excep_undef, my_handler);
	gpio_init();
	the_led = led_red_mask;
	//asm(".word 0x26889912\n");
	while (1)
	{
		if ((*reg_gpio_data0 & button_input1) != 0) {
			the_led = led_red_mask;
			leds_off(led_green_mask);
		} if ((*reg_gpio_data0 & button_input0) != 0) {
			the_led = led_green_mask;
			leds_off(led_red_mask);
		}
		leds_on(the_led);
		pause();

		if ((*reg_gpio_data0 & button_input1) != 0) {
			the_led = led_red_mask;
			leds_off(led_green_mask);
		} if ((*reg_gpio_data0 & button_input0) != 0) {
			the_led = led_green_mask;
			leds_off(led_red_mask);
		}
		leds_off(the_led);
		pause();
	}

        return 0;
}


/*****************************************************************************/

