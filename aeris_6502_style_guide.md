# Aeris' 6502 Style Guide

## Data Stack

The end of the zero page will be dedicated as a data stack. Starting from $00FF, 
temporary data can be pushed onto this stack. A register must contain the data 
stack point (`DSP`) to point to the top of the data stack. The max depth of the 
data stack should be kept to 32 bytes.

```
    ; Load DSP
    ldx #$FF 

    ; Push value to data stack
    sta $00,x
    dex

    ; Pull value from data stack
    lda $00,x
    inx
```

Note: The Easy6502 emulator allocates $00FF and $00FE to system variables so the
data stack must start at $00FD.

## Calling convention

### Subroutine parameters 
When passing fewer than 3 bytes as parameters, use registers in the following 
precedence.
* `A`
* `X`
* `Y`

If the routine receives more than 3 bytes as parameters, use `X` as a pointer to
the data stack located in the zero page. A subroutine cannot deallocate values
the caller has placed on the stack. Upon return, any values a callee wrote to 
the data stack will be considered discarded unless the subroutine returns a 
higher (closer to $0000) DSP.

Reasoning: ZP instructions are executed in fewer cycles and have more 
flexibility due to having specially dedicated addressing modes. 

### Return values

If returning a bool, return the value via the carry bit. `SEC` to indicate true 
and `CLC` to indicate false.

Reasoning: Evaluating the returned value simply requires 2 cycles when calling 
either `BCS` or `BCC`. Returning a bool via any other means would require a load 
and compare. 

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
