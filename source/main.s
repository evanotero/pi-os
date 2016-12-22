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

.section .init                  @ directive to linker to put this code first
.globl _start                   @ directive to toolchain to tell where entry point is
_start:
    B       main

.section .text
main:
    MOV     SP, #0x8000

    pinNum  .req R0
    pinFunc .req R1
    MOV     pinNum, #47
    MOV     pinFunc, #1

    BL      SetGpioFunction     @ Set function of GPIO port 47 to 001
    .unreq  pinNum
    .unreq  pinFunc

/* Turn LED on and off frepeatedly */
LOOP$:
    pinNum  .req R0
    pinVal  .req R1
    MOV     pinNum, #47
    MOV     pinVal, #1

    BL      SetGpio             @ turn LED on
    .unreq  pinNum
    .unreq  pinVal

    decr    .req R0
    MOV     decr, #0x3F0000     @ initialize wait start amount

/* Wait until decr == 0 */
WAIT1$:
    SUB     decr, #1
    CMP     decr, #0
    BNE     WAIT1$
    .unreq  decr

    pinNum  .req R0
    pinVal  .req R1
    MOV     pinNum, #47
    MOV     pinVal, #0

    BL      SetGpio             @ turn LED off      
    .unreq  pinNum
    .unreq  pinVal

    decr    .req R0
    MOV     decr, #0x3F0000     @ initialize wait start amount

/* Wait until decr == 0 */
WAIT2$:
    SUB     decr, #1
    CMP     decr, #0
    BNE     WAIT2$
    .unreq  decr

    B       LOOP$               @ loop over process forever
