# Aeris' 6502 Style Guide

## Data Stack

The end of the zero page will be dedicated as a data stack. Starting from $00FF 
and growing towards $0000, temporary data can be pushed onto this stack. The max 
depth of the data stack should be kept to 32 bytes.

The data stack pointer (DSP) is located at $0000 and contains the byte address 
representing the top of the data stack, which is the next free address that can 
be written to. Before calling any subroutine, the DSP must be updated.

If calling a subroutine that uses the data stack, the DSP must be copied into a 
register (usually `X`) before jumping to the subroutine.

Reasoning: Even if the immediate subroutine doesn't use the data stack, an 
indirectly called subroutine may need to use it. If so, the indirect subroutine 
must know the next free address of the data stack.

### Example

```
    ; Init
    define DSP $00
    lda #$FF
    sta DSP

    ; Load DSP
    ldx DSP 

    ; Push value to data stack
    lda #$55
    sta $00,x
    dex

    ; Pull value from data stack
    inx
    ldy $00,x
```

Note: The Easy6502 emulator allocates $00FF and $00FE to system variables so the
data stack must start at $00FD.

## Calling Convention

### Subroutine Parameters 
When passing fewer than 3 bytes as parameters, use registers in the following 
precedence.
* `A`
* `X`
* `Y`

If the routine receives more than 3 bytes as parameters, use `X` as a pointer to
the data stack, which is located in the zero page. A subroutine cannot 
deallocate values the caller has placed on the stack. Upon return, any values a 
callee wrote to the data stack will be considered discarded unless the 
subroutine returns a higher (closer to $0000) DSP.

Reasoning: ZP instructions are executed in fewer cycles than instructions 
operating on the native stack. In addition, operations on the ZP have more 
flexibility due to having multiple specially dedicated addressing modes. 

### Return Values

If returning a bool, return the value via the carry bit. `SEC` to indicate true 
and `CLC` to indicate false.

Reasoning: Evaluating the returned value simply requires 2 cycles when calling 
either `BCS` or `BCC`. Returning a bool via a register would result in a compare
that also takes 2 cycles, but wastes 7 bits. 

If returning multiple bytes, prioritize passing values via registers in the 
following precedence.
* `A`
* `X`
* `Y`

If more than three bytes need to be returned, then `X` will store a pointer to
the data stack. If `X` was used as a DSP parameter, then the return value of `X`
must be higher (closer to $0000) than its input value.

## Reset Handler

Initialize the stack pointer to a known value (usually $FF in the case of the 
65(c)02) before any operation occurs that will use the stack. The first several 
lines of code in a reset handler would appear like so.

```
    sei             
    cld          ;select binary mode
    ldx #$ff
    txs          ;initialize stack pointer
```

Reasoning: `SP` is not initialized upon reset. (Nor are registers A, X and Y.)
