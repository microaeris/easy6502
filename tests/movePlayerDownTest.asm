define maxPosP1L    $21 ; Low byte of max bound of P1's position.
define maxPosP1H    $05 ; High byte of max bound of P1's position.

; Case 1
ldx #$00
ldy #$00

; Case 2
ldx #$21
ldy #$05

; Case 3
ldx #$22
ldy #$05


; Arguments
;  A: Lower byte of paddle's location
;  X; Higher byte of paddle's location
; Returns
;  A: Lower byte of paddle's new location
;  X; Higher byte of paddle's new location
; Description
;  If current location < min(maxP1, maxP2) then current location += 32
;  min(maxP1, maxP2 is $0521
movePlayerDown:
  sec
  txa
  sbc #maxPosP1L
  tya
  sbc #maxPosP1H
  bcs movePlayerDownEnd
  ; Move player location up by subtracting the current position by 32
  clc
  txa
  adc #$20
  tax
  tya
  adc #$00
  tay
movePlayerDownEnd:
  rts