	include "shipdata.inc"

shipdir		DB 0	; 0=Right, 1=Left

shipX		DW 128	; Horizontal postion of ship on screen

rawShipXspeed	DB 0	; Value -127..+127 inc/dec by keys used as index into
			; a lookup table to get shipXspeed

shipXspeed	DB 0	; Value to be added to shipXspeedAcc at every frame

shipXspeedAcc	DB 0	; Added to shipX as shifted by >> 3 at every frame

shipY		DB 0	; Vertical position of ship

rawShipYspeed	DB 0	; Value -127..+127 inc/dec by keys used as index into
			; a lookup table to get shipYspeed

shipYspeed	DB 4	; Value to be added to shipYspeedAcc at every frame

shipYspeedAcc	DB 0	; Added to shipY as shifted by >> 3 at every frame


;
;  Used for displaying the number of remanining lives
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


;
;
;
DrawShip:
	; Calculate the 6 starting addresses on the screen according to
	; shipx and shipy variables.
	ld	BC,0
	ld	A,(shipY)
	ld	C,A
	ld	HL,RowLookup+56	; Offset down into the playfield
	add	HL,BC
	add	HL,BC
	ex	DE,HL		; DE=Screen line starting addresses

	ld	BC,(shipX)	; BC=shipx/8 for byte offset
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

	; Calculate the address of the correct ship image according
	; to the 3 LSB of the shipx variable
	ld	A,(shipX)
	and	%00000111
	add	A,A
	ld	DE,shipRLUT
	add	A,E
	ld	E,A
	ld	A,(DE)		; The address should end up in HL
	ld	L,A
	inc	DE
	ld	A,(DE)
	ld	H,A
	ld	A,(shipdir)	; Left/Right sprites are $100 apart
	add	A,H
	ld	H,A


	; Erase the 6 lines of the old ship from screen
	ld	(holdSP),SP		; The eraser uses the SP, so save it
	ld	BC,$0000		; first
  REPT	6,V
shp##V	ld	SP,$FFFF
	push	BC
	push	BC
  ENDM
	ld	SP,(holdSP)		; Restore the SP after eraser

	; Draw the six lines of the selected ship at
	; the six addresses pushed to the stack earlier
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

  ret


;
; Update ship Y counters and position
;
UpdateShipY:
	ld	A,(shipYspeed)		; shipYspeedAcc+=shipYspeed
	ld	B,A
	ld	A,(shipYspeedAcc)
	add	A,B
	ld	(shipYspeedAcc),A
	and	%11111000		; Is the integer part 0?
	jp	Z,noychange		; Yes, no need for update of ship

	srl	A			; Shift away the decimal part
	srl	A
	srl	A
	ld	B,A			; shipY+='integer part of acc'
	ld	A,(shipY)
	add	A,B

	cp	230			; Bound shipY within 0..140
	jp	C,ydone1
	ld	A,140	;0
	jp	ydone2
ydone1	cp	140
	jp	C,ydone2
	ld	A,0 	;140
ydone2	ld	(shipY),A

	ld	A,(shipYspeedAcc)	; Remove used integer part from acc
	and	%00000111
	ld	(shipYspeedAcc),A
noychange:
	ret
