// forth_core.S — noyau Forth de base (pile et primitives arithmétiques)
// version 0.0

.section .data
.align 4

data_stack:     .space 1024
return_stack:   .space 512

dp: .word data_stack+1024
rp: .word return_stack+512

.section .text
.global forth_init
.global forth_push
.global forth_pop
.global forth_dup
.global forth_drop
.global forth_add
.global forth_sub
.global forth_swap

forth_init:
    la a2, data_stack+1024
    s32i a2, dp, 0
    la a2, return_stack+512
    s32i a2, rp, 0
    ret

forth_push:
    l32i a2, dp, 0
    addi a2, a2, -4
    s32i a0, a2, 0
    s32i a2, dp, 0
    ret

forth_pop:
    l32i a2, dp, 0
    l32i a0, a2, 0
    addi a2, a2, 4
    s32i a2, dp, 0
    ret

forth_dup:
    call forth_pop
    mov a1, a0
    call forth_push
    mov a0, a1
    call forth_push
    ret

forth_drop:
    l32i a2, dp, 0
    addi a2, a2, 4
    s32i a2, dp, 0
    ret

forth_add:
    call forth_pop
    mov a1, a0
    call forth_pop
    add a0, a0, a1
    call forth_push
    ret

forth_sub:
    call forth_pop
    mov a1, a0
    call forth_pop
    sub a0, a0, a1
    call forth_push
    ret

forth_swap:
    call forth_pop
    mov a1, a0
    call forth_pop
    mov a2, a0
    mov a0, a1
    call forth_push
    mov a0, a2
    call forth_push
    ret

// fichier forth_core.S Version: 0.0
