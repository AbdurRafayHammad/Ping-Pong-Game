[org 0x0100]
jmp start

; Variables
DotX:       dw 0A0h        ; xStarting-position
DotY:       dw 64h         ; yStarting-position
DotSize:    dw 04h         ; Ball size
DotSpeedX:  dw 05h         ; x speed
DotSpeedY:  dw 02h         ; y speed
Width:      dw 140h        ; Screen width (320 in mode 13h)
Height:     dw 0C8h        ; Screen height (200 in mode 13h)
padding:    dw 6           ; Padding around the edges
DotXCentre: dw 0A0h        ;Centre Postion X
DotYCentre: dw 64h         ;Centre Position Y
PeddleLeftX: dw 0Bh         ;Starting Postion X of Left Peddle
PeddleLeftY: dw 0Bh         ;Starting Postion Y of Left Peddle
PeddleLeftWidth:dw 05h      ;Width of Left Peddle
PeddleLeftHeight:dw 1Fh     ; Height of Left Peddle
PeddleRightX: dw 130h         ;Starting Postion X of Right Peddle
PeddleRightY: dw 0Bh         ;Starting Postion Y of Right Peddle
PeddleRightWidth:dw 05h      ;Width of  Right Peddle
PeddleRightHeight:dw 1Fh     ;Height of Right Peddle
PeddleVelocity:dw 05h        ; The velocity of peddle to move up or down

PLeftPoint:dw 00             ;Left Player Points
PRightPoint: dw 00           ;Right Player Points

ShowPlayerOne: dw '0','$'    ;Player one text showing
ShowPlayerTwo:dw '0','$'     ;Player two text showing
Player1WinsText db 'Player 1 Wins!$', 0
Player2WinsText db 'Player 2 Wins!$', 0
RestartPrompt db 'Press "Y" to Restart or "N" to Exit$', 0


; Clear the area where the ball was previously drawn
clearBall:
    mov cx, [DotX]         ; Start x-coordinate
    mov dx, [DotY]         ; Start y-coordinate

ClearHorizontal:
    mov ah, 0Ch            ; Write pixel function
    mov al, 0x00           ; Black color (background)
    int 0x10               ; Call BIOS interrupt to draw
    inc cx 
    mov ax, cx
    sub ax, [DotX]
    cmp ax, [DotSize]
    jng ClearHorizontal
    mov cx , [DotX]
    inc dx

    mov ax, dx
    sub ax, [DotY]
    cmp ax, [DotSize]
    jng ClearHorizontal

    ret

; Update the dot's position
moving:
    mov ax, [DotSpeedX]
    add [DotX], ax
    cmp word[DotX], 06h
    jl GivePointtoTwo        ;jumping to give point to player tw

    mov ax, word[Width]
    sub ax, word[DotSize]
    sub ax, [padding]
    cmp word[DotX], ax
    jg GivePointtoOne         ;jumpint to give point to player one
    jmp moveVertically



GivePointtoOne:               ;small loop for giving point to left plyaer
inc word[PLeftPoint]
    call RestartCentre
        call updateScoreOne
    cmp word[PLeftPoint],05h
    jge GameOver
 ret

 GivePointtoTwo:                ;small loop for giving point to left plyaer
inc byte[PRightPoint]
    call RestartCentre
         call updateScoreTwo
 cmp word[PRightPoint],05h
     jge GameOver

 ret
GameOver:
    ; Clear the screen
    mov ax, 0x03          ; Text mode (80x25)
    int 0x10              ; Switch to text mode

    ; Display winner message
    mov ah, 02h           ; Set cursor position
    mov bh, 00h           ; Page number
    mov dh, 10h           ; Row (center vertically)
    mov dl, 15h           ; Column (center horizontally)
    int 10h               ; Set cursor position

    mov ah, 09h           ; Display string
    cmp word[PLeftPoint], 05
    jne CheckPlayerTwoWin
    lea dx, [Player1WinsText]
    jmp DisplayMessage

CheckPlayerTwoWin:
    lea dx, [Player2WinsText]

DisplayMessage:
    int 21h               ; Display the winning message

    ; Ask for restart
    mov ah, 02h           ; Set cursor position
    mov dh, 12h           ; Row (below the winning message)
    mov dl, 0Fh           ; Column
    int 10h               ; Set cursor position

    lea dx, [RestartPrompt]
    int 21h               ; Display the restart prompt

WaitForInput:
    mov ah, 01h           ; Check for keypress
    int 16h
    jz WaitForInput       ; Wait until a key is pressed

    mov ah, 00h           ; Read key
    int 16h
    cmp al, 'y'           ; Check if 'y' or 'Y' is pressed
    je RestartGame
    cmp al, 'Y'
    je RestartGame
    jmp ExitToDOS         ; Exit the game if not 'y' or 'Y'

RestartGame:
    ; Reset the ball position and speed
    mov ax, [DotXCentre]
    mov [DotX], ax
    mov ax, [DotYCentre]
    mov [DotY], ax
    mov word[DotSpeedX], 05h
    mov word[DotSpeedY], 02h

    ; Reset paddle positions
    mov ax, 0Bh
    mov [PeddleLeftX], ax
    mov [PeddleLeftY], ax
    mov word[PeddleRightX], 130h
    mov word[PeddleRightY], 0Bh

    ; Reset scores
    mov word[PLeftPoint], 00h
    mov word[PRightPoint], 00h

    ; Update score display
    call updateScoreOne
    call updateScoreTwo

    ret
DisplayPlayer1Wins:
    ; Show "Player 1 Wins!"
    mov ah, 02h
    mov bh, 00h
    mov dh, 0Ah
    mov dl, 14h
    int 10h

    mov ah, 09h
    lea dx, [Player1WinsText]
    int 21h

    call RestartOrExit
    ret

DisplayPlayer2Wins:
    ; Show "Player 2 Wins!"
    mov ah, 02h
    mov bh, 00h
    mov dh, 0Ah
    mov dl, 14h
    int 10h

    mov ah, 09h
    lea dx, [Player2WinsText]
    int 21h

    call RestartOrExit
    ret

RestartOrExit:
    ; Show "Press 'Y' to Restart or 'N' to Exit"
    mov ah, 02h
    mov bh, 00h
    mov dh, 0Fh
    mov dl, 10h
    int 10h

    mov ah, 09h
    lea dx, [RestartPrompt]
    int 21h

    ; Wait for user input
    mov ah, 00h
    int 16h
    cmp al, 'Y'
    je RestartGame
    cmp al, 'y'
    je RestartGame
    cmp al, 'N'
    je ExitToDOS
    cmp al, 'n'
    je ExitToDOS

    jmp RestartOrExit

ExitToDOS:
    ; Exit to DOS
    mov ax, 4c00h
    int 21h

    ret

 
 moveVertically:
    mov ax, word[DotSpeedY]
    add word[DotY], ax
    cmp word[DotY], 2

    jl reverseSpeedY

    mov ax, word[Height]
    sub ax, word[DotSize]
    sub ax, [padding]
    cmp word[DotY], ax
    jg reverseSpeedY

    mov ax,[DotX]
    add ax,[DotSize]
    cmp ax,[PeddleRightX]
    jng checkwithLeft


    mov ax,[PeddleRightX]
    add ax,[PeddleRightWidth]
    cmp [DotX],ax
    jnl checkwithLeft


    mov ax,[DotY]
    add ax,[DotSize]
    cmp ax,[PeddleRightY]
    jng checkwithLeft


    mov ax,[PeddleRightY]
    add ax,[PeddleRightHeight]
    cmp [DotY],ax
    jnl checkwithLeft

    jmp  reverseSpeedX

checkwithLeft:
    mov ax,[DotX]
    add ax,[DotSize]
    cmp ax,[PeddleLeftX]
    jng ExitCollision

    mov ax,[PeddleLeftX] 
    add ax,[PeddleLeftWidth]
    cmp [DotX],ax
    jnl ExitCollision

    mov ax,[DotY]
    add ax,[DotSize]
    cmp ax,[PeddleLeftY]
    jng ExitCollision

    mov ax,[PeddleLeftY]
    add ax,[PeddleLeftHeight]
    cmp [DotY],ax
    jnl ExitCollision



   jmp  reverseSpeedX
reverseSpeedY:
    neg word [DotSpeedY]
    ret
reverseSpeedX:
    neg word [DotSpeedX]
    ret



    
    ExitCollision:
    ret
 

    ;Restrating from centre after colliding with left and right Wall
RestartCentre:
    mov ax,[DotXCentre]
    mov [DotX],ax

    mov ax,[DotYCentre]
    mov [DotY],ax
    neg word[DotSpeedX]
    neg word[DotSpeedY]
    ret

; Draw the ball at its current position
drawBall:
    mov cx, [DotX]         ; Start x-coordinate
    mov dx, [DotY]         ; Start y-coordinate

DotHorizontal:
    mov ah, 0Ch            ; Write pixel function
    mov al, 0x07           ; White color
    int 0x10               ; Call BIOS interrupt to draw
    inc cx 
    mov ax, cx
    sub ax, [DotX]
    cmp ax, [DotSize]
    jng DotHorizontal
    mov cx , [DotX]
    inc dx

    mov ax, dx
    sub ax, [DotY]
    cmp ax, [DotSize]
    jng DotHorizontal

    ret


ClearPeddl:
    mov cx, [PeddleLeftX]         ; Start x-coordinate
    mov dx, [PeddleLeftY]         ; Start y-coordinate

PeddlLeftHorizontal1:
    mov ah, 0Ch            ; Write pixel function
    mov al, 0x00           ; black color
    int 0x10               ; Call BIOS interrupt to draw
    inc cx 
    mov ax, cx
    sub ax, [PeddleLeftX]
    cmp ax, [PeddleLeftWidth]
    jng PeddlLeftHorizontal1
    mov cx , [PeddleLeftX]
    inc dx

    mov ax, dx
    sub ax, [PeddleLeftY]
    cmp ax, [PeddleLeftHeight]
    jng PeddlLeftHorizontal1


    mov cx, [PeddleRightX]         ; Start x-coordinate
    mov dx, [PeddleRightY]         ; Start y-coordinate

PeddlRightHorizontal1:
    mov ah, 0Ch            ; Write pixel function
    mov al, 0x00           ; White color
    int 0x10               ; Call BIOS interrupt to draw
    inc cx 
    mov ax, cx
    sub ax, [PeddleRightX]
    cmp ax, [PeddleRightWidth]
    jng PeddlRightHorizontal1
    mov cx , [PeddleRightX]
    inc dx

    mov ax, dx
    sub ax, [PeddleRightY]
    cmp ax, [PeddleRightHeight]
    jng PeddlRightHorizontal1
    ret


drawPeddl:
    mov cx, [PeddleLeftX]         ; Start x-coordinate
    mov dx, [PeddleLeftY]         ; Start y-coordinate

PeddlLeftHorizontal:
    mov ah, 0Ch            ; Write pixel function
    mov al, 0x05           ; White color
    int 0x10               ; Call BIOS interrupt to draw
    inc cx 
    mov ax, cx
    sub ax, [PeddleLeftX]
    cmp ax, [PeddleLeftWidth]
    jng PeddlLeftHorizontal
    mov cx , [PeddleLeftX]
    inc dx

    mov ax, dx
    sub ax, [PeddleLeftY]
    cmp ax, [PeddleLeftHeight]
    jng PeddlLeftHorizontal


    mov cx, [PeddleRightX]         ; Start x-coordinate
    mov dx, [PeddleRightY]         ; Start y-coordinate

PeddlRightHorizontal:
    mov ah, 0Ch            ; Write pixel function
    mov al, 0x03           ; White color
    int 0x10               ; Call BIOS interrupt to draw
    inc cx 
    mov ax, cx
    sub ax, [PeddleRightX]
    cmp ax, [PeddleRightWidth]
    jng PeddlRightHorizontal
    mov cx , [PeddleRightX]
    inc dx

    mov ax, dx
    sub ax, [PeddleRightY]
    cmp ax, [PeddleRightHeight]
    jng PeddlRightHorizontal
    ret


movPeddle:
;left Peddle movement
;check if key is being presseed(If not check the other peddle)
mov ah,01h
int 16h
jz RightPeddleMovement
                          ;check which key is being pressed(AL = ASCII character)
mov ah,00h
int 16h
                          ;if is 'w' or 'W' move up

cmp al,77h                ;for 'w'
jz moveLeftPeddleUp

cmp al,57h                ;for 'W'
jz moveLeftPeddleUp

                          ;if is 'arrow key upward' Or 'arrow key downward' move down

cmp al,73h                
jz moveLeftPeddleDown

cmp al,53h                
jz moveLeftPeddleDown
jmp RightPeddleMovement

moveLeftPeddleUp:
mov ax,[PeddleVelocity]
sub [PeddleLeftY],ax

mov ax,[padding]
cmp [PeddleLeftY],ax
jl fixLeftPeddleTop
jmp RightPeddleMovement


fixLeftPeddleTop:
mov ax,[padding]
mov [PeddleLeftY],ax
jmp RightPeddleMovement


moveLeftPeddleDown:
mov ax,[PeddleVelocity]
add [PeddleLeftY],ax
mov ax,[Height]
sub ax,[padding]
sub ax,[PeddleLeftHeight]
cmp [PeddleLeftY],ax
jg fixLeftPeddleBottom
jmp RightPeddleMovement


fixLeftPeddleBottom:
mov [PeddleLeftY],ax
jmp RightPeddleMovement


;Right Peddle movement

RightPeddleMovement:
    ; Check if a key is being pressed
    mov ah, 01h       ; Check for a keypress
    int 16h
    jz ExitPeddleMovement ; If no key pressed, exit

    mov ah, 00h       ; Get the scan code of the key
    int 16h

    ; Check for Up Arrow key
    cmp ah, 48h       ; Up Arrow scan code
    jz moveRightPeddleUp

    ; Check for Down Arrow key
    cmp ah, 50h       ; Down Arrow scan code
    jz moveRightPeddleDown

    ; Exit if no matching key
    jmp ExitPeddleMovement

moveRightPeddleUp:
    mov ax, [PeddleVelocity]
    sub [PeddleRightY], ax

    mov ax, [padding]
    cmp [PeddleRightY], ax
    jl fixRightPeddleTop
    jmp ExitPeddleMovement

fixRightPeddleTop:
    mov ax, [padding]
    mov [PeddleRightY], ax
    jmp ExitPeddleMovement

moveRightPeddleDown:
    mov ax, [PeddleVelocity]
    add [PeddleRightY], ax
    mov ax, [Height]
    sub ax, [padding]
    sub ax, [PeddleRightHeight]
    cmp [PeddleRightY], ax
    jg fixRightPeddleBottom
    jmp ExitPeddleMovement

fixRightPeddleBottom:
    mov [PeddleRightY], ax
    jmp ExitPeddleMovement

ExitPeddleMovement:
    ret


DrawScore:  ;Code for Drawing score on screen
;for Left Peddle Score
  mov ah,02h
  mov bh,00h
  mov dh,02h
  mov dl,04h
  int 10h
  
  mov ah,09h
  lea dx,[ShowPlayerOne]
int 21h

;for Right Peddle
mov ah,02h
  mov bh,00h
  mov dh,02h
  mov dl,1Fh
  int 10h
  
  mov ah,09h
  lea dx,[ShowPlayerTwo]
int 21h

ret

updateScoreOne:     ;Subroutine for updating player one
xor ax,ax
mov al,[PLeftPoint]

add al,30h
mov [ShowPlayerOne],al

ret


updateScoreTwo:      ;Subroutine for updating player one

xor ax,ax
mov al,[PRightPoint]

add al,30h
mov [ShowPlayerTwo],al

ret
; Display "PING PONG" at the start
ShowTitle:
    mov ah, 02h             ; Set cursor position
    mov bh, 00h             ; Page number
    mov dh, 0Ah             ; Row (vertical position, near the top-center)
    mov dl, 14h             ; Column (horizontal position, near center)
    int 10h                 ; Set the cursor position

    mov ah, 09h             ; Display string
    lea dx, [PingPongText]  ; Load the address of "PING PONG"
    int 21h                 ; Display the text

    ; Small delay for the title screen
    mov cx, 0FFFFh
TitleDelay:
    loop TitleDelay
    mov cx, 0FFFFh
    loop TitleDelay

    ret

; Display "Made by: Abrar Fazal" at the bottom
ShowCredits:
    mov ah, 02h             ; Set cursor position
    mov bh, 00h             ; Page number
    mov dh, 18h             ; Row (vertical position, bottom-center)
    mov dl, 04h             ; Column (horizontal position, near center)
    int 10h                 ; Set the cursor position

    mov ah, 09h             ; Display string
    lea dx, [MadeByText]    ; Load the address of "Made by: Abrar Fazal"
    int 21h                 ; Display the text

    ret

; Data for text
PingPongText db 'PING PONG', '$'
MadeByText db 'Made by: Abdur Rafay 23F0622 ', '$'
; Main program
start:
    ; Set graphics mode (Mode 13h - 320x200, 256 colors)
    mov ax, 0x0013
    int 0x10
   
   
main_loop:
    call clearBall           ; Clear the old ball
    call moving              ; Update position
    call drawBall            ; Draw the new ball
    call ClearPeddl
    call movPeddle
    call drawPeddl           ; Draw the both Peddles
    call DrawScore
    call ShowCredits         ; Display the credits at the bottom

 ; Small delay for smooth movement
 mov cx, 0FFFFh          ; Delay lsoop
delay_loop1:
loop delay_loop1
inner:
    loop inner

    mov cx,0xffbb
inner1:
    loop inner1
    jmp main_loop           ; Repeat the loop

; Exit to DOS
exit:
    mov ax, 0x4c00
    int 0x21