@
@ Sistemas Empotrados
@ El "hola mundo" en la Redwire EconoTAG
@

@
@ Constantes
@

    @ Registro de control de dirección del GPIO
    @.set GPIO_PAD_DIR0,    0x80000000
    @.set gpio_pad_dir1,    0x80000004

    @ Registro de activación de bits del GPIO
    @.set GPIO_DATA_SET0,    0x80000048
    @.set GPIO_DATA_SET1,    0x8000004c

    @ Registro de limpieza de bits del GPIO
    @.set GPIO_DATA_RESET1,  0x80000054

    @ Registro de control del GPIO00-31
    @.set GPIO_DATA0,        0x80000008  


    .data
    @ El led rojo está en el GPIO 44 (el bit 12 de los registros GPIO_X_1)
    @ El led verde está en el GPIO 45 (el bit 13 de los registros GPIO_X_1)
led_red_mask: .word     (1 << (44-32))
led_green_mask: .word    (1 << (45-32))

    @ Los botones a usar están en el GPIO 22-26 y 23-27
button_input0: .word    (1 << 22)
button_output0: .word    (1 << 26)
button_input1: .word    (1 << 23)
button_output1: .word    (1 << 27)   

    @ Retardo para el parpadeo
delay: 
        .word            0x000f0000

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
    ldr     r0, =delay
    bl      pause

    @ Apagamos el led
    bl test_buttons
    str     r5, [r7]

    @ Pausa corta
    ldr     r0, =delay
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

    ldr r4, =gpio_pad_dir0
    ldr r5, =button_output0
    ldr r5, [r5]
    ldr r1, =button_output1
    ldr r1, [r1]
    orr r5, r5, r1
    str r5, [r4]

    ldr r4, =gpio_pad_dir1
    ldr r5, =led_green_mask
    ldr r5, [r5]
    ldr r6, =led_red_mask
    ldr r6, [r6]
    orr r5, r5, r6
    str r5, [r4]

    ldr r4, =gpio_data_set0
    ldr r5, =button_output0
    ldr r5, [r5]
    ldr r1, =button_output1
    ldr r1, [r1]
    orr r5, r5, r1
    str r5, [r4]


    ldr r5, =led_red_mask
    ldr r5, [r5]
    ldr r6, =gpio_data_set1
    ldr r7, =gpio_data_reset1

    mov pc, lr
    
.type test_buttons, %function
test_buttons:
    ldr r4, =gpio_data0
    ldr r4, [r4]
    ldr r1, =button_input0
    ldr r1, [r1]
    tst r4, r1
    ldrne r5, =led_green_mask
    ldrne r5, [r5]
    ldrne r1, =led_red_mask
    ldrne r1, [r1]
    strne r1, [r7]

    ldr r1, =button_input1
    ldr r1, [r1]
    tst r4, r1
    ldrne r5, =led_red_mask
    ldrne r5, [r5]
    ldrne r1, =led_green_mask
    ldrne r1, [r1]
    strne r1, [r7]

    mov pc, lr


