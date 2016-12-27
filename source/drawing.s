/**
 * File:    drawing.s
 * Author:  Evan Otero
 *
 * Contains code to do with drawing shapes to the screen.
 *
 * IMPORTANT NOTES:
 * - Address of pixel = frameBufferAddress + (x + y * width) * pixel size
 */

/*
    Color to draw shapes in.
    short foreColor;
 */
.section .data
.align 1
foreColor:
    .hword  0xFFFF

/*
    Address of the frame buffer info structure. 
    FrameBuferDescription* graphicsAddress;
 */
.align 2
graphicsAddress:
    .int    0

/*
    Changes the current drawing color to the 16 bit colour in r0.
    void SetForeColor(u16 color);
 */
.section .text
.globl SetForeColor
SetForeColor:
    @ Validate input
    CMP         R0, #0x10000
    MOVHS       PC, LR

    @ Set foreColor
    LDR         R1, =foreColor
    STRH        R0, [R1]
    MOV         PC, LR

/*
    Changes the current frame buffer information to graphicsAddress.
    void SetGraphicsAddress(FrameBuferDescription* value);
 */
.globl SetGraphicsAddress
SetGraphicsAddress:
    LDR         R1, =graphicsAddress
    STR         R0, [R1]
    MOV         PC, LR

    MOV         PC, LR
