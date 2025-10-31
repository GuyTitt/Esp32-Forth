// forth_io.S — UART pour console Forth ESP32

.section .text
.global uart_init
.global uart_putc
.global uart_getc
.global uart_print

.set UART0_BASE, 0x3FF40000
.set UART_FIFO_REG,  UART0_BASE + 0x0
.set UART_STATUS_REG, UART0_BASE + 0x1C

uart_init:
    ret

uart_putc:
1:  l32i a1, UART_STATUS_REG, 0
    bbsi a1, 31, 1b
    s32i a0, UART_FIFO_REG, 0
    ret

uart_getc:
2:  l32i a1, UART_STATUS_REG, 0
    bbci a1, 0, 2b
    l32i a0, UART_FIFO_REG, 0
    ret

uart_print:
3:  l8ui a1, a0, 0
    beqz a1, 4f
    call uart_putc
    addi a0, a0, 1
    j 3b
4:  ret
