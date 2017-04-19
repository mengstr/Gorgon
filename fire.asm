	ALIGN 256
	include "laserdata.inc"
LASERSTEPS EQU 16

LASERSTEP EQU 0
LASERLOC  EQU 1
LASERLOCl EQU 1
LASERLOCh EQU 2
LASERLEN  EQU 3
LASERDIR  EQU 4

laserArr
 REPT 6
	DB	31	; laserStep
	DW	0	; laserLoc
	DB	1	; laserLen
	DB	0	; laserDir
 ENDM

;
;
;
Fire:
	ld	IX,laserArr
	ld 	A,(IX+LASERSTEP)	; Can't fire if already doing a shot
	cp	31
	jp	Z,FireFound

	ld	IX,laserArr+5
	ld 	A,(IX+LASERSTEP)	; Can't fire if already doing a shot
	cp	31
	jp	Z,FireFound

	ld	IX,laserArr+10
	ld 	A,(IX+LASERSTEP)	; Can't fire if already doing a shot
	cp	31
	jp	Z,FireFound

	ld	IX,laserArr+15
	ld 	A,(IX+LASERSTEP)	; Can't fire if already doing a shot
	cp	31
	jp	Z,FireFound

	ld	IX,laserArr+20
	ld 	A,(IX+LASERSTEP)	; Can't fire if already doing a shot
	cp	31
	jp	Z,FireFound

	ret

FireFound:
	ld	HL,(shipScreenPos)	; Setup variables for the new shot
	ld	(IX+LASERLOCl),L
	ld	(IX+LASERLOCh),H
	ld	A,15
	ld	(IX+LASERLEN),A
	ld	A,0
	ld	(IX+LASERSTEP),A
	ld	A,(shipXdir)
	ld	(IX+LASERDIR),A
	ret

;
;
;
UpdateShots:
	ld	IX,laserArr+0
	call	UpdateLaser
	ld	IX,laserArr+5
	call	UpdateLaser
	ld	IX,laserArr+10
	call	UpdateLaser
	ld	IX,laserArr+15
	call	UpdateLaser
	ld	IX,laserArr+20
	call	UpdateLaser
	ret
;
;
;
UpdateLaser:
	ld 	A,(IX+LASERSTEP); If step is _ we have nothing to update
	cp	31		; to just return to caller
	ret 	Z
	inc	A		; Increment & store step variable
	ld	(IX+LASERSTEP),A

	ld	A,(IX+LASERLEN)	; Update the fire
	ld	B,A
	ld	E,(IX+LASERLOCl)
	ld	D,(IX+LASERLOCh)
	ld	HL,LaserData
	ld	A,(IX+LASERSTEP)
	srl	A
	add	A,A
	add	A,A
	add	A,A
	add	A,A
	add	A,L
	ld	L,A

	ld	A,(IX+LASERDIR)
	cp	SHIPLEFT
	jp	Z,shootLaserLeft

shootLaserRight
	inc 	DE
loopLaserRight
	ld	A,(HL)
	ld	(DE),A
	inc	DE
	ld	(DE),A
	inc	DE
	inc	HL
	djnz	loopLaserRight
	ret

shootLaserLeft
	dec 	DE
	dec 	DE
	dec 	DE
loopLaserLeft
	ld	A,(HL)
	ld	(DE),A
	dec	DE
	ld	(DE),A
	dec	DE
	inc	HL
	djnz	loopLaserLeft
	ret



