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
    BL          SetGraphicsAddress

    lastRandom  .req R7
    lastX       .req R8
    lastY       .req R9
    color       .req R10
    MOV         lastRandom, #0
    MOV         lastX, #0
    MOV         lastY, #0
    MOV         color, #0

    x           .req R5
    y           .req R6

    @ Make lines (loop forever)
RENDER$:
    @ Generate next x-coordinate
    MOV         R0, lastRandom
    BL          Random
    MOV         x, R0

    @ Generate next y-coordinate
    BL          Random
    MOV         y, R0

    @ Update last random number
    MOV         lastRandom, y

    @ Set line color
    MOV         R0, color
    BL          SetForeColor
    ADD         color, #1
    LSL         color, #16
    LSR         color, #16      @ set to 0 if above 0xFFFF

    @ Convet x and y to be between 0 and 1023
    LSR         R2, x, #22
    LSR         R3, y, #22

    @ Check that y is on screen
    CMP         R3, #768
    BHS         RENDER$    

    @ Update last x, y
    MOV         R0, lastX
    MOV         R1, lastY
    MOV         lastX, R2
    MOV         lastY, R3

    @ Draw line from last x, y
    BL          DrawLine

    B           RENDER$

    .unreq      x
    .unreq      y
    .unreq      lastRandom
    .unreq      lastX
    .unreq      lastY
    .unreq      color
