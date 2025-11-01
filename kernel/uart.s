    .section .literal
    .align  4
    .literal uart_base, 0x3FF40000    # UART0 base
    .literal baud_div,  694           # 115200 @ 80MHz
    .literal conf_8n1,  0x03          # 8N1
    .literal tx_enable, 0x01          # TX enable

    .section .text
    .global uart_init
    .global uart_putc
    .global uart_getc

uart_init:
    l32r    a2, uart_base
    l32r    a3, baud_div
    s32i    a3, a2, 0x14              # UART_CLKDIV
    l32r    a3, conf_8n1
    s32i    a3, a2, 0x0C              # UART_CONF0
    l32r    a3, tx_enable
    s32i    a3, a2, 0x00              # UART_CONF1 (TX enable)
    ret

uart_putc:
    l32r    a3, uart_base
1:  l32i    a4, a3, 0x20              # UART_STATUS
    extui   a4, a4, 23, 1             # TXFIFO_EMPTY
    bnez    a4, 1b
    s32i    a2, a3, 0x00              # UART_FIFO
    ret

uart_getc:
    l32r    a3, uart_base
1:  l32i    a4, a3, 0x20
    extui   a4, a4, 15, 1             # RXFIFO_FULL
    bnez    a4, 1b
    l32i    a2, a3, 0x00
    ret
# kernel/uart.s - VERSION 1.1.4
