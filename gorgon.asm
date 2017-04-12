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
SETBRDR	EQU $229B 	; 8859 Routine to set border color with A
LASTK	EQU $5C08 	; 23560 Location holding the last pressed key
DF_SZ	EQU 23659
DF_CC	EQU 23684 	; Address of next character location for print
SCREEN	EQU $4000
ATTRIBS EQU $5800	; 5800..5B00=$400 locs. FL BL P2 P1 P0 I2 I1 I0
SLOWRAM	EQU $5DC0 	; 24000 First usable location in slow ram
FASTRAM	EQU $8000 	; 32768 Start of the faster upper 32K ram

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
CPUBORDER	EQU 	1		; 0=Disable, 1=Enable

MAXSHIPYSPEED 	EQU	4
MAXSHIPXSPEED 	EQU	16

LASTLINE	EQU 	191
GROUNDHEIGHT 	EQU	16
SCOREHEIGHT	EQU 	9
GROUNDSTART	EQU 	LASTLINE-SCOREHEIGHT-GROUNDHEIGHT
NEXTGROUNDLINEOFFSET EQU 32*5

	include "macros.asm"

	ORG SLOWRAM
	ALIGN	256
	include "fatfont.asm"
	include "ytable.asm"
	include "score.asm"
	include "ground.asm"
	include "ship.asm"
	include "key.asm"

Footer:
	DB 22,1,0,'SCRE: ..... HISC:..... FUEL:....'
Footer_: EQU $

holdL		DB 0
holdH		DB 0
holdSP		DW 0
fire		DB 0

Start:
	call	CLRSCR 		; clear the screen.
	ld	A,BLACK
	call	SETBRDR

	ld	A,WhBK		; Fill the screen attributes
 REPT $400,V
;	ld	A, (YELLOW*8)+BLUE+(((V & 32) XOR ((V & 1) * 32)) * 2)
	ld	(ATTRIBS+V),A
 ENDM

	ld	A,253
	call	OPENCHN

	ld	DE,Footer 	; address of string
	ld	BC,Footer_ - Footer ; length of string to print
	call	8252 		; print our string

	call	ResetScores
	call	DrawTopBoxes
	call	DrawGroundMap
	call	DrawRemainingShips

Loop:
	call 	ReadKeys
	call	ScoreDisplayer
	call	DrawGround
	call	DrawShip
	call	UpdateShipY

 IF CPUBORDER=0
 	halt
 ELSE
	ld		A,BLACK
	call	SETBRDR
	halt
	ld		A,BLUE
	call	SETBRDR
 ENDIF

	jp		Loop


;
; Displays a number 0..9 from A
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
	ld	HL,Row2+26
	DRAW1SHIPLINE
	ld	HL,Row3+26
	DRAW1SHIPLINE
	ld	HL,Row4+26
	DRAW1SHIPLINE
	ld	HL,Row5+26
	DRAW1SHIPLINE
	ld	HL,Row6+26
	DRAW1SHIPLINE
	ld	HL,Row7+26
	DRAW1SHIPLINE

	ld	BC,shipR4
	ld	HL,Row10+26
	DRAW1SHIPLINE
	ld	HL,Row11+26
	DRAW1SHIPLINE
	ld	HL,Row12+26
	DRAW1SHIPLINE
	ld	HL,Row13+26
	DRAW1SHIPLINE
	ld	HL,Row14+26
	DRAW1SHIPLINE
	ld	HL,Row15+26
	DRAW1SHIPLINE

	ld	BC,shipR4
	ld	HL,Row18+26
	DRAW1SHIPLINE
	ld	HL,Row19+26
	DRAW1SHIPLINE
	ld	HL,Row20+26
	DRAW1SHIPLINE
	ld	HL,Row21+26
	DRAW1SHIPLINE
	ld	HL,Row22+26
	DRAW1SHIPLINE
	ld	HL,Row23+26
	DRAW1SHIPLINE

	ret

	;
	; Draw boxes for screen overview & lives
	;
Box1	DB $00,$00,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$00,$00,$00,$00,$FF,$FF,$FF,$FF,$00,$00
Box2	DB $00,$00,$80,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$01,$00,$00,$00,$00,$80,$00,$00,$01,$00,$00

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


	 END Start
