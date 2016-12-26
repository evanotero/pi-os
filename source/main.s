/**
 * File:    main.s
 * Author:  Evan Otero
 *
 * ARMv6
 * An operating system that controls the screen and ACT LED for RPi Zero.
 *
 * IMPORTANT NOTES:
 * - Pi 0 inherits increased pin count of newer Pi's.
 * - GPIO47 is now the ACT LED.
 * - Use GPFSEL4 bit 21 to enable GPIO47.
 * - Need bit 15 for GPSET1 and GPCLR0.
 * - Pin val:
 *     - 1 -> LED off
 *     - 0 -> LED on
 * - Pictures are stored left to right, then top to bottom
 */

.section .init                      @ directive to linker to put this code first
.globl _start                       @ directive to toolchain to tell where entry point is
_start:
    B           main

.section .text
main:
    @ Set the stack pointer to 0x8000.
    MOV         SP, #0x8000

    @ Set up screen
    MOV         R0, #1024
    MOV         R1, #768
    MOV         R2, #16
    BL          InitializeFrameBuffer

    @ Check for failed frame buffer
    TEQ         R0, #0
    BNE         NOERROR$

    MOV         R0, #47
    MOV         R1, #1
    BL          SetGpioFunction
    MOV         R0, #47
    MOV         R1, #0
    BL          SetGpio

ERROR$:
    B           ERROR$

NOERROR$:
    fbInfoAddr  .req R4
    MOV         fbInfoAddr, R0

    @ Set pixels (loop forever)
RENDER$:
    fbAddr      .req R3
    LDR         fbAddr, [fbInfoAddr, #32]   @ GPU Pointer

    @ Keep track of current color
    color       .req R0
    y           .req R1
    MOV         y, #768

    DRAWROW$:
        x       .req R2
        MOV     x, #1024

        DRAWPIXEL$:
            STRH    color, [fbAddr] @ Post-index: STRH    color, [fbAddr], #2
            ADD     fbAddr, #2
            SUB     x, #1
            TEQ     x, #0
            BNE     DRAWPIXEL$

        .unreq  x
        SUB     y, #1
        ADD     color, #1
        TEQ     y, #0
        BNE     DRAWROW$

    .unreq      y
    B           RENDER$

    .unreq      fbAddr
    .unreq      fbInfoAddr
