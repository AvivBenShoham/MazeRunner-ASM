IDEAL
MODEL small
STACK 100h
DATASEG
 
SHOVAL_COLOR = 5
HEAD_COLOR = 8
BG_COLOR = 0
SUCCESS_COLOR = 79


; --------------------------
; Your variables here

xplace dw 14
yplace dw 175

color db 0fh
direction db 'd'     ; w a s d
level1Maze  db 'level1.bmp',0 
level2Maze db 'level2.bmp',0

LostMsg db "You lost ... Press any key to quit $"
CongratsMsg db "Congratulations! You won!! Press any key to exit $"

filehandle dw ? 
 
Header db 54 dup (0) 
 
Palette db 256*4 dup (0) 
 
ScrLine db 320 dup (0) 
 
ErrorMsg db 'Error', 13, 10,'$' 
 
ForceExit db 0
LostGame db 0
levelFinished db 0
level2time db 0

firstTimeCount db 0

firstSystemTime dw ?
secondSystemTime dw ?

thanksForPlaying db 'thank you for playing the Maze,',13,10
                 db 'made by Aviv Ben Shoham  $'



Instructions db ' ÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛ ',13,10
         db 'ÛÛ                                          ',13,10
         db 'Û                                            ',13,10
         db 'Û                                            ',13,10
         db 'Û       Hello, and welcome to The            ',13,10
         db 'Û       maze. The goal of the game is        ',13,10
		 db 'Û       touch the red color, every touch of  ',13,10
         db 'Û       the green background will disqualify ',13,10
         db 'Û       you.                                 ',13,10
         db 'Û       the keys are the arrows in keyboard  ',13,10
         db 'Û       you can quit the program with        ',13,10
         db 'Û       press on 0 key.                      ',13,10
		 db 'Û        You have 2 levels to complete!      ',13,10
         db 'Û        Good luck!                          ',13,10
		 db 'Û                                            ',13,10
         db 'Û        press P to start the game.          ',13,10
         db 'Û        press Q to quit.                    ',13,10
         db 'Û                                            ',13,10
         db 'Û                                            ',13,10
         db 'ÛÛ                                         ',13,10
         db ' ÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛ $'
		 
		 
		 
; --------------------------

CODESEG

start:
	mov ax, @data
	mov ds, ax
 
	mov ax, 2   ; Move to Text mode 
	int 10h
 
 
	mov dx, offset Instructions ;showing the instructions
	mov ah,9
	int 21h
 
	mov ah, 7
	int 21h
	
	cmp al, 71h
	jne continue
	
	mov ax, 2   
	int 10h
	
	mov dx, offset thanksForPlaying 
	mov ah,9
	int 21h
	
	mov cx,60     ; give the user time to see the screen before move
readingLoop:
	call _100MiliSecDelay
	loop readingLoop
	
	jmp exit
continue:

	cmp al, 70h
	jne start 
 
	mov ax, 13h   ; Move to graphic mode 
	int 10h

	mov dx, offset level1Maze 
    call  loadPic
	
	 

mov cx,30     ; give the user time to see the screen before move
waitLoop:
	call _100MiliSecDelay
	loop waitLoop



	
main:	
;	call timeCount
	
	call checkMovement
	cmp [ForceExit],1
	je start
	 
	call MoveOneStep
	
	cmp [LostGame],1
	je LostgameMsg
	
	cmp [level2time],1
	je level2
	
	cmp [levelFinished],1
	jne skipLevel2
	call LoadLevel2
	jmp level2
skipLevel2:


	call _100MiliSecDelay

	jmp main
level2:
		
		cmp [levelFinished],1
		je SuccessMsg

		call _100MiliSecDelay
		jmp main


		
LostgameMsg: ;printing lost game message
	
	mov dx, offset lostMsg
	mov ah,9
	int 21h

	
	mov ah,7
	int 21h
	jmp start

SuccessMsg: ;printing congrats after winining both levels
	mov dx,offset CongratsMsg
    mov ah,9
	int 21h
	
	mov ah,7
	int 21h
	jmp start
exit:
	mov ax, 2   ; Move to Text mode 
	int 10h
	
	mov ax, 4c00h
	int 21h
	
; --------------------------
; --------------------------
; --------------------------
; --------------------------
; --------------------------

proc LoadLevel2 ;changing picture to level2Maze
	push cx
	mov [xplace] , 15
	mov [yplace] , 45
	mov [direction], 'd'
	inc [level2time]
	mov dx, offset level2Maze 
    call  loadPic
	mov [levelFinished],0
    mov cx,40     ; give the user time to see the screen b4 move
@@waitLoop:
	call _100MiliSecDelay
	loop @@waitLoop
	pop cx
	ret
endp LoadLevel2

	


proc loadPic
	call OpenFile 
	 
	call ReadHeader 
	 
	call ReadPalette 
	 
	call CopyPal 
	 
	call CopyBitmap 

	ret
endp loadPic
	
	
proc OpenFile 
; Open file 
	mov ah, 3Dh 
	xor al, al 
	int 21h 
	 
	jc openerror 
	mov [filehandle], ax 
	jmp @@ret 
	 
openerror: 
	push ax
	push dx

	mov  dx, offset ErrorMsg 
	mov  ah, 9h 
	int  21h 

	pop dx
	pop ax

@@ret:	 
	ret 
endp OpenFile 
 
proc ReadHeader 
	; Read BMP file header, 54 bytes 
	;;push ax
	;;push bx
	;;push cx
	;;push dx
	 
	mov ah,3fh 
	mov bx, [filehandle] 
	mov cx,54 ;
	mov dx,offset Header 
	 
	int 21h 
	 
	;; pop dx
	;; pop cx
	;; pop bx
	;; pop ax
	ret 
 
endp ReadHeader 


 
proc ReadPalette 
	; Read BMP file color palette, 256 colors * 4 bytes (400h) 
	 
	;;push ax
	;;push cx
	;;push dx 

	mov ah,3fh 
	mov cx,400h 
	mov dx,offset Palette 
	 
	int 21h 

	;;pop dx
	;;pop cx
	;;pop ax
	ret 
 
endp ReadPalette 


 
proc CopyPal 
	; Copy the colors palette to the video memory 
	; The number of the first color should be sent to port 3C8h 
	; The palette is sent to port 3C9h 
	 
	;; push ax
	;; push cx
	;; push dx
	;; push si
	 
	 
	 
	mov si,offset Palette 
	mov cx,256 
	mov dx,3C8h 
	mov al,0 
	 
	; Copy starting color to port 3C8h 
	 
	out dx,al 
	; Copy palette itself to port 3C9h 
	 
	inc dx 
	 
	PalLoop: 
	; Note: Colors in a BMP file are saved as BGR values rather than RGB. 
	 
	mov al,[si+2] 
	; Get red value. 
	 
	shr al,1 
	 shr al,1 
	; Max. is 255, but video palette maximal 
	; value is 63. Therefore dividing by 4. 
	 
	out dx,al 
	; Send it. 
	 
	mov al,[si+1] 
	; Get green value. 
	 
	shr al,1 
	shr al,1 
	 
	out dx,al 
	; Send it. 
	 
	mov al,[si] 
	; Get blue value. 
	 
	shr al,1 
	shr al,1 
	 
	out dx,al 
	; Send it. 
	 
	add si,4 
	; Point to next color. 
	; (There is a null chr. after every color.) 
	 
	loop PalLoop 
	 
	;; pop si
	;; pop dx
	;; pop cx
	;; pop ax
	 
	ret 
 
endp CopyPal 
 
 
proc CopyBitmap 
; BMP graphics are saved upside-down. 
; Read the graphic line by line (200 lines in VGA format), 
; displaying the lines from bottom to top. 
 
;; push ax
;; push cx
;; push dx
;; push si
;; push es
	 
	 
	mov ax, 0A000h 
	mov es, ax 
	mov cx,200 
	 
	PrintBMPLoop: 
	 
	push cx 
	; di = cx*320, point to the correct screen line 
	mov di,cx 
	 
	shl cx,1 
	shl cx,1 
	shl cx,1 
	shl cx,1 
	shl cx,1 
	shl cx,1 
	 
	shl di,1
	shl di,1
	shl di,1
	shl di,1
	shl di,1
	shl di,1
	shl di,1
	shl di,1
	 
	add di,cx 
	; Read one line 
	 
	mov ah,3fh 
	mov cx,320 
	mov dx,offset ScrLine 
	 
	int 21h 
	; Copy one line into video memory 
	 
	cld ; Clear direction flag, for movsb 
	mov cx,320 
	mov si,offset ScrLine 
	 
rep movsb 
; Copy line to the screen 
;rep movsb is same as the following code: 
 
;mov es:di, ds:si 
 
;inc si 
;inc di 
;dec cx ... ;loop until cx=0 
 
pop cx 
 
loop PrintBMPLoop 
 
;;	pop es
;;	pop si
;;	pop dx
;;	pop cx
;;	pop ax
 
ret 

 
endp CopyBitmap 


;prints pixel
proc pixel
	push bx 
	push cx 
	push dx
	 
	mov bh,0h 
	mov cx, [xplace]
	mov dx, [yplace]
	 
	mov ah, 0ch
	int 10h 
	 
	pop dx
	pop cx
	pop bx
	ret
endp pixel
 
;the program stops the program for several miliseconds 
proc _100MiliSecDelay 
	push cx
	
	mov cx ,200
@@Self1:
	
	push cx
	mov cx,600 

@@Self2:	
	loop @@Self2
	
	pop cx
	loop @@Self1
	
	pop cx
	ret
endp _100MiliSecDelay


 
;the action moving the pixel for the next place (increase/decrease places of x&y
proc MoveOneStep 
	push ax
	 
 
	
	mov al, SHOVAL_COLOR
	call  Pixel
	
	cmp [direction],'w'
	jne @@NotUp
	dec [yplace]
	jmp @@cnt1
@@NotUp:
	cmp [direction],'a'
	jne @@NotLeft
	dec [xplace] 
	jmp @@cnt1
@@NotLeft:
	cmp [direction],'s'
	jne @@NotDown
	inc [yplace] 
	jmp @@cnt1
@@NotDown:
	cmp  [direction],'d'
	jne @@NotRight
	inc [xplace]
	jmp @@cnt1
@@NotRight:
	jmp @@ret
	
@@cnt1:
	call CheckWhatNextCell
	cmp ax,1
	jne CheckSuccess
	
	mov al, HEAD_COLOR
	call  Pixel
	jmp @@ret
	
	
CheckSuccess:

	cmp ax,2  ; win 
	jne @@lost
	mov [levelFinished],1
	jmp @@ret

@@lost:	
	mov [LostGame],1
	jmp @@ret
	
@@ret:
	pop ax
	ret
endp MoveOneStep

;checking next pixel color
; return ax =1 when Empty,  2=success lvl 1, else 0 
proc CheckWhatNextCell
	push cx
	
	mov cx, [xplace]
	mov dx, [yplace]
	mov ah,0dh        ; checks what is the color of the point cx dx
	int 10h
	
	cmp al,BG_COLOR
	jnz @@NotEmpty
	mov ax,1
	jmp @@END_PROC
@@NotEmpty:
stop:
	cmp al, SUCCESS_COLOR
	jnz @@notSuccess
	mov ax,2
	jmp @@END_PROC
@@notSuccess:	
	mov ax,0

@@END_PROC:
	pop cx
	ret
endp CheckWhatNextCell




 
;get input,compering him and changes the direction
proc  checkMovement  
	mov ah,01h
	int 16h
	jz @@theEnd
	
	mov ah,00h
	int 16h
	
	cmp al,'w'
	jne @@NotUp
	mov [direction], 'w'
@@NotUp:
	cmp al,'a'
	jne @@NotLeft
	mov [direction], 'a'
@@NotLeft:
	cmp al,'s'
	jne @@NotDown
	mov [direction], 's'
@@NotDown:
	cmp al,'d'
	jne @@NotRight
	mov [direction], 'd'
@@NotRight:
	cmp al,'0'
	jne @@NotExit
	mov [ForceExit], 1
@@NotExit:
	cmp al,0
	jne @@NotArrows
	call ReplaceKey ;checking arrows input
@@NotArrows:

@@theEnd:
	
	ret
endp checkMovement



; in case of Arrows pressed put scan code in [direction]
proc ReplaceKey
     cmp ah,48h ; up arrow (Hex)
	 jnz @@NoUp
	 mov [direction], 'w'
	 jmp @@ret
@@NoUp:
     cmp ah,4dh ;right arrow (Hex)
	 jnz @@NoRight 
	 mov [direction], 'd'
	 jmp @@ret
@@NoRight:
     cmp ah,4bh ;left arrow (Hex)
	 jnz @@NoLeft
	 mov [direction], 'a'
	 jmp @@ret
@@NoLeft:
     cmp ah,50h  ; down arrow (Hex)
	 jnz @@ret
	 mov [direction], 's'
	 jmp @@ret
@@ret:
	ret
endp ReplaceKey


;proc timeCount
;push cx
;push dx
;push ax

;	mov ah ,2Ch
;	int 21h

;	mov ax ,0
;	mov ah,cl
;	mov al,dh

;	cmp [firstTimeCount],0
;	jne @@continue
	
;	mov [firstSystemTime],ax
;	inc [firstTimeCount]
;	jmp @@end
	
;@@continue:

	;mov [secondSystemTime],ax
	
	;mul ah 60
	;add al ,ah

;@@end:
;pop ax
;pop dx
;pop cx

;ret 
;endp timeCount
   
   
 
END start