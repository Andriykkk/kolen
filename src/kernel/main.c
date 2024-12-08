#include <stdint.h>

#define VGA_BUFFER 0xB8000
#define WHITE_ON_BLUE 0x1F

void kernel_main(void)
{
    volatile uint16_t *vga_buffer = (volatile uint16_t *)VGA_BUFFER;

    const char *hello = "Hello Wosdld!";

    int i = 0;
    while (hello[i] != '\0')
    {
        vga_buffer[i] = (WHITE_ON_BLUE << 8) | hello[i];
        i++;
    }

    while (1)
    {
    }
}

// Linker function declarations
void _start(void) __attribute__((noreturn));
void _start(void)
{
    kernel_main();
    while (1)
    {
    }
}

__attribute__((section(".entry"))) void entry()
{
    _start();
}
