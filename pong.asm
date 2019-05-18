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
define movingNone   $0
define movingUp     $1
define movingDown   $2

; Player 1 controls
define ASCII_q      $71 ; Up
define ASCII_a      $61 ; Down
define ASCII_z      $7A ; Stop

; Player 2 controls
define ASCII_p      $70 ; Up
define ASCII_l      $6C ; Down
define ASCII_carrot $2c ; Stop

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

define player1      $00
define player2      $01

define minPosP1L    $21 ; Low byte of min bound of P1's position.
define minPosP1H    $02 ; High byte of min bound of P1's position.
define minPosP2L    $3E ; Low byte of min bound of P2's position.
define minPosP2H    $02 ; High byte of min bound of P2's position.

define maxPosP1L    $21 ; Low byte of max bound of P1's position.
define maxPosP1H    $05 ; High byte of max bound of P1's position.
define maxPosP2L    $3E ; Low byte of max bound of P2's position.
define maxPosP2H    $05 ; High byte of max bound of P2's position.

define 5RowOffset   $A0

; Reset handler is the first code that is run.
; Can't call this function since this function clears the hardware stack.
resetHandler:
  sei          ; Disable interrupts
  ldx #$ff
  txs          ; Initialize stack pointer
  cld          ; Select binary mode
  lda #$00     ; Initialize registers to 0
  tax
  tay
  clc          ; Clear carry
  cli          ; Enable interrupts


main:
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
  cmp #ASCII_z
  beq p1StopKey
  cmp #ASCII_p
  beq p2UpKey
  cmp #ASCII_l
  beq p2DownKey
  cmp #ASCII_carrot
  beq p2StopKey
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
p1StopKey:
  lda #movingNone
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
p2StopKey:
  lda #movingNone
  sta p2Direction
  rts

; Arguments
;   X: Player number
erasePlayer:
  cpx #player1 ; If p1
  bne erasePlayerCheckPlayerElse
  ; Erase P1
  lda #black
  ldx #$00
  sta (p1PaddleL, x) ; ALICE FIXME - could speed this up by using a diff addressing mode.
  jmp erasePlayerCheckPlayerEnd
erasePlayerCheckPlayerElse:
  ; Erase P2
  lda #black
  ldx #$00
  sta (p2PaddleL, x)
erasePlayerCheckPlayerEnd:
  rts


; Arguments
;   X: Player number
; Description
;  Checks player number. Loads current paddle address into registers. Check
;  if the player input indicates the paddle should be moving up or down.
;  Call direction move function as appropriate.
updatePlayer:
  cpx #player1
  bne updatePlayerCheckPlayerElse
  ; Update P1
  ldx p1PaddleL ; Prepare parameters to move function
  ldy p1PaddleH ; Prepare parameters to move function
  lda p1Direction

  cmp #movingNone
  beq updatePlayerCheckPlayerEnd
  cmp #movingUp
  bne updatePlayerP1MovingDown
  jsr movePlayerUp
  jmp updatePlayerP1CheckMoveEnd
updatePlayerP1MovingDown:
  jsr movePlayerDown
updatePlayerP1CheckMoveEnd:
  ; Store results of movePlayerUp/Down to memory
  stx p1PaddleL
  sty p1PaddleH

  jmp updatePlayerCheckPlayerEnd
updatePlayerCheckPlayerElse:
  ; Update P2
  ldx p2PaddleL ; Prepare parameters to move function
  ldy p2PaddleH ; Prepare parameters to move function
  lda p2Direction

  cmp #movingNone
  beq updatePlayerCheckPlayerEnd
  cmp #movingUp
  bne updatePlayerP2MovingDown
  jsr movePlayerUp
  jmp updatePlayerP2CheckMoveEnd
updatePlayerP2MovingDown:
  jsr movePlayerDown
updatePlayerP2CheckMoveEnd:
  ; Store results of movePlayerUp/Down to memory
  stx p2PaddleL
  sty p2PaddleH

updatePlayerCheckPlayerEnd:
  rts


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
  ; If X.Y <=  minPosP2
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


; Arguments
;  X: Lower byte of paddle's location
;  Y; Higher byte of paddle's location
; Returns
;  X: Lower byte of paddle's new location
;  Y; Higher byte of paddle's new location
; Description
;  If current location < min(maxP1, maxP2) then current location += 32
;  min(maxP1, maxP2 is $0521
movePlayerDown:
  sec
  txa
  sbc #maxPosP1L
  tya
  sbc #maxPosP1H
  ; If X.Y >=  maxPosP1
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


; Arguments
;   X: Player number
drawPlayer:
  cpx #player1 ; If p1
  bne drawPlayerCheckPlayerElse
  ; ldx p1PaddleL ; Load the pointer to p1's paddle  -- this doesn't work because there's no addressing mode that takes the contents of x as the zero page index
  ; Draw P1
  lda #white
  ldx #$00
  sta (p1PaddleL, x) ; ALICE FIXME - could speed this up by using a diff addressing mode.
  jmp drawPlayerCheckPlayerEnd
drawPlayerCheckPlayerElse:
  ; ldx p2PaddleL ; Load the pointer to p2's paddle
  ; Draw P2
  lda #white
  ldx #$00
  sta (p2PaddleL, x)
drawPlayerCheckPlayerEnd:
  rts


loop:
  jsr readInput ; Read in the last two key presses to catch near
  jsr readInput ; simultaneous key presses.

  ; Update Player 1
  ldx #player1
  jsr erasePlayer
  ldx #player1
  jsr updatePlayer
  ldx #player1
  jsr drawPlayer

  ; Update Player 2
  ldx #player2
  jsr erasePlayer
  ldx #player2
  jsr updatePlayer
  ldx #player2
  jsr drawPlayer
  jmp loop
