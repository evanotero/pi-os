/**
 * File:    drawing.s
 * Author:  Evan Otero
 *
 * Contains code to do with drawing shapes to the screen.
 *
 * IMPORTANT NOTES:
 * - Address of pixel = frameBufferAddress + (x + y * width) * pixel size
 * - Length of string and address of the string are stored 
 *   (instead of relying on terminating character).
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
    Fnot stores bitmap images for the first 128 characters.
 */
.align 4
font:
    .incbin "font.bin"

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

/*
    Uses Bresenham's Line Algortihm to draw a line between two points
    void DrawLine(u32x2 p1, u32x2 p2);
 */
.globl DrawLine
DrawLine:
    PUSH        {R4, R5, R6, R7, R8, R9, R10, R11, R12, LR}
    x0          .req R9
    x1          .req R10
    y0          .req R11
    y1          .req R12

    MOV         x0, R0
    MOV         x1, R2
    MOV         y0, R1
    MOV         y1, R3

    dx          .req R4     @ deltax
    dyn         .req R5     @ -deltay
    sx          .req R6     @ stepx
    sy          .req R7     @ stepy
    err         .req R8

    CMP         x1, x0
    SUBGT       dx, x1, x0
    MOVGT       sx, #1
    SUBLE       dx, x0, x1
    MOVLE       sx, #-1

    CMP         y1, y0
    SUBGT       dyn, y0, y1
    MOVGT       sy, #1
    SUBLE       dyn, y1, y0
    MOVLE       sy, #-1

    ADD         err, dx, dyn
    ADD         x1, sx
    ADD         y1, sx

PIXELLOOP$:
    @ Loop until x0 = x1 + stepx or y0 = y1 + stepy
    TEQ         x0, x1
    TEQNE       y0, y1
    POPEQ       {R4, R5, R6, R7, R8, R9, R10, R11, R12, PC}

    MOV         R0, x0
    MOV         R1, y0
    BL          DrawPixel

    CMP         dyn, err, LSL #1
    ADDLE       x0, sx
    ADDLE       err, dyn

    CMP         dx, err, LSL #1
    ADDGE       y0, sy
    ADDGE       err, dx

    B           PIXELLOOP$

    .unreq      x0
    .unreq      x1
    .unreq      y0
    .unreq      y1
    .unreq      dx
    .unreq      dyn
    .unreq      sx
    .unreq      sy
    .unreq      err

/*
    Renders image for a single character given and returns
    the width and the height.
    u32x2 DrawCharacter(char character, u32 x, u32 y);
 */
.globl DrawCharacter
DrawCharacter:
    CMP         R0, #127
    MOVHI       R0, #0
    MOVHI       R1, #0
    MOVHI       PC, LR

    PUSH        {R4, R5, R6, R7, R8, LR}
    x           .req R4
    y           .req R5
    charAddr    .req R6
    MOV         x, R1
    MOV         y, R2
    LDR         charAddr, =font
    ADD         charAddr, R0, LSL #4

LINELOOP$:
    bits        .req R7
    bit         .req R8
    LDRB        bits, [charAddr]
    MOV         bit, #8

    CHARPIXELLOOP$:
        SUBS    bit, #1
        BLT     CHARPIXELLOOPEND$

        LSL     bits, #1
        TST     bits, #0x100
        BEQ     CHARPIXELLOOP$

        ADD     R0, x, bit
        MOV     R1, y
        BL      DrawPixel

        TEQ     bit, #0
        BNE     CHARPIXELLOOP$

    CHARPIXELLOOPEND$:
        .unreq  bit
        .unreq  bits
        ADD     y, #1
        ADD     charAddr, #1
        TST     charAddr, #0b1111
        BNE     LINELOOP$

    .unreq      x
    .unreq      y
    .unreq      charAddr

    width       .req R0
    height      .req R1
    MOV         width, #8
    MOV         height, #16

    POP         {R4, R5, R6, R7, R8, PC}
    .unreq      width
    .unreq      height

/*
    Renders the image for a string of characters.
    Obeys new line and horizontal tab chars.
    u32x2 DrawString(char* string, u32 length, u32 x, u32 y);
 */
.globl DrawString
DrawString:
    x           .req R4
    y           .req R5
    x0          .req R6
    string      .req R7
    length      .req R8
    char        .req R9
    PUSH        {R4, R5, R6, R7, R8, R9, LR}

    MOV         string, R0
    MOV         length, R1
    MOV         x, R2
    MOV         x0, x
    MOV         y, R3

STRINGLOOP$:
    SUBS        length, #1
    BLT         STRINGLOOPEND$

    LDRB        char, [string]
    ADD         string, #1

    MOV         R0, char
    MOV         R1, x
    MOV         R2, y
    BL          DrawCharacter
    cwidth      .req R0
    cheight     .req R1

    TEQ         char, #'\n'
    MOVEQ       x, x0
    ADDEQ       y, cheight
    BEQ         STRINGLOOP$

    TEQ         char, #'\t'
    ADDNE       x, cwidth
    BNE         STRINGLOOP$

    ADD         cwidth, cwidth, LSL #2
    x1          .req R1
    MOV         x1, x0

    STRINGLOOPTAB$:
        ADD     x1, cwidth
        CMP     x, x1
        BGE     STRINGLOOPTAB

    MOV         x, x1
    .unreq      x1
    b           STRINGLOOP$

    STRINGLOOPEND$:
        .unreq  cwidth
        .unreq  cheight

    POP         {R4, R5, R6, R7, R8, R9, PC}
    .unreq      x
    .unreq      y
    .unreq      x0
    .unreq      string
    .unreq      length
