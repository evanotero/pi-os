/**
 * File:    tag.s
 * Author:  Evan Otero
 *
 * Contains code to do with reading the ARM Linux boot tags.
 *
 * IMPORTANT NOTES:
 * - 
 */

/*
    Addresses of all tags detected, with 0 representing an
    undetected tag.
 */
.section .data
tag_core:
    .int        0

tag_mem:
    .int        0

tag_videotext:
    .int        0

tag_ramdisk:
    .int        0

tag_initrd2:
    .int        0

tag_serial:
    .int        0

tag_revision:
    .int        0

tag_videolfb:
    .int        0

tag_cmdline:
    .int        0

/*
    Finds teh address of all tags and returns the address
    of the tag who's number is given.
    void* FindTag(u16 tagNumber);
 */
.section .text
.globl FindTag
FindTag:
    tag         .req R0
    tagList     .req R1
    tagAddr     .req R2

    SUB         tag, #1
    CMP         tag, #8
    MOVHI       tag, #0
    MOVHI       PC, LR

    LDR         tagList, =tag_core

TAGRETURN$:
    ADD         tagAddr, tagList, tag, LSL #2
    LDR         tagAddr, [tagAddr]                  @ Load word

    TEQ         tagAddr, #0
    MOVNE       R0, tagAddr
    MOVNE       PC, LR

    LDR         tagAddr, [tagList]                  @ Read word
    TEQ         tagAddr, #0
    MOVNE       R0, #0
    MOVNE       PC, LR

    MOV         tagAddr, #0x100
    PUSH        {R4}
    tagIndex    .req R3
    oldAddr     .req R4

TAGLOOP$:
    LDRH        tagIndex, [tagAddr, #4]             @ Read half word
    SUBS        tagIndex, #1
    POPLT       {R4}
    BLT         TAGRETURN$

    ADD         tagIndex, tagList, tagIndex, LSL #2
    LDR         oldAddr, [tagIndex]                 @ Read word
    TEQ         oldAddr, #0
    .unreq      oldAddr
    STREQ       tagAddr, [tagIndex]                 @ Store word

    LDR         tagIndex, [tagAddr]                 @ Load word
    ADD         tagAddr, tagIndex, LSL #2
    B           TAGLOOP$

    .unreq      tag
    .unreq      tagList
    .unreq      tagAddr
    .unreq      tagIndex
