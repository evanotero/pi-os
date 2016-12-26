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
    .unreq      fbInfoAddr
