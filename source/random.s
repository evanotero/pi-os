/**
 * File:    random.s
 * Author:  Evan Otero
 *
 * Contains code for a quadratic congruence generator.
 *
 * IMPORTANT NOTES:
 * - a = 61184; b = 1; c = 73
 */

/*
    Function with an input of the last number it generated, and an 
    output of the next number in a pseduo random number sequence.
    u32 Random(u32 lastValue);
 */
.globl Random
Random:
    xnm         .req R0
    a           .req R1

    MOV         a, #0xEF00
    MUL         a, xnm
    MUL         a, xnm
    ADD         a, xnm
    .unreq      xnm
    ADD         R0, a, #73

    .unreq      a
    MOV         PC, LR
