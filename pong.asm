; Variables allocated in the zero page
define p1Direction  $00 ; Last read input from player
define p2Direction  $01
define p1PaddleL    $02 ; screen location of P1's paddle, low byte
define p1PaddleH    $03 ; screen location of P1's paddle, high byte
define p2PaddleL    $04 ; screen location of P2's paddle, low byte
define p2PaddleH    $05 ; screen location of P2's paddle, high byte

; Directions (each using a separate bit)
define movingUp     $1
define movingDown   $2

; Player 1 controls
define ASCII_q      $71
define ASCII_a      $61

; Player 2 controls
define ASCII_p      $70
define ASCII_l      $6C

; System variables
define sysRandom    $fe
define sysLastKey   $ff

; Consts
define rowLen       $20

define minPosP1L    $21 ; Low byte of min bound of P1's position.
define minPosP1H    $02 ; High byte of min bound of P1's position.
define minPosP2L    $3E ; Low byte of min bound of P2's position.
define minPosP2H    #02 ; High byte of min bound of P2's position.

define maxPosP1L    $C1 ; Low byte of max bound of P1's position.
define maxPosP1H    $05 ; High byte of max bound of P1's position.
define maxPosP2L    $DE ; Low byte of max bound of P2's position.
define maxPosP2H    #05 ; High byte of max bound of P2's position.


  jsr init
  jsr loop

init:
  lda #minPosP1H
  sta p1PaddleH
  lda #minPosP2H
  sta p2PaddleH
  lda #minPosP1L
  sta p1PaddleL
  lda #minPosP2L
  sta p2PaddleL
  rts

readInput:
  lda sysLastKey
  ldx sysLastKey
  cmp #ASCII_q
  beq p1UpKey
  cmp #ASCII_a
  beq p1DownKey
  cmp #ASCII_p
  beq p2UpKey
  cmp #ASCII_l
  beq p2DownKey
  ; No key presses or not a valid key
  ; Stop moving both paddles
  ; Removed because I don't think it felt good to let the opposite player to
  ; affect your movement.
  ; lda #$0
  ; sta p1Direction
  ; sta p2Direction
  rts
p1UpKey:
  lda #movingUp
  sta p1Direction
  rts
p1DownKey:
  lda #movingDown
  sta p1Direction
  rts
p2UpKey:
  lda #movingUp
  sta p2Direction
  rts
p2DownKey:
  lda #movingDown
  sta p2Direction
  rts

updateP1:
  ldx p1Direction
  cpx #movingUp
  beq movingUpP1
  cpx #movingDown
  beq movingDownP1
  rts
movingUpP1:
  rts
movingDownP1:
  clc
  lda p1PaddleL
  adc #rowLen
  sta p1PaddleL
  adc #$0
  sta p1PaddleH
  rts

updateP2:
  nop
  rts

drawP1:
  ldy #0 ; y coordinate
  lda #0 ; paddle color
  ldx p1Direction
  cpx #movingUp
  beq movingUpP1
  cpx #movingDown
  beq movingDownP1
  jmp drawP1Done
movingUpP1:
  lda #$8
  jmp drawP1Done
movingDownP1:
  lda #$3
drawP1Done:
  sta (p1PaddleL), y
  rts

drawP2:
  ldy #0 ; y coordinate
  lda #0 ; paddle color
  ldx p2Direction
  cpx #movingUp
  beq upColorP2
  cpx #movingDown
  beq downColorP2
  jmp drawP2Done
movingUpP2:
  lda #$8
  jmp drawP2Done
movingDownP2:
  lda #$3
drawP2Done:
  sta (p2PaddleL), y
  rts

loop:
  jsr readInput ; Read in the last two key presses to catch near
  jsr readInput ; simultaneous key presses.
  jsr updateP1
  jsr updateP2
  jsr drawP1
  jsr drawP2
  jmp loop
