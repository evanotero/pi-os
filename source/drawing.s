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

/*
    Draws a single pixel to the screen at (x,y).
    Steps:
        1. Load in the graphicsAddress
        2. Validate x and y
        3. Compute the address of the pixel
        4. Load foreColor
        5. Store at the address
    void DrawPixel(u32x2 point);
 */
.globl DrawPixel
DrawPixel:
    @ Load graphicsAddress
    px          .req R0
    py          .req R1
    addr        .req R2
    LDR         addr, =graphicsAddress
    LDR         addr, [addr]

    @ Validate x, y
    height      .req R3
    LDR         height, [addr, #4]
    SUB         height, #1
    CMP         py, height
    MOVHI       PC, LR
    .unreq      height

    width       .req R3
    LDR         width, [addr, #0]
    SUB         width, #1
    CMP         px, width
    MOVHI       PC, LR

    @ Compute address of pixel
    LDR         addr, [addr, #32]   @ GPU - Pointer
    ADD         width, #1
    MLA         px, py, width, px   @ px = py * width + px
    .unreq      width
    .unreq      py
    ADD         addr, px, LSL #1    @ addr + px * 2^1
    .unreq      px

    @ Load foreColor
    fore        .req R3
    LDR         fore, =foreColor
    LDRH        fore, [fore]

    @ Store
    STRH        fore, [addr]
    .unreq      fore
    .unreq      addr
    MOV         PC, LR
