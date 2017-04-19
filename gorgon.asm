;*****************************************************************************
; Gorgon - A Defender-like game based on the 1981 Apple ][ game Gorgon
;
; Copyright 2017 Mats Engstrom, SmallRoomLabs. Licensed under the MIT license
;*****************************************************************************

;
; Define standard ROM routines
;
CLRSCR	EQU 3503 	; $0D6B
OPENCHN	EQU $1601 	; 5633
print	EQU $203C
SCREEN	EQU $4000
ATTRIBS EQU $5800	; 5800..5B00=$400 locs. FL BL P2 P1 P0 I2 I1 I0
SLOWRAM	EQU $5DC0 	; 24000 First usable location in slow ram
FASTRAM	EQU $8000 	; 32768 Start of the faster upper 32K ram

PORTBORDER EQU $FE	; OUT port for seting border color

;
; Color names
;
BLACK	EQU 0		; BK
BLUE	EQU 1		; BL
RED	EQU 2		; RE
MAGENTA	EQU 3		; MA
GREEN	EQU 4		; GR
CYAN	EQU 5		; CY
YELLOW	EQU 6		; YL
WHITE	EQU 7		; WH

	include "colors.inc"	; INK/PAPER color combos

;
; Game constants and settings
;
;OPTSPEED	EQU	1	; Defined=Optimize for Speed
;SINGLESTEP	EQU	1	; Defined=J/K only moves single pixel
;DEBUG		EQU	1	; Defined=Print debug values at top
CPUBORDER	EQU 	1	; 0=Disable, 1=Enable

XFRICTION	EQU	1	; Horizontal air-drag
YFRICTION	EQU	1	; Vertical air-drag

SHIPWORLDTOP	EQU	56	; Screen line to offset to when shipY=0
MAXSHIPYSPEED 	EQU	24
MAXSHIPXSPEED 	EQU	31

EDGEDISTANCE	EQU	60
RESIDUALSPEED	EQU 	12	; ShipXspeed when changed direction

WORLDWIDTH	EQU	1024

LASTLINE	EQU 	191
GROUNDHEIGHT 	EQU	16
SCOREHEIGHT	EQU 	9
GROUNDSTART	EQU 	LASTLINE-SCOREHEIGHT-GROUNDHEIGHT

	include "macros.asm"

	ORG SLOWRAM
	ALIGN 256
	include "fatfont.asm"
	include "ytable.asm"
	include "score.asm"
	include "ground.asm"
	include "ship.asm"
	include "key.asm"
	include "interrupt.asm"

Footer:
	DB 22,1,0,'SCORE: ..... HI:..... FUEL:.... '
Footer_: EQU $

holdL		DB 0
holdH		DB 0
holdSP		DW 0
fire		DB 0

cameraX		DW 0


Start:
	call	CLRSCR 		; clear the screen.
	ld	A,BLACK
	out	(PORTBORDER),A

	ld	A,253
	call	OPENCHN

	ld	DE,Footer 	; address of string
	ld	BC,Footer_ - Footer ; length of string to print
	call	8252 		; print our string

	call	SetupIM2
	call	ResetScores

	call	DrawTopBoxes
	call	DrawGroundMap
	call	DrawRemainingShips

	ld	A,WhBK		; Fill the screen attributes
 REPT $400,V
;	ld	A, (YELLOW*8)+BLUE+(((V & 32) XOR ((V & 1) * 32)) * 2)
	ld	(ATTRIBS+V),A
 ENDM

	ld	HL,(shipX)
	ld	(cameraX),HL

	call 	DrawShipAtMap	; Pre-draw this outside of the loop so the
				; first time inside the loop will erase the
				; marker

Loop:
	call	DrawGround
	ld	A,YELLOW
	out	(PORTBORDER),A
	call	DrawShip
	ld	A,RED
	out	(PORTBORDER),A
	call 	ReadKeys
	call	ScoreDisplayer		; Display 1 digit of the score digits
	call 	DrawShipAtMap		; Erase the ship at the map
	call	UpdateShipY		; Update ship positions
	call	UpdateShipX
	call 	DrawShipAtMap		; Redraw the ship at the map
	ld	A,GREEN
	out	(PORTBORDER),A

	;
	; If ship is moving to the right then the camera should not move
	; until ship-camera>100. When this is true then camera=ship-100
	;
	; If ship is moving to the left then the camera should not move
	; until camera-ship>100. When this is true then camera=ship+100
	;
	ld 	A,(shipXdir)
	cp	SHIPRIGHT
	jp	Z,ShipIsGoingRight

ShipIsGoingLeft
	ld	HL,(cameraX)
	ld	BC,(shipX)
	CLC
	sbc	HL,BC
	ld	A,H			; Wrap at 1024
	and	3			;  ...
	jp	NZ,FollowDone		; Negative or >256 distance, we're done
	ld	H,A			;  ...
	ld	A,L
	cp	EDGEDISTANCE
	jp	C,FollowDone
	ld	HL,(shipX)
	ld	BC,EDGEDISTANCE
	add	HL,BC
	ld	A,H			; Wrap at 1024
	and	3			;  ...
	ld	H,A			;  ...
	ld	(cameraX),HL
	jp	FollowDone

ShipIsGoingRight:
	ld	HL,(shipX)
	ld	BC,(cameraX)
	CLC
	sbc	HL,BC
	ld	A,H			; Wrap at 1024
	and	3			;  ...
	jp	NZ,FollowDone		; Negative or >256 distance, we're done
	ld	H,A			;  ...
	ld	A,L
	cp	EDGEDISTANCE+24
	jp	C,FollowDone
	ld	HL,(shipX)
	ld	BC,EDGEDISTANCE+24
	CLC
	sbc	HL,BC
	ld	A,H			; Wrap at 1024
	and	3			;  ...
	ld	H,A			;  ...
	ld	(cameraX),HL
	jp	FollowDone

FollowDone:

IFDEF DEBUG
	ld HL,(cameraX)
	ld DE,Row0+0
	call PrintHLAtDE
	ld HL,(shipX)
	ld DE,Row0+7
	call PrintHLAtDE
ENDIF

 IF CPUBORDER=0
 	halt
 ELSE
	ld	A,BLACK
	out	(PORTBORDER),A
	halt
	ld	A,BLUE
	out	(PORTBORDER),A
 ENDIF
	jp	Loop

AbsA:
 	bit	7,A
	ret 	Z
	neg
	ret

;
; Displays a number 0..9 from A as location starting at HL
;
DispNum:
	add	A,A 		; Multiply A by 8
	add	A,A
	add	A,A
	ld	DE,FATFONT+$10*8 ; Address of digit 0 in charmap
	add	A,E		; Add A*8 to the address to get to the
	ld	E,A 		; correct offset of the requred digit

	ld	B,8
dn0	ld	A,(DE)		; Copy all 8 rows of the character map
	inc	DE		; into to the screen memory
	ld	(HL),A
	inc	H
	djnz	dn0
	ret



;
;
;
DrawRemainingShips:
	ld	BC,shipR4
	ld	HL,Row2+27
	DRAW1SHIPLINE
	ld	HL,Row3+27
	DRAW1SHIPLINE
	ld	HL,Row4+27
	DRAW1SHIPLINE
	ld	HL,Row5+27
	DRAW1SHIPLINE
	ld	HL,Row6+27
	DRAW1SHIPLINE
	ld	HL,Row7+27
	DRAW1SHIPLINE

	ld	BC,shipR4
	ld	HL,Row10+27
	DRAW1SHIPLINE
	ld	HL,Row11+27
	DRAW1SHIPLINE
	ld	HL,Row12+27
	DRAW1SHIPLINE
	ld	HL,Row13+27
	DRAW1SHIPLINE
	ld	HL,Row14+27
	DRAW1SHIPLINE
	ld	HL,Row15+27
	DRAW1SHIPLINE

	ld	BC,shipR4
	ld	HL,Row18+27
	DRAW1SHIPLINE
	ld	HL,Row19+27
	DRAW1SHIPLINE
	ld	HL,Row20+27
	DRAW1SHIPLINE
	ld	HL,Row21+27
	DRAW1SHIPLINE
	ld	HL,Row22+27
	DRAW1SHIPLINE
	ld	HL,Row23+27
	DRAW1SHIPLINE

	ret

	;
	; Draw boxes for screen overview & lives
	;
Box1	DB $01,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$80,$00,$FF,$FF,$FF,$FF,$00
Box2	DB $01,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$80,$00,$80,$00,$00,$01,$00

DrawTopBoxes:
	ld	DE,Row0
	ld	HL,Box1
	ld	BC,32
	ldir

	ld	DE,Row1
	ld	HL,Box2
	ld	BC,32
	ldir

	ld	DE,Row25
	ld	HL,Box2
	ld	BC,32
	ldir

	ld	DE,Row26
	ld	HL,Box1
	ld	BC,32
	ldir

	ret




PrintHLAtDE:
	push DE
	call Bin2Bcd
	ld DE,asciibuf
	call Bcd2HexAscii
	ld HL,asciibuf

	ld A,(asciibuf+0)
	add A,16
	pop HL
	inc HL
	push HL
	dec HL
	call DispNum

	ld A,(asciibuf+1)
	add A,16
	pop HL
	inc HL
	push HL
	dec HL
	call DispNum

	ld A,(asciibuf+2)
	add A,16
	pop HL
	inc HL
	push HL
	dec HL
	call DispNum

	ld A,(asciibuf+3)
	add A,16
	pop HL
	inc HL
	push HL
	dec HL
	call DispNum

	ld A,(asciibuf+4)
	add A,16
	pop HL
	inc HL
	push HL
	dec HL
	call DispNum

	ld A,(asciibuf+5)
	add A,16
	pop HL
	call DispNum

	ret

asciibuf DS 6

;;--------------------------------------------------
;; Binary to BCD conversion
;;
;; Converts a 16-bit unsigned integer into a 6-digit
;; BCD number. 1181 Tcycles
;;
;; input: HL = unsigned integer to convert
;; output: C:HL = 6-digit BCD number
;; destroys: A,F,B,C,D,E,H,L
;;--------------------------------------------------
Bin2Bcd:
	LD BC, 16*256+0 ; handle 16 bits, one bit per iteration
	LD DE, 0
cvtLoop:
	ADD HL, HL
	LD A, E
	ADC A, A
	DAA
	LD E, A
	LD A, D
	ADC A, A
	DAA
	LD D, A
	LD A, C
	ADC A, A
	DAA
	LD C, A
	DJNZ cvtLoop
	EX DE,HL
	RET

;;----------------------------------------------------
;; Converts a 6-digit BCD number to a hex ASCII string
;;
;; input: DE = pointer to start of ASCII string
;; C:HL number to be converted
;; output: DE = pointer past end of ASCII string
;; destroys: A,F,D,E
;;-----------------------------------------------------
Bcd2HexAscii:
	LD A, C
	CALL cvtUpperNibble
	LD A, C
	CALL cvtLowerNibble
	LD A, H
	CALL cvtUpperNibble
	LD A, H
	CALL cvtLowerNibble
	LD A, L
	CALL cvtUpperNibble
	LD A, L
	JR cvtLowerNibble
cvtUpperNibble:
	RRA ; move upper nibble into lower nibble
	RRA
	RRA
	RRA
cvtLowerNibble:
	AND $0F ; isolate lower nibble
	ADD A,$90 ; old trick
	DAA ; for converting
	ADC A,$40 ; one nibble
	DAA ; to hex ASCII
	LD (DE), A
	INC DE
	RET

	 END Start
