# Aeris' 6502 Style Guide

## Calling convention

Parameters passed as 

## Reset Handler

Good programming practice is to initialize the stack pointer to a known value (usually $FF in the case of the 65(c)02) before any operation occurs that will use the stack. The first several lines of code in a reset handler would appears like so:

```
    sei             
    cld          ;select binary mode
    ldx #$ff
    txs          ;initialize stack pointer
```

[Source](http://forum.6502.org/viewtopic.php?f=4&t=2258)

