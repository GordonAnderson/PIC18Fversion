#define	_C		ALUSTA,0
#define	_DC		ALUSTA,1
#define	_Z		ALUSTA,2
#define	_OV		ALUSTA,3

MSB		equ	7
LSB		equ	0
NAN		equ	4	; bit4 = not-a-number exception flag


;
; Math functions...
;
; This routine does a 16x16 multiply with a 32 bit result.
;  CEXreg = AXreg * BXreg
;
; Numbers are saved in intel order LS first
;
Mult1616
	; First do the unsigned multiply
		CALL 	Mult1616u
	; Test sign of BXreg correct if neg
		BTFSS	BXreg+1,7
		GOTO	Mult1
		MOVFP	AXreg,W
		SUBWF	CEXreg+2
		MOVFP	AXreg+1,W
		SUBWFB	CEXreg+3
Mult1
	; Test sign of AXreg correct if neg
		BTFSS	AXreg+1,7
		GOTO	Mult2
		MOVFP	BXreg,W
		SUBWF	CEXreg+2
		MOVFP	BXreg+1,W
		SUBWFB	CEXreg+3
Mult2
	; Done!	
		RETURN
;
; Unsigned 16x16 multiply
;
; This routine does a 16x16 multiply with a 32 bit result.
;  CEXreg = AXreg * BXreg
;
; Numbers are saved in intel order LS first
;
Mult1616u
		MOVLR	HIGH AXreg
		CLRF	CEXreg
		CLRF	CEXreg+1
		CLRF	CEXreg+2
		CLRF	CEXreg+3
	; LSB of BX times LSB of AX
		MOVFP	BXreg,W
		MULWF	AXreg
		MOVPF	PRODL,CEXreg
		MOVPF	PRODH,CEXreg+1
	; LSB of BX times MSB of AX
		MOVFP	BXreg,W
		MULWF	AXreg+1
		MOVFP	PRODL,W
		ADDWF	CEXreg+1
		MOVFP	PRODH,W
		ADDWFC	CEXreg+2
		BTFSC	ALUSTA,C,A
		INCF	CEXreg+3
	; MSB of BX times LSB of AX
		MOVFP	BXreg+1,W
		MULWF	AXreg
		MOVFP	PRODL,W
		ADDWF	CEXreg+1
		MOVFP	PRODH,W
		ADDWFC	CEXreg+2
		BTFSC	ALUSTA,C,A
		INCF	CEXreg+3
	; MSB of BX times MSB of AX
		MOVFP	BXreg+1,W
		MULWF	AXreg+1
		MOVFP	PRODL,W
		ADDWF	CEXreg+2
		MOVFP	PRODH,W
		ADDWFC	CEXreg+3
	; Done!	
		RETURN

;**********************************************************************************************
;**********************************************************************************************
;
;       16/08 BIT Division Macros
;
SDIV1608        macro
;
;       Max Timing:     3+5+14*8+2 = 122 clks
;
;       Min Timing:     3+5+14*8+2 = 122 clks
;
;       PM: 3+5+14*8+2 = 122            DM: 4
;
                variable i

                MOVFP           DEXreg,WREG
                SUBWF           EEXreg, F
                RLCF            CEXreg+1, F

                RLCF            CEXreg+1,W
                RLCF            EEXreg, F
                MOVFP           DEXreg,WREG
                ADDWF           EEXreg, F
                RLCF            CEXreg+1, F

                variable i = D'2'

                while i < D'8'

                RLCF            CEXreg+1,W
                RLCF            EEXreg, F
                MOVFP           DEXreg,WREG

                BTFSC           CEXreg+1,LSB
                SUBWF           EEXreg, F
                BTFSS           CEXreg+1,LSB
                ADDWF           EEXreg, F
                RLCF            CEXreg+1, F

                variable i=i+1

                endw

                RLCF            CEXreg,W
                RLCF            EEXreg, F
                MOVFP           DEXreg,WREG

                BTFSC           CEXreg+1,LSB
                SUBWF           EEXreg, F
                BTFSS           CEXreg+1,LSB
                ADDWF           EEXreg, F
                RLCF            CEXreg, F

                variable i = D'9'

                while i < D'16'

                RLCF            CEXreg,W
                RLCF            EEXreg, F
                MOVFP           DEXreg,WREG

                BTFSC           CEXreg,LSB
                SUBWF           EEXreg, F
                BTFSS           CEXreg,LSB
                ADDWF           EEXreg, F
                RLCF            CEXreg, F

                variable i=i+1

                endw

                BTFSS           CEXreg,LSB
                ADDWF           EEXreg, F

                endm

;**********************************************************************************************
;**********************************************************************************************
;
;       16/8 Bit Signed Fixed Point Divide 16/08 -> 16.08
;
;       Input:  16 bit fixed point dividend in CEXreg+1, CEXreg
;               8 bit fixed point divisor in DEXreg
;
;       Use:    CALL    FXD1608S
;
;       Output: 16 bit fixed point quotient in CEXreg+1, CEXreg
;               8 bit fixed point remainder in EEXreg
;
;       Result: AARG, REM  <--  AARG / BARG
;
;       Max Timing:     21+122+5 = 148 clks             A > 0, B > 0
;                       22+122+13 = 157 clks            A > 0, B < 0
;                       24+122+13 = 159 clks            A < 0, B > 0
;                       25+122+5 = 152 clks             A < 0, B < 0
;			7 clks				A = 0
;
;       Min Timing:     21+122+5 = 148 clks             A > 0, B > 0
;                       22+122+13 = 157 clks            A > 0, B < 0
;                       24+122+13 = 159 clks            A < 0, B > 0
;                       25+122+5 = 152 clks             A < 0, B < 0
;
;       PM: 25+122+12+30 = 189             DM: 6
;
Divide168
FXD1608S
		MOVLR		HIGH CEXreg
		CLRF		SIGN
                CLRF            EEXreg			; clear partial remainder
		MOVFP		CEXreg+1,WREG
		IORWF		CEXreg,W
		BTFSC		_Z
		RETLW		0x00

		MOVFP		CEXreg+1,WREG
		XORWF		DEXreg,W
		BTFSC		WREG,MSB
		COMF		SIGN,F

		CLRF		TEMPB3			; clear exception flag
		MOVLW		0

                BTFSS           DEXreg,MSB             ; if MSB set go & negate BARG
                GOTO            CA1608S

                COMF            DEXreg, F
                INCF            DEXreg, F

CA1608S         BTFSS           CEXreg+1,MSB             ; if MSB set go & negate AARGa
                GOTO            C1608SX

                COMF            CEXreg, F
                COMF            CEXreg+1, F
                INCF            CEXreg, F
                ADDWFC  	CEXreg+1, F

C1608SX		MOVFP		CEXreg+1,WREG
		IORWF		DEXreg,W
		BTFSC		WREG,MSB
		GOTO		C1608SX1

C1608S          SDIV1608

		BTFSC		TEMPB3,LSB		; test exception flag
		GOTO		C1608SX4

C1608SOK	BTFSS           SIGN,MSB                ; negate 
                RETLW           0x00

                COMF            CEXreg, F
                COMF            CEXreg+1, F
                CLRF            WREG
                INCF            CEXreg, F
                ADDWFC  	CEXreg+1, F

                COMF            EEXreg, F
                INCF            EEXreg, F

                RETLW           0x00

C1608SX1	BTFSS		DEXreg,MSB		; test BARG exception
		GOTO		C1608SX3
		BTFSC		CEXreg+1,MSB		; test AARG exception
		GOTO		C1608SX2
		MOVPF		WREG,Ctemp
		MOVFP		CEXreg,WREG
		MOVPF		WREG,EEXreg
		BCF		EEXreg,MSB
		RLCF		CEXreg,F
		RLCF		CEXreg+1,F
		MOVFP		CEXreg+1,WREG
		MOVPF		WREG,CEXreg
		MOVFP		Ctemp,WREG
		CLRF		CEXreg+1
		GOTO		C1608SOK
C1608SX2	CLRF		CEXreg		; quotient = 1, remainder = 0
		INCF		CEXreg,F
		CLRF		CEXreg+1
		RETLW		0x00

C1608SX3	COMF		CEXreg+1,F		; numerator = 0x7FFF + 1
		COMF		CEXreg,F
		INCF		TEMPB3,F
		GOTO		C1608S

C1608SX4	INCF		EEXreg,F		; increment remainder and test for
		MOVFP		DEXreg,WREG		; overflow
		CPFSEQ		EEXreg
		GOTO		C1608SOK
		CLRF		EEXreg			; if remainder overflow, clear
		MOVLW		0
		INCF		CEXreg,F		; remainder, increment quotient and
		ADDWFC		CEXreg+1,F		; test for overflow exception
		BTFSS		CEXreg+1,MSB
		GOTO		C1608SOK
		BSF		FPFLAGS,NAN
		RETLW		0xFF
		


INCLUDE		<DIV2416.ASM>
INCLUDE		<DIV3232U.ASM>
