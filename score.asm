Score	DB 6,5,0,3,1
HiScore	DB 8,1,1,1,4
Fuel	DB 4,7,1,1

;
;
;
ResetScores:
	ld	A,0
	ld	(Score+0),A
	ld	(Score+1),A
	ld	(Score+2),A
	ld	(Score+3),A
	ld	(Score+4),A
	ld	(HiScore+0),A
	ld	(HiScore+1),A
	ld	(HiScore+2),A
	ld	(HiScore+3),A
	ld	(HiScore+4),A
	ld	A,9
	ld	(Fuel+0),A
	ld	(Fuel+1),A
	ld	(Fuel+2),A
	ld	(Fuel+3),A

	ld	B,14		; Refresh all 14 digits now
rs0
	push	BC
	call	ScoreDisplayer
	pop	BC
	djnz	rs0

	ret


;
; Functions called to display 1 character at a time every frame
; out of the 14 required to show the full Score, HiScore and Fuel data
;

ScoreDisplayer:
	ld	A,(sdCnt)
	add	A,3
	cp	14*3
	jp	nz,sd0
	ld	A,0
sd0:	ld	(sdCnt),A
	ld	HL,SD
	add	A,L
	ld	L,A
	push	HL
	ret

	ALIGN 64

SD:	JP	DispScore0
	JP	DispScore1
	JP	DispScore2
	JP	DispScore3
	JP	DispScore4
	JP	DispHiScore0
	JP	DispHiScore1
	JP	DispHiScore2
	JP	DispHiScore3
	JP	DispHiScore4
	JP	DispFuel0
	JP	DispFuel1
	JP	DispFuel2
	JP	DispFuel3

sdCnt:	DB	13*3		; Point to the last entry to immediatly wrap

DispScore0:
	ld	A,(Score+0)
	ld	HL,Row184+6
	jp	DispNum

DispScore1:
	ld	A,(Score+1)
	ld	HL,Row184+7
	jp	DispNum

DispScore2:
	ld	A,(Score+2)
	ld	HL,Row184+8
	jp	DispNum

DispScore3:
	ld	A,(Score+3)
	ld	HL,Row184+9
	jp	DispNum

DispScore4:
	ld	A,(Score+4)
	ld	HL,Row184+10
	jp	DispNum

DispHiScore0:
	ld	A,(HiScore+0)
	ld	HL,Row184+17
	jp	DispNum

DispHiScore1:
	ld	A,(HiScore+1)
	ld	HL,Row184+18
	jp	DispNum

DispHiScore2:
	ld	A,(HiScore+2)
	ld	HL,Row184+19
	jp	DispNum

DispHiScore3:
	ld	A,(HiScore+3)
	ld	HL,Row184+20
	jp	DispNum

DispHiScore4:
	ld	A,(HiScore+4)
	ld	HL,Row184+21
	jp	DispNum

DispFuel0:
	ld	A,(Fuel+0)
	ld	HL,Row184+28
	jp	DispNum

DispFuel1:
	ld	A,(Fuel+1)
	ld	HL,Row184+29
	jp	DispNum

DispFuel2:
	ld	A,(Fuel+2)
	ld	HL,Row184+30
	jp	DispNum

DispFuel3:
	ld	A,(Fuel+3)
	ld	HL,Row184+31
	jp	DispNum

