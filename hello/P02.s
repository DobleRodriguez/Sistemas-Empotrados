@
@ Sistemas Empotrados
@ El "hola mundo" en la Redwire EconoTAG
@

@
@ Constantes
@

    @ Registro de control de dirección del GPIO
    .set GPIO_PAD_DIR0,    0x80000000
    .set GPIO_PAD_DIR1,    0x80000004

    @ Registro de activación de bits del GPIO
    .set GPIO_DATA_SET0,    0x80000048
    .set GPIO_DATA_SET1,    0x8000004c

    @ Registro de limpieza de bits del GPIO
    .set GPIO_DATA_RESET1,  0x80000054

    @ Registro de control del GPIO00-31
    .set GPIO_DATA0,        0x80000008  

    @ El led rojo está en el GPIO 44 (el bit 12 de los registros GPIO_X_1)
    @ El led verde está en el GPIO 45 (el bit 13 de los registros GPIO_X_1)
    .set LED_RED_MASK,     (1 << (44-32))
    .set LED_GREEN_MASK,    (1 << (45-32))

    @ Los botones a usar están en el GPIO 22-26 y 23-27
    .set BUTTON_INPUT0,     (1 << 22)
    .set BUTTON_OUTPUT0,    (1 << 26)
    .set BUTTON_INPUT1,     (1 << 23)
    .set BUTTON_OUTPUT1,    (1 << 27)   

    @ Retardo para el parpadeo
    .set DELAY,            0x000f0000

@
@ Punto de entrada
@

    .code 32
    .text
    .global _start
    .type   _start, %function

_start:
    bl gpio_init

loop:
    @ Encendemos el led
    bl test_buttons
    str     r5, [r6]

    @ Pausa corta
    ldr     r0, =DELAY
    bl      pause

    @ Apagamos el led
    bl test_buttons
    str     r5, [r7]

    @ Pausa corta
    ldr     r0, =DELAY
    bl      pause

    @ Bucle infinito
    b       loop
        
@
@ Función que produce un retardo
@ r0: iteraciones del retardo
@
.type   pause, %function
pause:
    subs    r0, r0, #1
    bne     pause
    mov     pc, lr

.type   gpio_init, %function
gpio_init:
    ldr r4, =GPIO_PAD_DIR0
    ldr r5, =BUTTON_OUTPUT0
    orr r5, r5, #BUTTON_OUTPUT1
    str r5, [r4]

    ldr r4, =GPIO_PAD_DIR1
    ldr r5, =LED_GREEN_MASK
    orr r5, r5, #LED_RED_MASK
    str r5, [r4]

    ldr r4, =GPIO_DATA_SET0
    ldr r5, = BUTTON_OUTPUT0
    orr r5, r5, #BUTTON_OUTPUT1
    str r5, [r4]

    ldr r5, =LED_RED_MASK
    ldr r6, =GPIO_DATA_SET1
    ldr r7, =GPIO_DATA_RESET1

    mov pc, lr
    
    
.type test_buttons, %function
test_buttons:
    ldr r4, =GPIO_DATA0
    ldr r4, [r4]
    tst r4, #BUTTON_INPUT0
    ldrne r5, =LED_GREEN_MASK
    ldrne r1, =LED_RED_MASK
    strne r1, [r7]

    tst r4, #BUTTON_INPUT1
    ldrne r5, =LED_RED_MASK
    ldrne r1, =LED_GREEN_MASK
    strne r1, [r7]

    mov pc, lr

