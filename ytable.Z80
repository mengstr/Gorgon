;
; Use a macro-repeat to create a the table of addresses where each of
; the 192 rows on the screen starts in memory
;

RowLookup:
	REPT	192,V
	DW	$4000+((((V&$7)<<3) | ((V>>3)&$7) | (V&$C0)) << 5)
Row##V	EQU	$4000+((((V&$7)<<3) | ((V>>3)&$7) | (V&$C0)) << 5)
	ENDM
