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

;DEBUG		EQU	1
CPUBORDER	EQU 	1		; 0=Disable, 1=Enable
XFRICTION	EQU	1		; Horizontal air-drag
YFRICTION	EQU	1		; Vertical air-drag

MAXSHIPYSPEED 	EQU	24
MAXSHIPXSPEED 	EQU	31

RESIDUALSPEED	EQU 	12

WORLDWIDTH	EQU	1280
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
	DB 22,1,0,'SCORE: ..... HI:..... FUEL:.... '
Footer_: EQU $

holdL		DB 0
holdH		DB 0
holdSP		DW 0
fire		DB 0

cameraX		DW	WORLDWIDTH/2


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
	call	UpdateShipX

	ld	HL,(shipX)
	ld	(cameraX),HL

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
	call	SETBRDR
	halt
	ld	A,BLUE
	call	SETBRDR
 ENDIF
	jp	Loop


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
