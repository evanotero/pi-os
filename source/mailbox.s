/**
 * File:    mailbox.s
 * Author:  Evan Otero
 *
 * Contains code that interacts with the mailbox for communication with various devices.
 *
 * IMPORTANT NOTES:
 * - Mailbox Addresses
 *     Address  Size    Name    Desc                    Read/Write
 *     2000B880 4       Read    Receiving mail          R
 *     2000B890 4       Poll    Receive w/o retrieving  R
 *     2000B894 4       Sender  Sender info             R
 *     2000B898 4       Status  Info                    R
 *     2000B89C 4       Config  Settings                RW
 *     2000B8A0 4       Write   Sending mail            W
 * - TST computes AND and compares the result with 0.
 * - Mailbox 1 is used for negotiating the frame buffer.
 */

/*
    Returns address of Mailbox.
    void* GetMailboxBase()
 */
.globl GetMailboxBase
GetMailboxBase:
    LDR         R0, =0x2000B880
    MOV         PC, LR

/*
    Send message to particular mailbox.
    Steps:
        1. Validate inputs.
            a. Check if R1 is a real mailbox.
            b. Check low 4 bits of R0 are 0.
        2. Retrieve mailbox address.
        3. Read from Status field.
        4. Check the top bit is 0.  Else, go back to 3.
        5. Combine the value and the channel.
        6. Write to Write field.
    void MailboxWrite(u32 value, u8 channel)
 */
.globl MailboxWrite
MailboxWrite:
    @ Validate Inputs
    TST         R0, #0b1111
    MOVNE       PC, LR
    CMP         R1, #15
    MOVHI       PC, LR

    @ Retrieve mailbox address
    channel     .req R1
    value       .req R2
    MOV         value, R0
    PUSH        {LR}
    BL          GetMailboxBase
    mailbox     .req R0

    @ Read from Status
WAIT1$:
    status      .req R3
    LDR         status, [mailbox, #0x18]

    @ Check if top bit of Status is 0
    TST         status, #0x80000000 @ 0b10000000000000000000000000000000
    .unreq      status
    BNE         WAIT1$

    @ Combine channel and value
    ADD         value, channel
    .unreq      channel

    @ Store result in Write
    STR         value, [mailbox, #0x20]
    .unreq      value
    .unreq      mailbox

    POP         {PC}

/*
    Reads message from particular mailbox.
    Steps:
        1. Validate Inputs.
            a. Check if R0 is a real mailbox.
        2. Retrieve mailbox address.
        3. Read from Status field.
        4. Check if 30th bit is 0.  Else, go back to 3.
        5. Read from Read field.
        6. Check if mailbox is one we want.  Else, go back to 3.
        7. Return result.
    u32 MailboxRead(u8 channel)
 */
.globl MailboxRead
MailboxRead:
    @ Validate input
    CMP         R0, #15
    MOVHI       PC, LR

    @ Retrieve mailbox address
    channel     .req R1
    MOV         channel, R0
    PUSH        {LR}
    BL          GetMailboxBase
    mailbox     .req R0

    @ Read from status
RIGHTMAIL$:
    WAIT2$:
        status  .req R2
        LDR     status, [mailbox, #0x18]

        @ Check if 30th bit is 0
        TST     status, #0x40000000 @ 0b1000000000000000000000000000000
        .unreq  status
        BNE     WAIT2$

    @ Read next item from Read
    mail        .req R2
    LDR         mail, [mailbox, #0]

    @ Check if channel of mail we just read is the one that was supplied
    inchan      .req R3
    AND         inchan, mail, #0b1111
    TEQ         inchan, channel
    .unreq      inchan
    BNE         RIGHTMAIL$

    .unreq      mailbox
    .unreq      channel

    @ Return result
    AND         R0, mail, #0xFFFFFFF0   @ Move top 28 bits
    .unreq      mail

    POP {PC}
