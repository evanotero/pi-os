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

    @ Find the cmdline tag
    MOV         R0, #9
    BL          FindTag

    @ Draw our command line
    LDR         R1, [R0]
    LSL         R1, #2
    SUB         R1, #8              @ strnig length
    ADD         R0, #8

    MOV         R2, #0              @ x-coordinate
    MOV         R3, #0              @ y-coordinate
    BL          DrawString

LOOP$:
    b LOOP$