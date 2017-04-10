;                   Bit   4  3  2  1  0
PORTbm	EQU 32766	; B, N, M, Symbol Shift, Space
PORThl	EQU 49150	; H, J, K, L, Enter
PORTyp	EQU 57342	; Y, U, I, O, P
PORT60	EQU 61438	; 6, 7, 8, 9, 0
PORT51	EQU 63486 	; 5, 4, 3, 2, 1
PORTtq	EQU 64510 	; T, R, E, W, Q
PORTga	EQU 65022 	; G, F, D, S, A
PORTvz	EQU 65278 	; V, C, X, Z, Caps Shift

KEYb	EQU 4		; PORTbm
KEYn	EQU 3		; PORTbm
KEYm	EQU 2		; PORTbm
KEYsym	EQU 1		; PORTbm
KEYspa	EQU 0		; PORTbm

KEYh	EQU 4		; PORThl
KEYj	EQU 3		; PORThl
KEYk	EQU 2		; PORThl
KEYl	EQU 1		; PORThl
KEYent	EQU 0		; PORThl

KEYy	EQU 4		; PORTyp
KEYu	EQU 3		; PORTyp
KEYi	EQU 2		; PORTyp
KEYo	EQU 1		; PORTyp
KEYp	EQU 0		; PORTyp

KEY6	EQU 4		; PORT60
KEY7	EQU 3		; PORT60
KEY8	EQU 2		; PORT60
KEY9	EQU 1		; PORT60
KEY0	EQU 0		; PORT60

KEY5	EQU 4		; PORT51
KEY4	EQU 3		; PORT51
KEY3	EQU 2		; PORT51
KEY2	EQU 1		; PORT51
KEY1	EQU 0		; PORT51

KEYg	EQU 4		; PORTga
KEYf	EQU 3		; PORTga
KEYd	EQU 2		; PORTga
KEYs	EQU 1		; PORTga
KEYa	EQU 0		; PORTga

KEYv	EQU 4		; PORTvz
KEYc	EQU 3		; PORTvz
KEYx	EQU 2		; PORTvz
KEYz	EQU 1		; PORTvz
KEYcap	EQU 0		; PORTvz
