/**
 * File:    main.s
 * Author:  Evan Otero
 *
 * ARMv6
 * An operating system that turns the OK LED on and off repeatedly.
 */

.section .init              @ directive to linker to put this code first
.globl _start               @ directive to toolchain to tell where entry point is

_start:
    LDR     R0, =0x20200000 @ address of GPIO controller

    MOV     R1, #1
    LSL     R1, #18         @ 6th set of 3 bits
    STR     R1, [r0, #4]    @ enable GPIO 16 pin for output

    MOV     R1, #1
    MOV     R1, #16         @ put a 1 in 16th bit of message

/* Turn LED on and off frepeatedly */
LOOP$:
    STR     R1, [r0, #40]   @ set GPIO 16 to LOW (40) -> LED turns ON
    MOV     R2, #0x3F0000   @ initialize wait start amount

/* Wait until R2 == 0 */
WAIT1$:
    SUB     R2, #1
    CMP     R2, #0
    BNE     WAIT1$

    STR     R1, [r0, #28]   @ set GPIO 16 to HIGH (28) -> LED turns OFF
    MOV     R2, #0x3F0000   @ initialize wait start amount

/* Wait until R2 == 0 */
WAIT2$:
    SUB     R2, #1
    CMP     R2, #0
    BNE     WAIT2$

    B       LOOP$
