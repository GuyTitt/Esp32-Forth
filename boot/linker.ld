ENTRY(_start)

SECTIONS
{
    . = 0x40080000;

    .literal :
    {
        *(.literal)
        *(.literal.*)
        . = ALIGN(4);
    }

    .text :
    {
        *(.text.start)
        *(.text)
        *(.text.*)
        . = ALIGN(4);
    }

    .rodata :
    {
        *(.rodata)
        *(.rodata.*)
        . = ALIGN(4);
    }

    .data :
    {
        *(.data)
        *(.data.*)
        . = ALIGN(4);
    }

    .bss (NOLOAD) :
    {
        *(.bss)
        *(.bss.*)
        *(COMMON)
        . = ALIGN(4);
    }

    /DISCARD/ :
    {
        *(.comment)
        *(.eh_frame)
        *(.xtensa*)
    }
}
# boot/linker.ld - VERSION 1.0.11