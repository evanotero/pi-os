/**
 * File:    framebuffer.s
 * Author:  Evan Otero
 *
 * Contains code that creates and manipulates the frame buffer.
 *
 * IMPORTANT NOTES:
 * - Framebuffer's width & height are the virtual w & h.
 * - GPU scales framebuffer to physical screen.
 * - Have to add 0x40000000 to address to tell GPU to
 *   not use its cache for these writes, ensuring the change can be seen.
 */

/*
    Format of message to the GPU
    struct FrameBuferDescription {
        u32 width; u32 height; u32 vWidth; u32 vHeight; u32 pitch; u32 bitDepth;
        u32 x; u32 y; void* pointer; u32 size;
    };
    FrameBuferDescription FrameBufferInfo =
        { 1024, 768, 1024, 768, 0, 16, 0, 0, 0, 0 };
*/
.section .data
.align 4        @ Ensures lowest 4 bits of the next line are 0
.globl FrameBufferInfo
FrameBufferInfo:
    .int 1024   @ #0 Physical Width
    .int 768    @ #4 Physical Height
    .int 1024   @ #8 Virtual Width
    .int 768    @ #12 Virtual height
    .int 0      @ #16 GPU - Pitch
    .int 16     @ #20 Bit Depth
    .int 0      @ #24 X offset
    .int 0      @ #28 Y offset
    .int 0      @ #32 GPU - Pointer
    .int 0      @ #36 GPU - Size

/*
    Returns pointer to FrameBuferDescription.
    Steps:
        1. Validate inputs.
        2. Write inputs into frame buffer.
        3. Send address of frame buffer + 0x40000000
        4. Receive the reply from mailbox
        5. If reply is not 0, method has failed.  Return 0 to indicate failure.
        6. Return a pointer to the frame buffer info.
    FrameBuferDescription* InitialiseFrameBuffer(u32 width, u32 height, u32 bitDepth);
 */
.section .text
.globl InitializeFrameBuffer
InitializeFrameBuffer:
    @ Validate inputs
    width       .req R0
    height      .req R1
    bitDepth    .req R2
    CMP         width, #4096
    CMPLS       height, #4096
    CMPLS       bitDepth, #32

    result      .req R0
    MOVHI       result, #0
    MOVHI       PC, LR

    @ Write into frame buffer
    PUSH        {R4, LR}
    fbInfoAddr  .req R4
    LDR         fbInfoAddr, =FrameBufferInfo
    STR         width, [fbInfoAddr, #0]
    STR         height, [fbInfoAddr, #4]
    STR         width, [fbInfoAddr, #8]
    STR         height, [fbInfoAddr, #12]
    STR         bitDepth, [fbInfoAddr, #20]
    .unreq      width
    .unreq      height
    .unreq      bitDepth

    @ Send to mailbox
    MOV         R0, fbInfoAddr
    ADD         R0, #0x40000000 @ Value input
    MOV         R1, #1          @ Channel input
    BL          MailboxWrite

    @ Receive reply
    MOV         R0, #1          @ Channel input
    BL          MailboxRead

    @ Check reply
    TEQ         result, #0
    MOVNE       result, #0
    POPNE       {R4, PC}

    @ Return
    MOV         result, fbInfoAddr
    POP         {R4, PC}
    .unreq      result
    .unreq      fbInfoAddr
