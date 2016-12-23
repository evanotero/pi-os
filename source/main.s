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
 */

.section .init                      @ directive to linker to put this code first
.globl _start                       @ directive to toolchain to tell where entry point is
_start:
    B           main

.section .text
main:
    MOV         SP, #0x8000

    pinNum      .req R0
    pinFunc     .req R1
    MOV         pinNum, #47
    MOV         pinFunc, #1

    BL          SetGpioFunction     @ Set function of GPIO port 47 to 001
    .unreq      pinNum
    .unreq      pinFunc

/* Turn LED on and off frepeatedly */
LOOP$:
    pinNum      .req R0
    pinVal      .req R1
    MOV         pinNum, #47
    MOV         pinVal, #1

    BL          SetGpio             @ turn LED on
    .unreq      pinNum
    .unreq      pinVal

    waitTime    .req R0
    LDR         waitTime, =100000
    BL          Wait                @ Wait 0.1 seconds
    .unreq      waitTime

    pinNum      .req R0
    pinVal      .req R1
    MOV         pinNum, #47
    MOV         pinVal, #0

    BL          SetGpio              @ turn LED off      
    .unreq      pinNum
    .unreq      pinVal

    waitTime    .req R0
    LDR         waitTime, =100000
    BL          Wait                @ Wait 0.1 seconds
    .unreq      waitTime

    B           LOOP$               @ loop over process forever
