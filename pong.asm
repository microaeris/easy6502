; Variables allocated in the zero page
define p1Direction  $00 ; Last read input from player
define p2Direction  $01
define p1PaddleL    $02 ; screen location of P1's paddle, low byte
define p1PaddleH    $03 ; screen location of P1's paddle, high byte
define p2PaddleL    $04 ; screen location of P2's paddle, low byte
define p2PaddleH    $05 ; screen location of P2's paddle, high byte
define tmpL         $06 ; temporary address storage, low byte
define tmpH         $07 ; temporary address storage, high byte

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

; Colors
define black        $00
define white        $01

; Consts
define false        $00
define true         $01

define rowLen       $20
define paddleLen    $05

define minPosP1L    $21 ; Low byte of min bound of P1's position.
define minPosP1H    $02 ; High byte of min bound of P1's position.
define minPosP2L    $3E ; Low byte of min bound of P2's position.
define minPosP2H    $02 ; High byte of min bound of P2's position.

define maxPosP1L    $21 ; Low byte of max bound of P1's position.
define maxPosP1H    $05 ; High byte of max bound of P1's position.
define maxPosP2L    $3E ; Low byte of max bound of P2's position.
define maxPosP2H    $05 ; High byte of max bound of P2's position.

define 5RowOffset   $A0

  jsr resetHandler
  jsr init
  jsr loop


resetHandler:
  sei
  cld ;select binary mode
  ldx #$ff
  txs ;initialize stack pointer

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

; Returns if a move is needed.
; Stores 1 in A if a move is needed.
; Stores 0 in A if move is not needed.
updateP1:
  ldx p1Direction
  cpx #movingUp
  beq movingUpP1
  cpx #movingDown
  beq movingDownP1
  lda #false
  rts
movingUpP1:
  ; Bounds check
  ; if paddle position == min position, return
  lda p1PaddleL
  cmp #minPosP1L
  bne movingUpP1Do
  lda p1PaddleH
  cmp #minPosP1H
  bne movingUpP1Do
  lda #false
  rts
movingUpP1Do:
  sec ; set carry to indicate no borrow happened
  lda p1PaddleL
  sbc #rowLen
  sta p1PaddleL
  lda p1PaddleH
  sbc #$0
  sta p1PaddleH
  lda #true
  rts
movingDownP1:
  ; Bounds check
  ; if paddle position == max position, return
  lda p1PaddleL
  cmp #maxPosP1L
  bne movingDownP1Do
  lda p1PaddleH
  cmp #maxPosP1H
  bne movingDownP1Do
  lda #false
  rts
movingDownP1Do:
  clc ; clear carry to indicate no carry to start
  lda p1PaddleL
  adc #rowLen
  sta p1PaddleL
  lda p1PaddleH
  adc #$0
  sta p1PaddleH
  lda #true
  rts

updateP2:
  rts

; Draw Player
;
; Move the paddle by 1 pixel vertically.
; This subroutine erases 1 pixel in the opposite direction of the paddle's
; movement and draws one pixel in the direction of the paddle's movement.

nop
nop
nop
nop
nop
nop
nop
nop
nop
nop
nop
nop
nop
nop
nop
nop
nop
nop
nop
nop
nop
nop
nop
nop
nop

drawP1:
  ; Prep arguments for calling drawAbovePaddle or drawBelowPaddle
  lda p1PaddleH
  pha
  lda p1PaddleL
  pha
  ; Branch
  ldx p1Direction
  cpx #movingUp
  beq drawMovingUpP1
  cpx #movingDown
  beq drawMovingDownP1
  rts
drawMovingUpP1:
  lda #white
  pha
  jsr drawAbovePaddle
  lda #black
  pha
  jsr drawBelowPaddle
  rts
drawMovingDownP1:
  lda #black
  pha
  jsr drawAbovePaddle
  lda #white
  pha
  jsr drawBelowPaddle
  rts
;   ldy #0 ; y coordinate
;   lda #0 ; paddle color
;   ldx p1Direction
;   cpx #movingUp
;   beq drawUpP1
;   cpx #movingDown
;   beq drawDownP1
;   jmp drawP1Done
; drawUpP1:
;   lda #$8
;   jmp drawP1Done
; drawDownP1:
;   lda #$3
; drawP1Done:
;   sta (p1PaddleL), y
;   rts

drawP2:
  ldy #0 ; y coordinate
  lda #0 ; paddle color
  ldx p2Direction
  cpx #movingUp
  beq drawUpP2
  cpx #movingDown
  beq drawDownP2
  jmp drawP2Done
drawUpP2:
  lda #$8
  jmp drawP2Done
drawDownP2:
  lda #$3
drawP2Done:
  sta (p2PaddleL), y
  rts

; Draws one pixel above the current position of the paddle.
; Assumes this function will pull all arguments off the stack.
; Arguments
;     * color: color to be drawn (top of stack)
;     * paddlePosL: top coordinate of paddle, low byte
;     * paddlePosH: top coordinate of paddle, high byte
drawAbovePaddle:
  ; Calculate the screen position of the pixel above the paddle
  pla ; color
  tax ; color stored in x
  pla ; paddlePosL
  sec
  sbc #rowLen
  sta tmpL
  pla ; paddlePosH
  sbc #$0
  sta tmpH
  ; Draw pixel
  ldy #$0 ; clear y so it can be used in indirect offset addressing mode
  txa ; move color into accumulator
  sta (tmpL), y
  rts

drawBelowPaddle:
  ; Calculate the screen position of the pixel below the paddle
  pla ; color
  tax ; color stored in x
  pla ; paddlePosL
  clc
  adc #5RowOffset
  sta tmpL
  pla ; paddlePosH
  adc #$0
  sta tmpH
  ; Draw pixel
  ldy #$0 ; clear y so it can be used in indirect offset addressing mode
  txa ; move color into accumulator
  sta (tmpL), y
  rts

loop:
  jsr readInput ; Read in the last two key presses to catch near
  jsr readInput ; simultaneous key presses.
  jsr updateP1
  cmp #false
  beq p2Loop
  jsr drawP1
p2Loop:
  jsr updateP2
  cmp #false
  beq loop
  jsr drawP2
  jmp loop
