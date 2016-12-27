/**
 * File:    gpio.s
 * Author:  Evan Otero
 *
 * Contains routines for manipulation of the GPIO ports.
 *
 * IMPORTANT NOTES:
 * - Address based off BCM2835.
 */

/*
    Returns address of GPIO controller.
    void* GetGpioBase();
 */
.globl GetGpioBase
GetGpioBase:
    LDR         R0, =0x20200000
    MOV         PC, LR

/*
    Sets function of pin to specified value.
    void SetGpioFunction(u32 gpioRegister, u32 function);
 */
.globl SetGpioFunction
SetGpioFunction:
    pinNum      .req R0
    pinFunc     .req R1

    CMP         pinNum, #53             @ Pin number must be between 0 & 53
    CMPLS       pinFunc, #7             @ Each pin has function numbers from 0 - 7
    MOVHI       PC, LR                  @ Return if pinNum > 53 or pinFunc > 7

    PUSH        {LR}
    MOV         R2, pinNum              @ Move pin number, so it will not be overwritten
    .unreq      pinNum
    pinNum      .req R2

    BL          GetGpioBase
    gpioAddr    .req R0

FUNCTIONLOOP$:                          @ gpioAddr = GPIO Address + 4 * (Pin # / 10)
    CMP         pinNum, #9              @ pinNum contains remainder of (pin #) / 10
    SUBHI       pinNum, #10
    ADDHI       gpioAddr, #4
    BHI         FUNCTIONLOOP$

    ADD         pinNum, pinNum, LSL #1  @ pinNum * 3 = pinNum * 2 + pinNum
    LSL         pinFunc, pinNum

    @ START of fix to preserve values of all pin's functions in the block of 10 
    mask        .req R3
    MOV         mask, #7                @ mask = 111
    LSL         mask, pinNum            @ Move 111 to same position as function
    .unreq      pinNum

    MVN         mask, mask              @ Invert bits
    oldFunc     .req R2
    LDR         oldFunc, [gpioAddr]
    AND         oldFunc, mask
    .unreq      mask

    ORR         pinFunc, oldFunc        @ Correct bits are now set
    .unreq      oldFunc
    @ END of fix

    STR         pinFunc, [gpioAddr]     @ gpioAddr = computed function value at address
    .unreq      pinFunc
    .unreq      gpioAddr
    POP         {PC}

/*
    Turns gpio pin on or off.
    void SetGpio(u32 gpioRegister, u32 value);
 */
.globl SetGpio
SetGpio:
    pinNum      .req R0
    pinVal      .req R1

    CMP         pinNum, #53
    MOVHI       PC, LR

    PUSH        {LR}
    MOV         R2, pinNum
    .unreq      pinNum
    pinNum      .req R2

    BL          GetGpioBase
    gpioAddr    .req R0

    pinBank     .req R3
    LSR         pinBank, pinNum, #5     @ pinNum / 32
    LSL         pinBank, #2             @ pinBank * 4
    ADD         gpioAddr, pinBank
    .unreq      pinBank

    AND         pinNum, #31             @ pinNum = remainder of pinNum / 32
    setBit      .req R3
    MOV         setBit, #1
    LSL         setBit, pinNum
    .unreq      pinNum

    TEQ         pinVal, #0              @ 0 -> LED on
    .unreq      pinVal
    STREQ       setBit, [gpioAddr, #40] @ turn on
    STRNE       setBit, [gpioAddr, #28] @ turn off
    .unreq      setBit
    .unreq      gpioAddr

    POP         {PC}
