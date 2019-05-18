# Aeris' 6502 Style Guide

This style guide aims to provide guidelines for consistency and best practices
within a 6502 program. 

The two stack scheme described below is borrowed from cc65's treatment of 
parameters and return values.

## Data Stack

The data stack will be a software stack that is located in RAM from $0200-$0220 
(32 bytes max depth). Starting from $0200 and growing downwards towards larger 
addresses, this stack should be used to store parameters and return values.

Rationale: The data stack is a separate block of memory from the hardware stack 
for programming simplicity. The other option would be to play games with 
intermixing return addresses and subroutine parameters on the same stack, which 
quickly becomes messy.

The data stack pointer (DSP) is a zero page (ZP) variable that contains the 
address that points to the top of the data stack, which is the next free address 
that can be written to. DSP is two bytes long and is located at $0000-$0001.

One can access values on the data stack with indirect Y addressing mode.

Rationale: The data stack is not located in the zero page since the ZP should be
saved for variables and operations that can take advantage of direct zero page 
addressing. `lda` using indirect Y addressing costs one additional cycle when 
compared to using a software stack on the ZP and accessing with absolute X 
addressing (or ZP,X). Parameter access is not a frequent enough use case to 
justify the space that would be required to store it in the ZP.

### Example

```
    define DSP $00

    ; Init - Load $0200 into the DSP
    lda #$00
    sta DSP
    lda #$02
    sta $01 
 
    ; Push value to data stack
    lda #$55 ; Data 
    ldy #$00
    sta (DSP),y
    inc DSP

    ; Pull value from data stack
    ldy #$00
    dec DSP
    lda (DSP),y
```

## Return Stack

The 'return stack' is actually the 6502 hardware stack. It is called 'return 
stack', because it contains mostly return address of subroutines. It can be (and
is) used also as temporary data storage (for example saving a register). It is 
not used for parameters and variables.

(As taken from [cc65](https://github.com/cc65/wiki/wiki/Parameter-and-return-stacks#the-return-stack).)

## Calling Convention

### Subroutine Parameters 
When passing fewer than 3 bytes as parameters, use registers in the following 
precedence.
* `X`
* `Y`
* `A`

If the routine receives more than 3 bytes as parameters, use the data stack
as described above. A subroutine is required to pull off all parameters from the 
stack before returning.

Rationale: To explicitly delineate responsibility of caller vs. callee. `A` is 
to be used last since it will more likely be needed in the called subroutine's 
process.

### Return Values

If returning a bool, return the value via the carry bit. `SEC` to indicate true 
and `CLC` to indicate false.

Rationale: Evaluating the returned value simply requires 2 cycles when calling 
either `BCS` or `BCC`. Returning a bool via a register would require a compare
and then branch. 

If returning multiple bytes, prioritize passing values via registers in the 
following precedence.
* `X`
* `Y`
* `A`

If more than three bytes need to be returned, then the data stack can be used as 
described above.

## Reset Handler

Initialize the stack pointer to a known value (usually $FF in the case of the 
65(c)02) before any operation occurs that will use the stack. The first several 
lines of code in a reset handler would appear like so.

```
    sei          ; Disable interrupts
    ldx #$ff
    txs          ; Initialize stack pointer
    cld          ; Select binary mode
    lda #$00     ; Initialize registers to 0
    tax    
    tay
    clc          ; Clear carry
    cli          ; Enable interrupts
```

Rationale: `SP` is not initialized upon reset. (Nor are registers `A`, `X`, `Y`,
and `D` status flag.)

## Branch Conditions

When writing branching conditions, branch on the less expected result (i.e. the 
edge case). The exception to this rule is branching in loops where one must 
repeatedly branch on the expected condition until the loop terminates.

Rationale: A branch test that fails takes one less cycle to execute than one a
branch test that succeeds. 

### Examples

```
    adc $24
    bcs TOOBIG

    sbc $24
    bcc TOOSML

LOOP
    ...
    dex
    bne LOOP
```

## Incrementing and Decrementing Index Registers

To increment or decrement the X or Y registers by 5 or more, do the arithmetic 
to the accumulator. For increments and decrements less than 5, do it with the 
increment and decrement instructions. 

Rationale: 

```
    ; Increment with INX
    ; Total: 5 bytes, 10 cycles

    inx
    inx
    inx
    inx
    inx

    ; Increment with accumulator
    ; Total: 5 bytes, 8 cycles

    txa
    clc
    adc #$05
    tax
```

cf. Page 70 in 6502 Software Design.

## Saving All Registers on Hardware Stack

Must be done in the following order.

```
    ; Saving register values
    php 
    pha 
    txa
    pha 
    tya
    pha


    ; Restoring register values
    pla
    tay
    pla 
    tax
    pla
    plp
```




