@
@ Sistemas Empotrados
@ El "hola mundo" en la Redwire EconoTAG
@

@
@ Constantes
@
        @ Registro de control de dirección del GPIO00-GPIO31
        .set GPIO_PAD_DIR0,     0x80000000

        @ Registro de control de dirección del GPIO32-GPIO63
        .set GPIO_PAD_DIR1,     0x80000004

        @ Registro de control de datos del GPIO00-GPIO31
        .set GPIO_DATA0,        0x80000008

        @ Registro deactivacion de bits del GPIO00-GPIO31
        .set GPIO_DATA_SET0,    0x80000048

        @ Registro de activación de bits del GPIO32-GPIO63 @Encender
        .set GPIO_DATA_SET1,    0x8000004c

        @ Registro de limpieza de bits del GPIO32-GPIO63  @Apagar
        .set GPIO_DATA_RESET1,  0x80000054

        @ El led rojo está en el GPIO 44 (el bit 12 de los registros GPIO_X_1)
        .set LED_RED_MASK,      (1 << (44-32)) 
        .set LED_GREEN_MASK,    (1 << (45-32)) 

        @ KBI0 esta en el GPIO22
        .set KBI_0_MASK,         (1 << 22)

        @ KBI1 esta en el GPIO23
        .set KBI_1_MASK,         (1 << 23)

        @ KBI4 esta en el GPIO26
        .set KBI_4_MASK,         (1 << 26)

        @ KBI5 esta en el GPIO27
        .set KBI_5_MASK,        (1 << 27)

        @ Retardo para el parpadeo
        .set DELAY,            0x000070000

@
@ Punto de entrada
@

        .code 32
        .text
        .global _start
        .type   _start, %function

_start:
        @ Inicializamos los pines E/S
        bl      gpio_init

loop:
        @ Encendemos led
        bl      test_buttons
        str     r5, [r6]

        @ Pausa corta
        ldr     r0, =DELAY
        bl      pause

        @ Apagamos el led
        str     r5, [r7]
        bl      test_buttons

        @ Pausa corta
        ldr     r0, =DELAY
        bl      pause

        @ Bucle infinito
        b       loop

        .type   gpio_init, %function
gpio_init:
    @ Configuramos los GPIO44 y GPIPO45 para que sean de salida
    ldr     r4, =GPIO_PAD_DIR1
    ldr     r5, =(LED_RED_MASK|LED_GREEN_MASK)
    str     r5, [r4]

	@ Direcciones de los registros GPIO_DATA_SET1 y GPIO_DATA_RESET1
	ldr     r6, =GPIO_DATA_SET1
	ldr     r7, =GPIO_DATA_RESET1

    @ Configuramos los KBI0 y KBI1 para que sean de salida
    @ Configuramos los KBI4 y KBI5 para que sean de entrada
    @KBI_3:KBI_0 - outputs high
    @KBI_7:KBI_4 - inputs w / pull-downs enabled
    @ Fijamos un 1 en KBI0 y KBI1 (Si no ir al datasheet y mirar cuales son de entrada y de salida)
    @ O Fijar un 1 en los KBIs que sean de salida tras el reseteo, debe haber un 1 en los pines de salida
    
    @Empieza encendido el led rojo
    ldr     r5, =LED_RED_MASK
    mov     pc, lr
@
@ Chequea si se ha pulsado algun boton. Si asi fuera, cambia el valor del registro
@ r5 segun el boton pulsado. S2 -> led rojo, S3 -> led verde
@
        .type   test_buttons, %function
test_buttons:
        @ Leemos el registro de datos GPIO_DATA0
        @ Si no se pulsa 0x80000008(GPIO_DATA0) contiene 0x3f010
        @ Si se pulsa SW3 0x80000008(GPIO_DATA0) contiene 0x43f010 & 0x400000 #KBI_4_MASK
        @ Si se pulsa SW2 0x80000008(GPIO_DATA0) contiene 0x83f010 & 0x800000 #KBI_5_MASK
        @ Los dos pulsados a la vez:  0x80000008(GPIO_DATA0)  ->  0xc03d010

        ldr     r1, =GPIO_DATA0
        ldr     r1, [r1]

        @KBI_4_mask asociado al (led verde) boton S2
        @KBI_5_mask asociado al (led rojo)  boton S3

        @ Instruccion test dado un registro y una mascara (and) 
        tst     r1, #KBI_4_MASK  @(r1 & mask) Si esta pulsado -> resultado mask != 0
                                            @Si no esta pulsado -> resultado == 0

        @ Despues del test vamos a mirar los flags
        @copiar en r5 la mask led verde si test es != 0
        ldrne   r5, =LED_GREEN_MASK

        tst     r1, #KBI_5_MASK  @(r1 & mask) Si esta pulsado -> resultado mask != 0
                                            @Si no esta pulsado -> resultado == 0

        @ Despues del test vamos a mirar los flags
        @copiar en r5 la mask led rojo si test es != 0
        ldrne     r5, =LED_RED_MASK

        mov     pc, lr

@
@ Función que produce un retardo
@ r0: iteraciones del retardo
@
        .type   pause, %function
pause:
        subs    r0, r0, #1
        bne     pause
        mov     pc, lr
