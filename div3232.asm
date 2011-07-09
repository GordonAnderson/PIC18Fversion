;**********************************************************************************************
;**********************************************************************************************
;
;       32/32 Bit Signed Fixed Point Divide 32/32 -> 32.32
;
;       Input:  32 bit signed fixed point dividend in AARGB0, AARGB1,AARGB2,AARGB3
;               32 bit unsigned fixed point divisor in BARGB0, BARGB1, BARGB2, BARGB3
;
;       Use:    CALL    FXD3232S
;
;       Output: 32 bit signed fixed point quotient in AARGB0, AARGB1,AARGB2,AARGB3
;               32 bit fixed point remainder in REMB0, REMB1, REMB2, REMB3
;
;       Result: AARG, REM  <--  AARG / BARG
;
;       Max Timing:     27+573+5 = 605 clks             A > 0, B > 0
;                       34+573+23 = 630 clks            A > 0, B < 0
;                       34+573+23 = 630 clks            A < 0, B > 0
;                       41+573+5 = 619 clks             A < 0, B < 0
;			12 clks				A = 0
;
;       Min Timing:     27+536+5 = 568 clks             A > 0, B > 0
;                       34+536+23 = 593 clks            A > 0, B < 0
;                       31+536+23 = 593 clks            A < 0, B > 0
;                       41+536+5 = 582 clks             A < 0, B < 0
;
;       PM: 41+753+22+54 = 870             DM: 14
;

AARGB3		EQU		CEXreg
AARGB2		EQU		CEXreg+1
AARGB1		EQU		CEXreg+2
AARGB0		EQU		CEXreg+3

BARGB3		EQU		DEXreg
BARGB2		EQU		DEXreg+1
BARGB1		EQU		DEXreg+2
BARGB0		EQU		DEXreg+3

REMB3		EQU		EEXreg
REMB2		EQU		EEXreg+1
REMB1		EQU		EEXreg+2
REMB0		EQU		EEXreg+3

;**********************************************************************************************
;
;       32/32 Bit Division Macros
;
SDIV3232        macro
;
;       Max Timing:     9+14+30*18+10 = 573 clks
;
;       Min Timing:     9+14+30*17+3 = 536 clks
;
;       PM: 9+14+30*24+10 = 753         DM: 12
;
                variable i

                MOVFP           BARGB3,WREG
                SUBWF           REMB3, F
                MOVFP           BARGB2,WREG
                SUBWFB          REMB2, F
                MOVFP           BARGB1,WREG
                SUBWFB          REMB1, F
                MOVFP           BARGB0,WREG
                SUBWFB          REMB0, F
                RLCF            AARGB0, F

                RLCF            AARGB0,W
                RLCF            REMB3, F
                RLCF            REMB2, F
                RLCF            REMB1, F
                RLCF            REMB0, F
                MOVFP           BARGB3,WREG
                ADDWF           REMB3, F
                MOVFP           BARGB2,WREG
                ADDWFC          REMB2, F
                MOVFP           BARGB1,WREG
                ADDWFC          REMB1, F
                MOVFP           BARGB0,WREG
                ADDWFC          REMB0, F
                RLCF            AARGB0, F

                variable i = D'2'

                while i < D'8'

                RLCF            AARGB0,W
                RLCF            REMB3, F
                RLCF            REMB2, F
                RLCF            REMB1, F
                RLCF            REMB0, F
                MOVFP           BARGB3,WREG
                BTFSS           AARGB0,LSB
                GOTO            SADD22#v(i)
                SUBWF           REMB3, F
                MOVFP           BARGB2,WREG
                SUBWFB          REMB2, F
                MOVFP           BARGB1,WREG
                SUBWFB          REMB1, F
                MOVFP           BARGB0,WREG
                SUBWFB          REMB0, F
                GOTO            SOK22#v(i)

SADD22#v(i)     ADDWF           REMB3, F
                MOVFP           BARGB2,WREG
                ADDWFC          REMB2, F
                MOVFP           BARGB1,WREG
                ADDWFC          REMB1, F
                MOVFP           BARGB0,WREG
                ADDWFC          REMB0, F

SOK22#v(i)      RLCF            AARGB0, F

                variable i=i+1

                endw

                RLCF            AARGB1,W
                RLCF            REMB3, F
                RLCF            REMB2, F
                RLCF            REMB1, F
                RLCF            REMB0, F
                MOVFP           BARGB3,WREG
                BTFSS           AARGB0,LSB
                GOTO            SADD228
                SUBWF           REMB3, F
                MOVFP           BARGB2,WREG
                SUBWFB          REMB2, F
                MOVFP           BARGB1,WREG
                SUBWFB          REMB1, F
                MOVFP           BARGB0,WREG
                SUBWFB          REMB0, F
                GOTO            SOK228

SADD228         ADDWF           REMB3, F
                MOVFP           BARGB2,WREG
                ADDWFC          REMB2, F
                MOVFP           BARGB1,WREG
                ADDWFC          REMB1, F
                MOVFP           BARGB0,WREG
                ADDWFC          REMB0, F

SOK228          RLCF            AARGB1, F

                variable i = D'9'

                while i < D'16'

                RLCF            AARGB1,W
                RLCF            REMB3, F
                RLCF            REMB2, F
                RLCF            REMB1, F
                RLCF            REMB0, F
                MOVFP           BARGB3,WREG
                BTFSS           AARGB1,LSB
                GOTO            SADD22#v(i)
                SUBWF           REMB3, F
                MOVFP           BARGB2,WREG
                SUBWFB          REMB2, F
                MOVFP           BARGB1,WREG
                SUBWFB          REMB1, F
                MOVFP           BARGB0,WREG
                SUBWFB          REMB0, F
                GOTO            SOK22#v(i)

SADD22#v(i)     ADDWF           REMB3, F
                MOVFP           BARGB2,WREG
                ADDWFC          REMB2, F
                MOVFP           BARGB1,WREG
                ADDWFC          REMB1, F
                MOVFP           BARGB0,WREG
                ADDWFC  	REMB0, F

SOK22#v(i)      RLCF            AARGB1, F

                variable i=i+1

                endw

                RLCF            AARGB2,W
                RLCF            REMB3, F
                RLCF            REMB2, F
                RLCF            REMB1, F
                RLCF            REMB0, F
                MOVFP           BARGB3,WREG
                BTFSS           AARGB1,LSB
                GOTO            SADD2216
                SUBWF           REMB3, F
                MOVFP           BARGB2,WREG
                SUBWFB          REMB2, F
                MOVFP           BARGB1,WREG
                SUBWFB          REMB1, F
                MOVFP           BARGB0,WREG
                SUBWFB          REMB0, F
                GOTO            SOK2216

SADD2216        ADDWF           REMB3, F
                MOVFP           BARGB2,WREG
                ADDWFC          REMB2, F
                MOVFP           BARGB1,WREG
                ADDWFC          REMB1, F
                MOVFP           BARGB0,WREG
                ADDWFC          REMB0, F

SOK2216         RLCF            AARGB2, F


                variable i = D'17'

                while i < D'24'

                RLCF            AARGB2,W
                RLCF            REMB3, F
                RLCF            REMB2, F
                RLCF            REMB1, F
                RLCF            REMB0, F
                MOVFP           BARGB3,WREG
                BTFSS           AARGB2,LSB
                GOTO            SADD22#v(i)
                SUBWF           REMB3, F
                MOVFP           BARGB2,WREG
                SUBWFB          REMB2, F
                MOVFP           BARGB1,WREG
                SUBWFB          REMB1, F
                MOVFP           BARGB0,WREG
                SUBWFB          REMB0, F
                GOTO            SOK22#v(i)

SADD22#v(i)     ADDWF           REMB3, F
                MOVFP           BARGB2,WREG
                ADDWFC          REMB2, F
                MOVFP           BARGB1,WREG
                ADDWFC          REMB1, F
                MOVFP           BARGB0,WREG
                ADDWFC          REMB0, F

SOK22#v(i)      RLCF            AARGB2, F

                variable i=i+1

                endw

                RLCF            AARGB3,W
                RLCF            REMB3, F
                RLCF            REMB2, F
                RLCF            REMB1, F
                RLCF            REMB0, F
                MOVFP           BARGB3,WREG
                BTFSS           AARGB2,LSB
                GOTO            SADD2224
                SUBWF           REMB3, F
                MOVFP           BARGB2,WREG
                SUBWFB  	REMB2, F
                MOVFP           BARGB1,WREG
                SUBWFB  	REMB1, F
                MOVFP           BARGB0,WREG
                SUBWFB  	REMB0, F
                GOTO            SOK2224

SADD2224        ADDWF           REMB3, F
                MOVFP           BARGB2,WREG
                ADDWFC  	REMB2, F
                MOVFP           BARGB1,WREG
                ADDWFC  	REMB1, F
                MOVFP           BARGB0,WREG
                ADDWFC  	REMB0, F

SOK2224         RLCF            AARGB3, F

                variable i = D'25'

                while i < D'32'

                RLCF            AARGB3,W
                RLCF            REMB3, F
                RLCF            REMB2, F
                RLCF            REMB1, F
                RLCF            REMB0, F
                MOVFP           BARGB3,WREG
                BTFSS           AARGB3,LSB
                GOTO            SADD22#v(i)
                SUBWF           REMB3, F
                MOVFP           BARGB2,WREG
                SUBWFB  	REMB2, F
                MOVFP           BARGB1,WREG
                SUBWFB  	REMB1, F
                MOVFP           BARGB0,WREG
                SUBWFB  	REMB0, F
                GOTO            SOK22#v(i)

SADD22#v(i)     ADDWF           REMB3, F
                MOVFP           BARGB2,WREG
                ADDWFC  	REMB2, F
                MOVFP           BARGB1,WREG
                ADDWFC  	REMB1, F
                MOVFP           BARGB0,WREG
                ADDWFC  	REMB0, F

SOK22#v(i)      RLCF            AARGB3, F

                variable i=i+1

                endw

                BTFSC           AARGB3,LSB
                GOTO            SOK22
                MOVFP           BARGB3,WREG
                ADDWF           REMB3, F
                MOVFP           BARGB2,WREG
                ADDWFC  	REMB2, F
                MOVFP           BARGB1,WREG
                ADDWFC  	REMB1, F
                MOVFP           BARGB0,WREG
                ADDWFC  	REMB0, F
SOK22

                endm

; *********************************************************************
; *********************************************************************
; 32/32 signed divide....
;
;	CEXreg.EEXreg = CEXreg/DEXreg
; *********************************************************************
; *********************************************************************

Divide3232
FXD3232S	CLRF		SIGN,F
                CLRF            REMB0,F			; clear partial remainder
		CLRF		REMB1,F
		CLRF		REMB2,F
		CLRF		REMB3,F
		MOVFP		AARGB0,WREG
		IORWF		AARGB1,W
		IORWF		AARGB2,W
		IORWF		AARGB3,W
		BTFSC		_Z
		RETLW		0x00

		MOVFP		AARGB0,WREG
		XORWF		BARGB0,W
		BTFSC		WREG,MSB
		COMF		SIGN,F

		CLRF		TEMPB3,W		; clear exception flag

                BTFSS           BARGB0,MSB        ; if MSB set, negate BARG
                GOTO            CA3232S

                COMF            BARGB3, F
                COMF            BARGB2, F
                COMF            BARGB1, F
                COMF            BARGB0, F
                INCF            BARGB3, F
                ADDWFC  	BARGB2, F
                ADDWFC  	BARGB1, F
                ADDWFC  	BARGB0, F

CA3232S         BTFSS           AARGB0,MSB        ; if MSB set, negate AARG
                GOTO            C3232SX

                COMF            AARGB3, F
                COMF            AARGB2, F
                COMF            AARGB1, F
                COMF            AARGB0, F
                INCF            AARGB3, F
                ADDWFC  	AARGB2, F
                ADDWFC  	AARGB1, F
                ADDWFC  	AARGB0, F

C3232SX		MOVFP		AARGB0,WREG
		IORWF		BARGB0,W
		BTFSC		WREG,MSB
		GOTO		C3232SX1

C3232S          SDIV3232

		BTFSC		TEMPB3,LSB		; test exception flag
		GOTO		C3232SX4

C3232SOK        BTFSS           SIGN,MSB
                RETLW           0x00

                COMF            AARGB3, F
                COMF            AARGB2, F
                COMF            AARGB1, F
                COMF            AARGB0, F
                CLRF            WREG, F
                INCF            AARGB3, F
                ADDWFC  	AARGB2, F
                ADDWFC  	AARGB1, F
                ADDWFC  	AARGB0, F

                COMF            REMB3, F
                COMF            REMB2, F
                COMF            REMB1, F
                COMF            REMB0, F
                INCF            REMB3, F
                ADDWFC  	REMB2, F
                ADDWFC  	REMB1, F
                ADDWFC  	REMB0, F

                RETLW           0x00

C3232SX1	BTFSS		BARGB0,MSB		; test BARG exception
		GOTO		C3232SX3
		BTFSC		AARGB0,MSB		; test AARG exception
		GOTO		C3232SX2
		MOVFP		AARGB0,WREG		; quotient = 0, remainder = AARG
		MOVPF		WREG,REMB0
		MOVFP		AARGB1,WREG
		MOVPF		WREG,REMB1
		MOVFP		AARGB2,WREG
		MOVPF		WREG,REMB2
		MOVFP		AARGB3,WREG
		MOVPF		WREG,REMB3
		CLRF		AARGB0,F
		CLRF		AARGB1,F
		CLRF		AARGB2,F
		CLRF		AARGB3,F
		GOTO		C3232SOK
C3232SX2	CLRF		AARGB0,F		; quotient = 1, remainder = 0
		CLRF		AARGB1,F
		CLRF		AARGB2,F
		CLRF		AARGB3,F
		INCF		AARGB3,F
		RETLW		0x00

C3232SX3	COMF		AARGB0,F		; numerator = 0x7FFFFFFF + 1
		COMF		AARGB1,F
		COMF		AARGB2,F
		COMF		AARGB3,F
		INCF		TEMPB3,F
		GOTO		C3232S

C3232SX4	INCF		REMB3,F			; increment remainder and test for
		CLRF		WREG,F			; overflow
		ADDWFC		REMB2,F
		ADDWFC		REMB1,F
		ADDWFC		REMB0,F
		MOVFP		BARGB3,WREG
		CPFSEQ		REMB3
		GOTO		C3232SOK
		MOVFP		BARGB2,WREG
		CPFSEQ		REMB2
		GOTO		C3232SOK
		MOVFP		BARGB1,WREG
		CPFSEQ		REMB1
		GOTO		C3232SOK
		MOVFP		BARGB0,WREG
		CPFSEQ		REMB0
		GOTO		C3232SOK
		CLRF		REMB0,F			; if remainder overflow, clear
		CLRF		REMB1,F			; remainder, increment quotient and
		CLRF		REMB2,F
		CLRF		REMB3,W
		INCF		AARGB3,F		; test for overflow exception
		ADDWFC		AARGB2,F
		ADDWFC		AARGB1,F
		ADDWFC		AARGB0,F
		BTFSS		AARGB0,MSB
		GOTO		C3232SOK
		BSF		FPFLAGS,NAN
		RETLW		0xFF


