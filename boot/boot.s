    .section .literal
    .align  4
    .literal base_addr, 0x3FFE0000    # Adresse de base du Forth (RAM interne)
    .literal ram_top,   0x3FFF0000    # Haut de la RAM utilisateur
    .literal ram_end,   0x3FFF8000    # Fin de la RAM disponible
    .literal cold_addr, cold_start    # Adresse du mot COLD

    .section .text.start
    .global _start
    .type _start, @function

_start:
    rsil    a15, 0                    # Désactive les interruptions
    l32r    a10, base_addr            # a10 = pointeur de base
    l32r    a11, ram_top
    s32i    a11, a10, 0               # RAM_TOP = 0x3FFF0000
    l32r    a11, ram_end
    s32i    a11, a10, 4               # RAM_END = 0x3FFF8000
    l32r    a11, cold_addr
    s32i    a11, a10, 8               # IP = COLD
    j       forth_vm                  # Démarre la VM Forth

    .size _start, . - _start

    .section .rodata
    .align  4

cold_start:
    .word   xt_docol
    .word   xt_lit, 13, xt_emit       # CR
    .word   xt_lit, 10, xt_emit       # LF
    .word   xt_lit, 'O', xt_emit      # O
    .word   xt_lit, 'K', xt_emit      # K
    .word   xt_lit, '>', xt_emit      # >
    .word   xt_lit, ' ', xt_emit      # espace
    .word   xt_accept_loop
    .word   xt_bye

xt_docol:       .word 0xDEADC0DE
xt_emit:        .word 0xDEADC0DE
xt_accept_loop: .word 0xDEADC0DE
xt_bye:         .word 0xDEADC0DE
# boot/boot.s - VERSION 1.1.4
