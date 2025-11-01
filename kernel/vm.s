    .section .literal
    .align  4
    .literal base_addr,      0x3FFE0000
    .literal uart_putc_addr, uart_putc

    .section .text
    .global forth_vm
    .type forth_vm, @function

forth_vm:
    l32r    a10, base_addr            # a10 = base pointer
    l32i    a12, a10, 8               # a12 = IP

next:
    l32i    a13, a12, 0               # a13 = *IP++
    addi    a12, a12, 4
    s32i    a12, a10, 8
    jx      a13                       # jump to code

    .global xt_docol
xt_docol:
    l32i    a14, a10, 4               # a14 = RP
    addi    a14, a14, -4
    s32i    a12, a14, 0               # *--RP = IP
    s32i    a14, a10, 4
    addi    a12, a13, 4               # IP = CFA + 4
    j       next

    .global xt_exit
xt_exit:
    l32i    a14, a10, 4
    l32i    a12, a14, 0               # IP = *RP++
    addi    a14, a14, 4
    s32i    a14, a10, 4
    j       next

    .global xt_lit
xt_lit:
    l32i    a13, a12, 0               # a13 = *IP++
    addi    a12, a12, 4
    s32i    a12, a10, 8
    addi    a1, a1, -4                # push a13
    s32i    a13, a1, 0
    j       next

    .global xt_emit
xt_emit:
    l32i    a2, a1, 0                 # a2 = pop
    addi    a1, a1, 4
    l32r    a15, uart_putc_addr
    callx8  a15
    j       next

    .global xt_bye
xt_bye:
    j       xt_bye                    # boucle infinie
# kernel/vm.s - VERSION 1.1.4
