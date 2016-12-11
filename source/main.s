/**
 * File:    main.s
 * Author:  Evan Otero
 *
 * ARMv6
 * An operating system that turns the ACT LED on and off repeatedly.
 *
 * IMPORTANT NOTES:
 * - Pi 0 inherits increased pin count of newer Pi's.
 * - GPIO47 is now the ACT LED.
 * - Use GPFSEL4 bit 21 to enable GPIO47.
 * - Need bit 15 for GPSET1 and GPCLR0.
 */

.section .init              @ directive to linker to put this code first
.globl _start               @ directive to toolchain to tell where entry point is

_start:
    LDR     R0, =0x20200000 @ address of GPIO controller

    MOV     R1, #1
    LSL     R1, #21         @ 7th set of 3 bits -> GPFSEL4 bit
    STR     R1, [r0, #16]   @ enable GPIO47 for output

    MOV     R1, #1
    LSL     R1, #15         @ put a 1 in 15th bit of message

/* Turn LED on and off frepeatedly */
LOOP$:
    STR     R1, [r0, #44]   @ set GPIO47 to HIGH (44) -> LED turns ON
    MOV     R2, #0x3F0000   @ initialize wait start amount

/* Wait until R2 == 0 */
WAIT1$:
    SUB     R2, #1
    CMP     R2, #0
    BNE     WAIT1$

    STR     R1, [r0, #32]   @ set GPIO47 to LOW (32) -> LED turns OFF
    MOV     R2, #0x3F0000   @ initialize wait start amount

/* Wait until R2 == 0 */
WAIT2$:
    SUB     R2, #1
    CMP     R2, #0
    BNE     WAIT2$

    B       LOOP$
