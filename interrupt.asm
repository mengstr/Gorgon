;
; Create a full page plus one extra of jump vectors to $FDFD for the
; Interrupt 2 mode. The extra is required since FUSE sets the bus part to
; $FF resulting in the vector being fetched from $xxFF and $yy00 where
; yy is xx+1. Running in a real spectrum or other emulator might use another
; (odd or even) value for the bus part, so better use the same vale for both
; the high and low byte of the vector so it doesn't matter if the value is
; fetched starting at an odd or even address.
;
; Page usage:
;  $FDFD - IM2 ISR. Holds just a patched in jump to the real code in lower ram
;  $FExx - Vectors to the $FDFD IM2Trampoline
;  $FF00 - Last part of a vector to the $FDFD IM2Trampoline
;
; Free memory in this area:
;  $FD00..$FDFC
;  $FFF1..$FFFF
;

IM2Trampoline EQU $FDFD

;
;
;
SetupIM2:
	ld 	BC,$100		; Fill 257 bytes with $FC starting at $FE00
	ld 	HL,$FE00
	ld 	DE,$FE01
	ld 	(HL),HIGH IM2Trampoline
	ldir

  	; Patch in the jump to
	ld	HL,IM2Trampoline
	ld	A,$C3
	ld	(HL),A
	inc	HL
	ld	A,LOW IM2Handler
	ld	(HL),A
	inc	HL
	ld	A,HIGH IM2Handler
	ld	(HL),A

	; Tell the Interrupt subsystem to use page $FDxx for vectors
	ld 	A,HIGH IM2Trampoline
	ld 	I,A		; Set high of IM2 byte
	im	2		; Enable Interrupt mode 2
	ret

;
;
;
IM2Handler:
	ei
	reti
