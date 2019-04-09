## Branching

Fill the screen with random colors

```
LDA #$02
STA $01
loop:
  LDA $FE
  STA ($00), y
  INY
  CPY #$FF
  BNE loop
  INC $01
  LDY #$00
  LDA $01
  CMP #$06
  BNE loop
BRK
```

Draw orange or blue pixel depending on if the RNG is even or odd.

```
LDA #$20
STA $01 ; Address at $00 is our current address of the screen
top:
    LDA $FE
    AND #$01
    BEQ even ; Z = 1, LSB of A was 0. A was even.
    LDA #$E ; light blue
    CLV ; clear overflow flag
    BVC write; branch if overflow clear
even:
    LDA #$8 ; orange
write:
    ; Common path
    STA ($00), y
    INY
    CPY #$FF
    BNE foo
    INC $01
foo:
    LDA $01
    CMP #$06 ; if we've reached the last address
    BNE top
BRK
```