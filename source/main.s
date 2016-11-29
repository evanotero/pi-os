/**
 * File:    main.s
 * Author:  Evan Otero
 *
 * ARMv6
 * An operating system that turns on the OK LED
 */

.section .init              @ directive to linker to put this code first
.globl _start               @ directive to toolchain to tell where entry point is
_start:
    ldr     r0, =0x20200000 @ address of GPIO controller

    mov     r1, #1          @ r1 = 1
    lsl     r1, #18         @ 6th set of 3bits -> left shift 6 * 3 = 18 -> r1 = 1000000000000000000
    str     r1, [r0, #4]    @ enable GPIO 16 pin for output

    mov     r1, #1          @ r1 = 1
    mov     r1, #16         @ left shift 16 -> r1 = 10000000000000000
    str     r1, [r0, #40]   @ set GPIO 16 to low, causing the LED to turn on

loop$:
    b       loop$           @ give Pi task to do forever, so it will not crash
