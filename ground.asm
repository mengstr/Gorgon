	include "grounddata.inc"
	include "groundmapdata.inc"

;
;
;
MACRO DRAW1GROUNDLINEAT,myRow
	ld	DE,myRow
	ld	BC,32
	ldir
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

	DRAW1GROUNDLINEAT Row166
	DRAW1GROUNDLINEAT Row167
	DRAW1GROUNDLINEAT Row168
	DRAW1GROUNDLINEAT Row169
	DRAW1GROUNDLINEAT Row170
	DRAW1GROUNDLINEAT Row171
	DRAW1GROUNDLINEAT Row172
	DRAW1GROUNDLINEAT Row173
	DRAW1GROUNDLINEAT Row174
	DRAW1GROUNDLINEAT Row175
	DRAW1GROUNDLINEAT Row176
	DRAW1GROUNDLINEAT Row177
	DRAW1GROUNDLINEAT Row178
	DRAW1GROUNDLINEAT Row179

	ret

;
; Draw the small ground data into the overview map on top of screen
;
DrawGroundMap:
	ld	DE,Row19+2
	ld	HL,GroundMap0
	ld	BC,20
	ldir
	ld	DE,Row20+2
	ld	HL,GroundMap1
	ld	BC,20
	ldir
	ld	DE,Row21+2
	ld	HL,GroundMap2
	ld	BC,20
	ldir
	ld	DE,Row22+2
	ld	HL,GroundMap3
	ld	BC,20
	ldir
	ld	DE,Row23+2
	ld	HL,GroundMap4
	ld	BC,20
	ldir
	ld	DE,Row24+2
	ld	HL,GroundMap5
	ld	BC,20
	ldir

	ret

