	include "shipdata.inc"

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

	; Calculate the address of the correct ship image according
	; to the 3 LSB of the shipx variable
	ld	A,(shipx)
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