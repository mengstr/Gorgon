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

BLACK	EQU 0		; BK
BLUE	EQU 1		; BL
RED	EQU 2		; RE
MAGENTA	EQU 3		; MA
GREEN	EQU 4		; GR
CYAN	EQU 5		; CY
YELLOW	EQU 6		; YL
WHITE	EQU 7		; WH

	include "colors.inc"



LASTLINE	EQU 191
GROUNDHEIGHT	EQU 16
SCOREHEIGHT	EQU 9
GROUNDSTART	EQU LASTLINE-SCOREHEIGHT-GROUNDHEIGHT
NEXTGROUNDLINEOFFSET EQU 32*5

;
;
;
DRAW1SHIPLINE MACRO
	ld	A,(BC)
	ld	(HL),A
	inc	HL
	inc	BC
	ld	A,(BC)
	ld	(HL),A
	inc	HL
	inc	BC
	ld	A,(BC)
	ld	(HL),A
	inc	HL
	inc	BC
	ld	A,(BC)
	ld	(HL),A
	inc	HL
	inc	BC
ENDM

	include "align.asm"


	ORG SLOWRAM
	ALIGN	256
	include "fatfont.asm"

	ORG FASTRAM
	include "ytable.asm"
	include "shipdata.asm"
	include "score.asm"
	include "ground.asm"
	include "key.asm"


Footer:
	DB 22,1,0,'SCRE: ..... HISC:..... FUEL:....'
Footer_: EQU $

holdL	DB	0
holdH	DB	0

shipx	DW	128
shipy	DW	0

holdSP	DW	0

Start:
	ld	A,BLACK
	call	SETBRDR

	ld	A,RED<<8+WHITE
	ld	(23693),A 	; Set screen colours.

	call	CLRSCR 		; clear the screen.

	ld	A,253
	call	OPENCHN

	ld	DE,Footer 	; address of string
	ld	BC,Footer_ - Footer ; length of string to print
	call	8252 		; print our string

	call	ResetScores
	call	DrawTopBoxes
	call	DrawGroundMap
	call	DrawRemainingShips

 REPT $400,V
	ld	A, (YELLOW*8)+BLUE+(((V & 32) XOR ((V & 1) * 32)) * 2)
	ld	(ATTRIBS+V),A
 ENDM

Loop:
	ld	BC,65022
	in	A,(C)
	bit	0,A
	jp	Z,UpKey
	ld	BC,65278
	in	A,(C)
	bit	1,A
	jp	Z,DownKey
	jp	NoKey1

UpKey:
	ld	HL,shipy
	dec	(HL)
	jp	NoKey1
DownKey:
	ld	HL,shipy
	inc	(HL)
	jp	NoKey1
NoKey1

	ld	BC,49150
	in	A,(C)
	bit	3,A
	jp	Z,LeftKey
	bit	2,A
	jp	Z,RightKey
	jp	NoKey2

LeftKey:
	ld	HL,shipx
	dec	(HL)
	jp	NoKey2
RightKey:
	ld	HL,shipx
	inc	(HL)
	jp	NoKey2


NoKey2:
	call	ScoreDisplayer
	call	DrawGround

	;
	; Calculate the 6 starting addresses on the screen according to
	; shipx and shipy variables.
	ld	BC,0
	ld	A,(shipy)
	ld	C,A
	ld	HL,RowLookup+56	; Offset down into the playfield
	add	HL,BC
	add	HL,BC
	ex	DE,HL		; DE=Screen line starting addresses

	ld	BC,(shipx)	; BC=shipx/8 for byte offset
	srl	B
	rr	C
	srl	B
	rr	C
	srl	B
	rr	C

  REPT 6
	ld	A,(DE)
	ld	L,A
	inc	DE
	ld	A,(DE)
	ld	H,A
	inc	DE
	add	HL,BC
	push	HL
  ENDM
 	;
	; Calculate the address of the correct ship image according
	; to the 3 LSB of the shipx variable
	;
	ld	A,(shipx)
	and	%00000111
	add	A,A
	ld	DE,shipRLUT
	add	A,E
	ld	E,A
	ld	A,(DE)
	ld	L,A		; The address should end up
	inc	DE		; in HL
	ld	A,(DE)
	ld	H,A


	;
	; Erase the 6 lines of the old ship from screen
	;
	ld	(holdSP),SP		; The eraser uses the SP, so save it
	ld	BC,$0000		; first
  REPT	6,V
shp##V	ld	SP,$FFFF
	push	BC
	push	BC
  ENDM
	ld	SP,(holdSP)		; Restore the SP after eraser

	;
	; Draw the six lines of the selected ship at
	; the six addresses pushed to the stack earlier
	;
  REPT	6,V
	ld	BC,4
	pop	DE
	ld	A,E
	inc	A
	ld	(shp##V + 1),A
	ld	A,D
	ld	(shp##V + 2),A
	lddr
  ENDM

	ld	HL,shipy
	ld	A,(shipy)
	cp	150
	jp	Z,L3
;	inc	(HL)
L3

	ld	A,BLACK
	call	SETBRDR
	halt
	ld	A,GREEN
	call	SETBRDR
	jp	Loop

JallaBye:
	halt
	call	WaitForKey
	ret

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
WaitForKey:
	ld	hl,LASTK	; LAST K system variable.
	ld	(hl),0		; put null value there.
wfk0	ld	a,(hl)		; new value of LAST K.
	cp	0		; is it still zero?
	jr	z,wfk0		; yes, so no key pressed.
	ret			; key was pressed.


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
