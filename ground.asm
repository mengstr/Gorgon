	include "grounddata.inc"
	include "groundmapdata.inc"
	ALIGN 128
	include "mapXscaler.inc"
	include "mapYscaler.inc"

NEXTGROUNDLINEOFFSET EQU 1024/8

;
;
;
MACRO DRAW1GROUNDLINEAT,myRow
	ld	DE,myRow
 IFDEF OPTSPEED
  REPT 32
  	ldi
  ENDM
 ELSE
	ld	BC,32
	ldir
 ENDIF
	ld	BC,NEXTGROUNDLINEOFFSET
	add	HL,BC
ENDM


	;
	; Calculate the starting address of the pre-shifted ground bitmap
	; according to the 2 LSB of groundx
	;
DrawGround:
	ld	BC,(cameraX)

	srl	B
	rr	C

	ld	A,C
	and	%00000011
	srl	B		; The lower two bits is used to select one of
	rr	C		; four different pre-shifted ground images so
	srl	B		; we need to shift BC right by two bits (/4)
	rr	C		; to use for the bytes offset into the ground

	cp	0		; Select the right pre-shifted ground table
	jp	NZ,gofs1	; according to A (the two LSB of groundx)
	ld	HL,Ground0ofs0
gofs1	cp	1
	jp	NZ,gofs2
	ld	HL,Ground0ofs1
gofs2	cp	2
	jp	NZ,gofs3
	ld	HL,Ground0ofs2
gofs3	cp	3
	jp	NZ,gofs4
	ld	HL,Ground0ofs3
gofs4

	add	HL,BC		; Add byte-offset to the address of the
				; selected ground table

 IRP V,<166,167,168,169,170,171,172,173,174,175,176,177,178,179>
	DRAW1GROUNDLINEAT Row##V
 ENDM
	ret

;
; Draw the small ground data into the overview map on top of screen
;
DrawGroundMap:
	ld	HL,GroundMap0
 IRP V,<19,20,21,22,23,24>
	ld	DE,1+Row##V
	ld	BC,24
	ldir
 ENDM
	ret


;
;
;
DrawShipAtMap:
	ld	A,(shipY)	;       0..140
	srl	A		; A/=2  0..70
	add	A,A		; Two-bytes lookup table
	ld	HL,LookupMapYscaler
	add	A,L
	ld	L,A
	ld	E,(HL)		; DE=Row address in the map for shipY
	inc	HL		;.
	ld	D,(HL)		;.

	ld	HL,(shipX)	;        0..1024
	srl	H		; HL/=8  0..128
	rr	L		;.
	srl	H		;.
	rr	L		;.
	srl	H		;.
	rr	L		;.
	ld	BC,LookupMapXscaler
	add	HL,BC
	ld	A,(HL)		; A now holds 0..191
	push	AF		; Keep A for the bits within the byte
	srl	A		; /8          0..23
	srl	A		;...
	srl	A		;...

	ex	DE,HL		; HL now is the address

	add	A,L		; Add the X-offset
	ld	L,A

	pop	AF
	and	%00000111
	add	a,a
	push	HL
	ld	HL,DoublePixel
	add	A,L
	ld	L,A
	ld	A,(HL)
	ld	B,A
	inc	HL
	ld	A,(HL)
	ld	C,A
	pop	HL

	ld	A,(HL)		; Paint a blob there
	xor	C
	ld	(HL),A
	inc	HL
	ld	A,(HL)		; Paint a blob there
	xor	B
	ld	(HL),A

	ret


 ALIGN 16
DoublePixel:
	DW %1100000000000000
	DW %0110000000000000
	DW %0011000000000000
	DW %0001100000000000
	DW %0000110000000000
	DW %0000011000000000
	DW %0000001100000000
	DW %0000000110000000
