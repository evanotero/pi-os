/**
 * File:    main.s
 * Author:  Evan Otero
 *
 * ARMv6
 * An operating system that turns the ACT LED on and off repeatedly for RPi Zero.
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

    pinNum      .req R0
    pinFunc     .req R1
    MOV         pinNum, #47
    MOV         pinFunc, #1

    BL          SetGpioFunction     @ Set function of GPIO port 47 to 001
    .unreq      pinNum
    .unreq      pinFunc

    ptrn        .req R4
    LDR         ptrn, =pattern
    LDR         ptrn, [ptrn]
    seq         .req R5
    MOV         seq, #0             @ sequence index

/* Turn LED on and off based on pattern */
LOOP$:
    pinNum      .req R0
    pinVal      .req R1
    MOV         pinNum, #47
    MOV         pinVal, #1
    LSL         pinVal, seq
    AND         pinVal, ptrn

    BL          SetGpio             @ turn LED on
    .unreq      pinNum
    .unreq      pinVal

    LDR         R0, =250000
    BL          Wait                @ Wait 0.25 seconds

    ADD         seq, #1             @ increment sequence index
    AND         seq, #31            @ if (seq >= 32) seq = 0

    B           LOOP$               @ loop over process forever

.section .data
.align 2                            @ align on multiple of 4
pattern:
    .int        0b11111111101010100010001000101010

