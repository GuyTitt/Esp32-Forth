// forth_start.S — point d’entrée et mini boucle d’interprétation

.section .text
.global _start
.extern forth_init
.extern uart_init
.extern uart_getc
.extern uart_putc
.extern forth_add
.extern forth_dup

_start:
    call forth_init
    call uart_init

loop:
    call uart_getc
    movi a1, '+'
    beq a0, a1, do_add
    movi a1, 'd'
    beq a0, a1, do_dup
    j loop

do_add:
    call forth_add
    j loop

do_dup:
    call forth_dup
    j loop
