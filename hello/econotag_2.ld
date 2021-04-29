/*****************************************************************************/
/*                                                                           */
/* Sistemas Empotrados                                                       */
/*                                                                           */
/* Linker script para la Redwire EconoTAG                                    */
/*                                                                           */
/*****************************************************************************/

/*****************************************************************************/
/* Punto de entrada                                                          */
/*****************************************************************************/

ENTRY(_start)

/*
 * Mapa de memoria de la placa
 */
MEMORY
{
        ram0 :  org = 0x00400000,       len = 0x00002000        /* (8  KB) */
        ram1 :  org = 0x00402000,       len = 0x00006000        /* (24 KB) */
        ram2 :  org = 0x00408000,       len = 0x00008000        /* (32 KB) */
        ram3 :  org = 0x00410000,       len = 0x00008000        /* (32 KB) */
        /* gpio :  org = 0x80000000,       len = 0x00000064        (64  B) */
}

SECTIONS
{
        /* Código del programa */
        .text : ALIGN(4) /* Alineamiento 4 bytes 32bits */
        {
                *(.text);
        } > ram0

        /* Datos del programa */
        .data : ALIGN(4)
        {
                *(.data);
        } > ram0

        /* Direcciones de GPIO */

        gpio_base = 0x8000000;

        /* Registro de control de dirección del GPIO00-GPIO31 */
        gpio_pad_dir0 = gpio_base + 0x00000000;

        /* Registro de control de dirección del GPIO32-GPIO63 */
        gpio_pad_dir1 = gpio_base + 0x00000004;

        /* Registro de datos del GPIO00-GPIO31 */
        gpio_data0 = gpio_base + 0x00000008;

        /* Registro de activacion de bits del GPIO00-GPIO31 */
        gpio_data_set0 = gpio_base + 0x00000048;

        /* Registro de activacion de bits del GPIO32-GPIO63 */
        gpio_data_set1 = gpio_base + 0x0000004c;

        /* Registro de limpieza de bits del GPIO32-GPIO63 */
        gpio_data_reset1 = gpio_base + 0x00000054;
}
