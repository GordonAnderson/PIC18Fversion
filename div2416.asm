
#define	AARGB2		CEXreg
#define	AARGB1		CEXreg+1
#define	AARGB0		CEXreg+2

#define	BARGB1		DEXreg
#define	BARGB0		DEXreg+1

#define	REMB1		EEXreg
#define	REMB0		EEXreg+1

;**********************************************************************************************
;
;       24/16 Bit Division Macros
;
SDIV2416        macro
;
;       Max Timing:     5+8+22*12+6 = 283 clks
;
;       Min Timing:     5+8+22*11+3 = 258 clks
;
;       PM: 5+8+22*14+6 = 327           DM: 8
;
                variable i

                MOVFP           BARGB1,WREG
                SUBWF           REMB1, F
                MOVFP           BARGB0,WREG
                SUBWFB          REMB0, F
                RLCF            AARGB0, F

                RLCF            AARGB0,W
                RLCF            REMB1, F
                RLCF            REMB0, F
                MOVFP           BARGB1,WREG
                ADDWF           REMB1, F
                MOVFP           BARGB0,WREG
                ADDWFC          REMB0, F
                RLCF            AARGB0, F

                variable i = D'2'

                while i < D'8'

                RLCF            AARGB0,W
                RLCF            REMB1, F
                RLCF            REMB0, F
                MOVFP           BARGB1,WREG
                BTFSS           AARGB0,LSB
                GOTO            SADD46#v(i)
                SUBWF           REMB1, F
                MOVFP           BARGB0,WREG
                SUBWFB          REMB0, F
                GOTO            SOK46#v(i)

SADD46#v(i)     ADDWF           REMB1, F
                MOVFP           BARGB0,WREG
                ADDWFC          REMB0, F

SOK46#v(i)      RLCF            AARGB0, F

                variable i=i+1

                endw

                RLCF            AARGB1,W
                RLCF            REMB1, F
                RLCF            REMB0, F
                MOVFP           BARGB1,WREG
                BTFSS           AARGB0,LSB
                GOTO            SADD468
                SUBWF           REMB1, F
                MOVFP           BARGB0,WREG
                SUBWFB          REMB0, F
                GOTO            SOK468

SADD468         ADDWF           REMB1, F
                MOVFP           BARGB0,WREG
                ADDWFC          REMB0, F

SOK468          RLCF            AARGB1, F

                variable i = D'9'

                while i < D'16'

                RLCF            AARGB1,W
                RLCF            REMB1, F
                RLCF            REMB0, F
                MOVFP           BARGB1,WREG
                BTFSS           AARGB1,LSB
                GOTO            SADD46#v(i)
                SUBWF           REMB1, F
                MOVFP           BARGB0,WREG
                SUBWFB          REMB0, F
                GOTO            SOK46#v(i)

SADD46#v(i)     ADDWF           REMB1, F
                MOVFP           BARGB0,WREG
                ADDWFC          REMB0, F

SOK46#v(i)      RLCF            AARGB1, F

                variable i=i+1

                endw

                RLCF            AARGB2,W
                RLCF            REMB1, F
                RLCF            REMB0, F
                MOVFP           BARGB1,WREG
                BTFSS           AARGB1,LSB
                GOTO            SADD4616
                SUBWF           REMB1, F
                MOVFP           BARGB0,WREG
                SUBWFB          REMB0, F
                GOTO            SOK4616

SADD4616        ADDWF           REMB1, F
                MOVFP           BARGB0,WREG
                ADDWFC          REMB0, F

SOK4616         RLCF            AARGB2, F


                variable i = D'17'

                while i < D'24'

                RLCF            AARGB2,W
                RLCF            REMB1, F
                RLCF            REMB0, F
                MOVFP           BARGB1,WREG
                BTFSS           AARGB2,LSB
                GOTO            SADD46#v(i)
                SUBWF           REMB1, F
                MOVFP           BARGB0,WREG
                SUBWFB          REMB0, F
                GOTO            SOK46#v(i)

SADD46#v(i)     ADDWF           REMB1, F
                MOVFP           BARGB0,WREG
                ADDWFC          REMB0, F

SOK46#v(i)      RLCF            AARGB2, F

                variable i=i+1

                endw

                BTFSC           AARGB2,LSB
                GOTO            SOK46
                MOVFP           BARGB1,WREG
                ADDWF           REMB1, F
                MOVFP           BARGB0,WREG
                ADDWFC          REMB0, F
SOK46

                endm


;**********************************************************************************************
;**********************************************************************************************
;
;       24/16 Bit Signed Fixed Point Divide 24/16 -> 24.16
;
;       Input:  24 bit fixed point dividend in AARGB0, AARGB1, AARGB2
;               16 bit fixed point divisor in BARGB0, BARGB1
;
;       Use:    CALL    FXD2416S
;
;       Output: 24 bit fixed point quotient in AARGB0, AARGB1, AARGB2
;               16 bit fixed point remainder in REMB0, REMB1
;
;       Result: AARG, REM  <--  AARG / BARG
;
;       Max Timing:     23+283+5 = 311 clks             A > 0, B > 0
;                       26+283+17 = 326 clks            A > 0, B < 0
;                       28+283+17 = 328 clks            A < 0, B > 0
;                       31+283+5 = 319 clks             A < 0, B < 0
;			9 clks				A = 0
;
;       Min Timing:     23+258+5 = 286 clks             A > 0, B > 0
;                       26+258+17 = 301 clks            A > 0, B < 0
;                       28+258+17 = 303 clks            A < 0, B > 0
;                       31+258+5 = 294 clks             A < 0, B < 0
;
;       PM: 30+327+16+41 = 414             DM: 9
;

Divide2416
FXD2416S
		MOVLR		HIGH AXreg
		CLRF		SIGN
                CLRF            REMB0			; clear partial remainder
		CLRF		REMB1
		MOVFP		AARGB0,W
		IORWF		AARGB1,W
		IORWF		AARGB2,W
		BTFSC		_Z
		RETLW		0x00

		MOVFP		AARGB0,W
		XORWF		BARGB0,W
		BTFSC		WREG,MSB,A
		COMF		SIGN,F

		CLRF		TEMPB3			; clear exception flag
		MOVLW		0

                BTFSS           BARGB0,MSB        	; if MSB set go & negate BARG
                GOTO            CA2416S

                COMF            BARGB1, F
                COMF            BARGB0, F
                INCF            BARGB1, F
                ADDWFC          BARGB0, F

CA2416S         BTFSS           AARGB0,MSB        	; if MSB set go & negate AARGa
                GOTO            C2416SX

                COMF            AARGB2, F
                COMF            AARGB1, F
                COMF            AARGB0, F
                INCF            AARGB2, F
                ADDWFC          AARGB1, F
                ADDWFC          AARGB0, F

C2416SX		MOVFP		AARGB0,W
		IORWF		BARGB0,W
		BTFSC		WREG,MSB,A
		GOTO		C2416SX1

C2416S          SDIV2416

		BTFSC		TEMPB3,LSB		; test exception flag
		GOTO		C2416SX4

C2416SOK        BTFSS           SIGN,MSB        	; negate
                RETLW           0x00

                COMF            AARGB2, F
                COMF            AARGB1, F
                COMF            AARGB0, F
                MOVLW		0
                INCF            AARGB2, F
                ADDWFC          AARGB1, F
                ADDWFC          AARGB0, F

                COMF            REMB1, F
                COMF            REMB0, F
                INCF            REMB1, F
                ADDWFC          REMB0, F

                RETLW           0x00

C2416SX1	BTFSS		BARGB0,MSB		; test BARG exception
		GOTO		C2416SX3
		BTFSC		AARGB0,MSB		; test AARG exception
		GOTO		C2416SX2
		MOVPF		WREG,Ctemp
		MOVFP		AARGB1,W
		MOVPF		WREG,REMB0
		MOVFP		AARGB2,W
		MOVPF		WREG,REMB1
		BCF		REMB0,MSB
		RLCF		AARGB1,F
		RLCF		AARGB0,F
		MOVFP		AARGB0,W
		MOVPF		WREG,AARGB2
		MOVFP		Ctemp,W
		CLRF		AARGB0
		CLRF		AARGB1
		GOTO		C2416SOK
C2416SX2	CLRF		AARGB2		; quotient = 1, remainder = 0
		INCF		AARGB2,F
		CLRF		AARGB1
		CLRF		AARGB0
		RETLW		0x00

C2416SX3	COMF		AARGB0,F		; numerator = 0x7FFFFF + 1
		COMF		AARGB1,F
		COMF		AARGB2,F
		INCF		TEMPB3,F
		GOTO		C2416S

C2416SX4	INCF		REMB1,F			; increment remainder and test for
		CLRF		WREG
		ADDWFC		REMB0,F
		MOVFP		BARGB1,W		; overflow
		CPFSEQ		REMB1
		GOTO		C2416SOK
		MOVFP		BARGB0,W		; overflow
		CPFSEQ		REMB0
		GOTO		C2416SOK
		CLRF		REMB0			; if remainder overflow, clear
		CLRF		REMB1
		MOVLW		0
		INCF		AARGB2,F		; remainder, increment quotient and
		ADDWFC		AARGB1,F		; test for overflow exception
		ADDWFC		AARGB0,F
		BTFSS		AARGB0,MSB
		GOTO		C2416SOK
		BSF		FPFLAGS,NAN
		RETLW		0xFF
		
