// forth_gpio.S — primitives GPIO pour Forth ESP32

.section .text
.global gpio_set
.global gpio_clear
.global gpio_read

.set GPIO_OUT_REG, 0x3FF44004
.set GPIO_IN_REG,  0x3FF4403C

gpio_set:
    call forth_pop
    movi a1, 1
    slli a1, a1, a0
    l32i a2, GPIO_OUT_REG, 0
    or a2, a2, a1
    s32i a2, GPIO_OUT_REG, 0
    ret

gpio_clear:
    call forth_pop
    movi a1, 1
    slli a1, a1, a0
    l32i a2, GPIO_OUT_REG, 0
    xor a2, a2, a1
    s32i a2, GPIO_OUT_REG, 0
    ret

gpio_read:
    call forth_pop
    movi a1, 1
    slli a1, a1, a0
    l32i a2, GPIO_IN_REG, 0
    and a0, a2, a1
    call forth_push
    ret
