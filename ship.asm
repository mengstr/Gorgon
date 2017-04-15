	include "shipdata.inc"

shipXdir	DB 0	; 0=Right, 1=Left

shipX		DW WORLDWIDTH/2-128 ; Horizontal position of ship

rawShipXspeed	DB 1	; Value -127..+127 inc/dec by keys used as index into
			; a lookup table to get shipXspeed

shipXspeed	DB 0	; Value to be added to shipXspeedAcc at every frame

shipXspeedAcc	DB 0	; Added to shipX as shifted by >> 3 at every frame

shipYdir	DB 1	; 0=Down, 1=Up

shipY		DB 70	; Vertical position of ship (start in the middle)

rawShipYspeed	DB 0	; Value -127..+127 inc/dec by keys used as index into
			; a lookup table to get shipYspeed

shipYspeed	DB 0	; Value to be added to shipYspeedAcc at every frame

shipYspeedAcc	DB 0	; Added to shipY as shifted by >> 3 at every frame

;
;
;
DrawShip:
	; Calculate the 6 starting addresses on the screen according to
	; shipx and shipy variables.
	ld	BC,0
	ld	A,(shipY)
	ld	C,A
	ld	HL,RowLookup+SHIPWORLDTOP ; Offset down into the playfield
	add	HL,BC
	add	HL,BC
	ex	DE,HL		; DE=Screen line starting addresses

	ld	HL,(shipX)	; BC=shipx/8 for byte offset
	ld	BC,(cameraX)
	CLC
	sbc	HL,BC
	ld	BC,128
	add	HL,BC
	ld	A,H			; Wrap at 1024
	and	3			;  ...
	ld	H,A			;  ...
	ld	B,H
	ld	C,L
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
	ld	A,(cameraX)
	ld	C,A
	ld	A,(shipX)
	sub	C
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
	ld	A,(shipXdir)	; Left/Right sprites are $100 apart
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
	ld	SP,(holdSP)		; Restore the SP after erasing

	; Draw the six lines of the selected ship at
	; the six addresses pushed to the stack earlier
 REPT	6,V
	pop	DE
	ld	A,E
	inc	A
	ld	(shp##V + 1),A
	ld	A,D
	ld	(shp##V + 2),A
  IFDEF OPTSPEED
   REPT 4
  	ldd
   ENDM
  ELSE
	ld	BC,4
	lddr
  ENDIF
 ENDM

  ret


;
; Update ship Y counters and position
;
UpdateShipY:
	ld	A,(shipYdir)		; Stash shipYdir in C for later usage
	ld	C,A

IFDEF YFRICTION
	ld	A,(rawShipYspeed)	; Introduce some friction/drag
 	cp	0			; if (speed>0) speed--;
 	jp	Z,noydec
 	dec	A
noydec	ld 	(rawShipYspeed),A
ENDIF

	ld	A,(rawShipYspeed)	; TODO - lookuptable
	ld	(shipYspeed),A

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
	bit	0,C			; Make value negative if the shipYdir
	jp	Z,notyneg		; is going up
	neg
notyneg	ld	B,A			; shipY+='integer part of acc'
	ld	A,(shipY)
	add	A,B

	cp	230			; Bound shipY within 0..140
	jp	C,ydone1
	ld	A,0
	jp	ydone2
ydone1	cp	140
	jp	C,ydone2
	ld	A,140
ydone2	ld	(shipY),A

	ld	A,(shipYspeedAcc)	; Remove used integer part from acc
	and	%00000111
	ld	(shipYspeedAcc),A
noychange:
	ret


;
;
;
UpdateShipX:
IFDEF XFRICTION
	ld	A,(rawShipXspeed)	; Introduce some friction/drag
 	cp	0			; if (speed>0) speed--;
 	jp	Z,noxdec
 	dec	A
noxdec	ld 	(rawShipXspeed),A
ENDIF

	ld	A,(rawShipXspeed)	; TODO - table loopup
	ld	(shipXspeed),A

	ld	A,(shipXspeed)
	ld	B,A
	ld	A,(shipXspeedAcc)
	add	A,B
	ld	(shipXspeedAcc),A
	and	%11111000		; Is the integer part 0?
	jp	Z,nochange		; Yes, no need for update of ship

	srl	A			; Shift away the decimal part
	srl	A
	srl	A
	ld	C,A
	ld	A,0
	ld	B,A
	ld	HL,(shipX)
	ld	A,(shipXdir)
	bit	0,A			; Make value negative if the shipXdir
	jp	Z,notxneg		; is going left
	CLC
	sbc	HL,BC
	jp	donex

notxneg	add	HL,BC			; shipX+='integer part of acc'

donex	ld	A,H			; Wrap at right and left edges
	and	3
	ld	H,A
	ld	(shipX),HL

	ld	A,(shipXspeedAcc)	; Remove used integer part from acc
	and	%00000111
	ld	(shipXspeedAcc),A

nochange
	ret


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
