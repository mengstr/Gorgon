;
; Macro that does aligning to an even multiple of the specified number
; If the PC is ajdusted the space is filled with NOP's
;
ALIGN MACRO n

	LOCAL newpos, oldpos

oldpos	equ $
newpos	equ (oldpos + n - 1) / n * n

	IF newpos < oldpos
	.error Align out of memory
	ENDIF

	REPT newpos - oldpos
	    nop
	ENDM

ENDM


;
; Clear carry using the regular OR A-method. The macro allows for
; easier-to-read code
;
CLC MACRO
	OR 	A
ENDM
