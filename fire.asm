	ALIGN 256
	include "laserdata.inc"

LASERSTEPS EQU 12	; Number of images to be displaed one-by-one
LASERLENGTH EQU 21	; Number of bytes in each laser image

MAXLASERS EQU	6	; How many active lasers there can be on screen

LASERSTEP	EQU 0	; Byte positions into the laserArr struct
LASERSRCOFS	EQU 1
LASERDST	EQU 2
LASERDSTl	EQU 2
LASERDSTh	EQU 3
LASERLEN	EQU 4
LASERDIR	EQU 5

LASERSTRUCTSIZE	EQU 6

laserArr
 REPT MAXLASERS
	DB LASERSTEPS+1	; laserStep
	DB 0		; srcOfs     Offset for the next image to draw
	DW 0		; dstLoc     Memory location for first drawn byte
	DB 0		; laserLen   Number of bytes to draw from each image
	DB 0		; laserDir   SHIPRIGHT/SHIPLEFT
 ENDM

;
;
;
Fire:
	ld	B,MAXLASERS		; Scan thru all slots
	ld	DE,LASERSTRUCTSIZE	; Each slot is _ bytes long
	ld	IX,laserArr		; First slot
fireSlotLoop:
	ld 	A,(IX+LASERSTEP)
	cp	LASERSTEPS+1		; All steps done == is free
	jp	Z,FireSlotFound
	add	IX,DE			; Goto next slot and test
	djnz	fireSlotLoop
	ret

FireSlotFound:
	ld	A,0
	ld	(IX+LASERSTEP),A
	ld	(IX+LASERSRCOFS),A
	ld	A,(shipXdir)
	ld	(IX+LASERDIR),A
	cp	SHIPLEFT
	jp	Z,SetupLeftFire

	; Setup variables for the new shot. When shooting to the right
	; the laser should start 1 memory cell to the right of the ship
	; location
SetupRightFire:
	ld      HL,(shipScreenPos)
	inc 	HL
       	ld	(IX+LASERDSTl),L
	ld	(IX+LASERDSTh),H
	ld	A,L			; Calculate length of laser beam
	and	$1F
	ld	B,A
	ld	A,32
	sub	B
	ld	(IX+LASERLEN),A
	ret

	; Setup variables for the new shot. When shooting to the left
	; the laser should start 4 memory cells to the left of the ship
	; location
SetupLeftFire:
	ld      HL,(shipScreenPos)
	dec	HL
	dec	HL
	dec	HL
 	dec	HL
       	ld	(IX+LASERDSTl),L
	ld	(IX+LASERDSTh),H
	ld	A,L			; Calculate length of laser beam
	and	$1F
	inc 	A
	ld	(IX+LASERLEN),A

	ret

;
;
;
UpdateShots:
	ld	IX,laserArr
	ld	B,MAXLASERS
updShotLoop
	push	BC
	call	UpdateLaser
	POP	BC
	ld	DE,LASERSTRUCTSIZE
	add	IX,DE
	djnz	updShotLoop
	ret

;
;
;
UpdateLaser:
	ld 	A,(IX+LASERSTEP); If step is the last step we have nothing to
	cp	LASERSTEPS+1		; update so just return to caller
	ret 	Z

	cp	LASERSTEPS
	jp	Z,laserErase

	inc	A			; Increment & store step variable
	ld	(IX+LASERSTEP),A

	; Update the laser fire by drawing the next fire image on the line
	ld	A,(IX+LASERLEN)		; Fetch length of laser beam
	ld	B,A

	ld	E,(IX+LASERDSTl)	; Fetch screen location of laser
	ld	D,(IX+LASERDSTh)

	ld	HL,LaserData		; Calculate the memory location of
	ld	A,(IX+LASERSRCOFS)	; the beginning of the laserdata
	ld	L,A			; into HL

	add	A,LASERLENGTH		; Update the SRC offset already for
	ld	(IX+LASERSRCOFS),A	; the next line

	ld	A,(IX+LASERDIR)		; Jump to the function for drawing
	cp	SHIPLEFT		; the laser either left or right
	jp	Z,shootLaserLeft

shootLaserRight
	ld	A,(HL)
	ld	(DE),A
	inc	DE
	inc	HL
	djnz	shootLaserRight
	ret

shootLaserLeft
	ld	A,(HL)
	ld	(DE),A
	dec	DE
	inc	HL
	djnz	shootLaserLeft
	ret

;
; Lot of code repeated from the drawing above. All of this could be removed
; if the last line of the laser data was just blanks.
;
laserErase:
	inc	A			; Increment & store step variable
	ld	(IX+LASERSTEP),A

	ld	A,(IX+LASERLEN)		; Fetch length of laser beam to be
	ld	B,A			; erased

	ld	E,(IX+LASERDSTl)	; Fetch screen location of laser
	ld	D,(IX+LASERDSTh)

	ld	A,(IX+LASERDIR)		; Jump to the function for drawing
	cp	SHIPLEFT		; the laser either left or right
	jp	Z,eraseLaserLeft

eraseLaserRight
	ld	A,0
eraseLaserRight1
	ld	(DE),A
	inc	DE
	djnz	eraseLaserRight1
	ret

eraseLaserLeft
	ld	A,0
eraseLaserLeft1
	ld	(DE),A
	dec	DE
	djnz	eraseLaserLeft1
	ret


