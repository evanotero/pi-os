/**
 * File:    systemTimer.s
 * Author:  Evan Otero
 *
 * Contains routines that interact with System Timer.
 */

/*
    Returns address of Timer.
    void* GetSystemTimerAddress()
 */
.globl GetSystemTimerAddress
GetSystemTimerAddress:
    LDR         R0, =0x20003000
    MOV         PC, LR

/*
    Returns current value in timer.
    u64 GetCurrentTime()
 */
.globl GetCurrentTime
GetCurrentTime:
    PUSH        {LR}

    BL          GetSystemTimerAddress

    LDRD        R0, R1, [R0, #4]
    POP         {PC}

/*
    Waits for a given amount of time.
    void GetTime(u32 waitTime)
 */
.globl Wait
Wait:
    delay       .req R2
    MOV         delay, R0

    PUSH        {LR}

    BL          GetCurrentTime
    start       .req R3
    MOV         start, R0

    elapsed .req R1
    current .req R0

    LOOP$:
        BL      GetCurrentTime
        SUB     elapsed, current, start
        CMP     elapsed, delay
        BLS     LOOP$

    .unreq      elapsed
    .unreq      current
    .unreq      delay
    .unreq      start
    POP         {PC}