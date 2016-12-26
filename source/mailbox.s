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
