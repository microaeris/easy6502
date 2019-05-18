define minPosP2L    $3E ; Low byte of min bound of P2's position.
define minPosP2H    $02 ; High byte of min bound of P2's position.

ldx #$00  ; CASE 1
ldy #$00

ldx #$AA  ; CASE 2
ldy #$AA

ldx #$3E  ; CASE 3
ldy #$02

; Arguments
;  X: Lower byte of paddle's location
;  Y; Higher byte of paddle's location
; Returns
;  X: Lower byte of paddle's new location
;  Y; Higher byte of paddle's new location
; Description
;  If current location > max(minP1, minP2) then current location -= 32
;  max(minP1, minP2) is $023E
movePlayerUp:
  sec
  txa
  sbc #minPosP2L
  tya
  sbc #minPosP2H
  bcc movePlayerUpEnd
  beq movePlayerUpEnd
  ; Move player location up by subtracting the current position by 32
  sec
  txa
  sbc #$20
  tax
  tya
  sbc #$00
  tay
movePlayerUpEnd:
  rts