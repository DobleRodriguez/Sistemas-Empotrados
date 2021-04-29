@
@ Sistemas Empotrados
@ El "hola mundo" en la Redwire EconoTAG
@

@
@ Variables globales
@
        .data

led_red_mask:
        @ El led rojo esta en el GPIO44 (bit 12 de los registros GPIO_X_1)
        .word   (1 << (44-32))

led_green_mask:
        @ El led verde esta en el GPIO45 (bit 13 de los registros GPIO_X_1)
        .word   (1 << (45-32))

kbi0_mask:
        @ KBI0 esta en el GPIO22
        .word   (1 << 22)

kbi1_mask:
        @ KBI1 esta en el GPIO23
        .word   (1 << 23)

kbi4_mask:
        @ KBI4 esta en el GPIO26
        .word   (1 << 26)

kbi5_mask:
        @ KBI5 esta en el GPIO27
        .word   (1 << 27)

delay:
        @ Retardo para el parpadeo
        .word   0x000070000

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

        @ Usaremos r4 para mantener el retardo
        ldr     r0, =delay
        ldr     r4, [r0]

        @ Usaremos r5 para mantener la mascara del led que debe parpadear
        @ Por defecto escogemos el rojo
        ldr     r0, =led_red_mask
        ldr     r5, [r0]

        @ Direcciones de los registros GPIO_DATA_SET1 y GPIO_DATA_RESET1
        ldr     r6, =gpio_data_set1
        ldr     r7, =gpio_data_reset1
loop:
        @ Encendemos led
        bl      test_buttons
        str     r5, [r6]

        @ Pausa corta
        mov     r0, r4
        bl      pause

        @ Apagamos el led
        str     r5, [r7]
        bl      test_buttons

        @ Pausa corta
        ldr     r0, =delay
        bl      pause

        @ Bucle infinito
        b       loop

        .type   gpio_init, %function
gpio_init:
        @ Configuramos los GPIO44 y GPIPO45 para que sean de salida
        ldr     r0, =led_red_mask
        ldr     r1, [r0]

        ldr     r0, =led_green_mask
        ldr     r2, [r0]

        orr     r1, r1, r2
        ldr     r0, =gpio_pad_dir1
        str     r1, [r0]

@
@ Chequea si se ha pulsado algun boton. Si asi fuera, cambia el valor del registro
@ r5 segun el boton pulsado. S2 -> led rojo, S3 -> led verde
@
        .type   test_buttons, %function
test_buttons:
        @ Leemos el registro de datos GPIO_DATA0
        ldr     r0, =gpio_data0
        ldr     r1, [r0]

        ldr     r0, =kbi4_mask
        ldr     r2, [r0]
        tst     r1, r2
        ldrne   r0, =led_green_mask
        ldrne   r5, [r0]

        ldr     r0, =kbi5_mask
        ldr     r2, [r0]
        tst     r1, r2
        ldrne   r0, =led_red_mask
        ldrne   r5, [r0]

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
