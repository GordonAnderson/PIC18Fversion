
#define	TEMP	TEMPB3

NDIV3232        macro

;       Max Timing:     16+31*21+10 = 677 clks
;
;       Min Timing: 16+31*20+3 = 639 clks
;
;       PM: 16+31*29+10 = 925           DM: 13
;
                variable i

                RLCF            CEXreg+3,W
                RLCF            EEXreg, F
                RLCF            EEXreg+1, F
                RLCF            EEXreg+2, F
                RLCF            EEXreg+3, F
                MOVFP           DEXreg,WREG
                SUBWF           EEXreg, F
                MOVFP           DEXreg+1,WREG
                SUBWFB  	EEXreg+1, F
                MOVFP           DEXreg+2,WREG
                SUBWFB  	EEXreg+2, F
                MOVFP           DEXreg+3,WREG
                SUBWFB  	EEXreg+3, F
                CLRF            TEMP
                SUBWFB  	TEMP, F
                RLCF            CEXreg+3, F

                variable i = D'1'

                while i < D'8'

                RLCF            CEXreg+3,W
                RLCF            EEXreg, F
                RLCF            EEXreg+1, F
                RLCF            EEXreg+2, F
                RLCF            EEXreg+3, F
                RLCF            TEMP, F
                MOVFP           DEXreg,WREG
                BTFSS           CEXreg+3,LSB
                GOTO            NADD22#v(i)
                SUBWF           EEXreg, F
                MOVFP           DEXreg+1,WREG
                SUBWFB  	EEXreg+1, F
                MOVFP           DEXreg+2,WREG
                SUBWFB  	EEXreg+2, F
                MOVFP           DEXreg+3,WREG
                SUBWFB  	EEXreg+3, F
                CLRF            WREG
                SUBWFB  	TEMP, F
                GOTO            NOK22#v(i)

NADD22#v(i)     ADDWF           EEXreg, F
                MOVFP           DEXreg+1,WREG
                ADDWFC  	EEXreg+1, F
                MOVFP           DEXreg+2,WREG
                ADDWFC  	EEXreg+2, F
                MOVFP           DEXreg+3,WREG
                ADDWFC  	EEXreg+3, F
                CLRF            WREG
                ADDWFC  	TEMP, F
        
NOK22#v(i)      RLCF            CEXreg+3, F

                variable i=i+1

                endw

                RLCF            CEXreg+2,W
                RLCF            EEXreg, F
                RLCF            EEXreg+1, F
                RLCF            EEXreg+2, F
                RLCF            EEXreg+3, F
                RLCF            TEMP, F
                MOVFP           DEXreg,WREG
                BTFSS           CEXreg+3,LSB
                GOTO            NADD228
                SUBWF           EEXreg, F
                MOVFP           DEXreg+1,WREG
                SUBWFB  	EEXreg+1, F
                MOVFP           DEXreg+2,WREG
                SUBWFB  	EEXreg+2, F
                MOVFP           DEXreg+3,WREG
                SUBWFB  	EEXreg+3, F
                CLRF            WREG
                SUBWFB  	TEMP, F
                GOTO            NOK228

NADD228         ADDWF           EEXreg, F
                MOVFP           DEXreg+1,WREG
                ADDWFC  	EEXreg+1, F
                MOVFP           DEXreg+2,WREG
                ADDWFC  	EEXreg+2, F
                MOVFP           DEXreg+3,WREG
                ADDWFC  	EEXreg+3, F
                CLRF            WREG
                ADDWFC  	TEMP, F
        
NOK228          RLCF            CEXreg+2, F

                variable i = D'9'

                while i < D'16'

                RLCF            CEXreg+2,W
                RLCF            EEXreg, F
                RLCF            EEXreg+1, F
                RLCF            EEXreg+2, F
                RLCF            EEXreg+3, F
                RLCF            TEMP, F
                MOVFP           DEXreg,WREG
                BTFSS           CEXreg+2,LSB
                GOTO            NADD22#v(i)
                SUBWF           EEXreg, F
                MOVFP           DEXreg+1,WREG
                SUBWFB  	EEXreg+1, F
                MOVFP           DEXreg+2,WREG
                SUBWFB  	EEXreg+2, F
                MOVFP           DEXreg+3,WREG
                SUBWFB  	EEXreg+3, F
                CLRF            WREG
                SUBWFB  	TEMP, F
                GOTO            NOK22#v(i)

NADD22#v(i)     ADDWF           EEXreg, F
                MOVFP           DEXreg+1,WREG
                ADDWFC  	EEXreg+1, F
                MOVFP           DEXreg+2,WREG
                ADDWFC  	EEXreg+2, F
                MOVFP           DEXreg+3,WREG
                ADDWFC  	EEXreg+3, F
                CLRF            WREG
                ADDWFC  	TEMP, F
        
NOK22#v(i)      RLCF            CEXreg+2, F

                variable i=i+1

                endw

                RLCF            CEXreg+1,W
                RLCF            EEXreg, F
                RLCF            EEXreg+1, F
                RLCF            EEXreg+2, F
                RLCF            EEXreg+3, F
                RLCF            TEMP, F
                MOVFP           DEXreg,WREG
                BTFSS           CEXreg+2,LSB
                GOTO            NADD2216
                SUBWF           EEXreg, F
                MOVFP           DEXreg+1,WREG
                SUBWFB  	EEXreg+1, F
                MOVFP           DEXreg+2,WREG
                SUBWFB  	EEXreg+2, F
                MOVFP           DEXreg+3,WREG
                SUBWFB  	EEXreg+3, F
                CLRF            WREG
                SUBWFB  	TEMP, F
                GOTO            NOK2216

NADD2216        ADDWF           EEXreg, F
                MOVFP           DEXreg+1,WREG
                ADDWFC  	EEXreg+1, F
                MOVFP           DEXreg+2,WREG
                ADDWFC  	EEXreg+2, F
                MOVFP           DEXreg+3,WREG
                ADDWFC  	EEXreg+3, F
                CLRF            WREG
                ADDWFC  	TEMP, F
        
NOK2216         RLCF            CEXreg+1, F

                variable i = D'17'

                while i < D'24'

                RLCF            CEXreg+1,W
                RLCF            EEXreg, F
                RLCF            EEXreg+1, F
                RLCF            EEXreg+2, F
                RLCF            EEXreg+3, F
                RLCF            TEMP, F
                MOVFP           DEXreg,WREG
                BTFSS           CEXreg+1,LSB
                GOTO            NADD22#v(i)
                SUBWF           EEXreg, F
                MOVFP           DEXreg+1,WREG
                SUBWFB  	EEXreg+1, F
                MOVFP           DEXreg+2,WREG
                SUBWFB  	EEXreg+2, F
                MOVFP           DEXreg+3,WREG
                SUBWFB  	EEXreg+3, F
                CLRF            WREG
                SUBWFB  	TEMP, F
                GOTO            NOK22#v(i)

NADD22#v(i)     ADDWF           EEXreg, F
                MOVFP           DEXreg+1,WREG
                ADDWFC  	EEXreg+1, F
                MOVFP           DEXreg+2,WREG
                ADDWFC  	EEXreg+2, F
                MOVFP           DEXreg+3,WREG
                ADDWFC  	EEXreg+3, F
                CLRF            WREG
                ADDWFC  	TEMP, F
        
NOK22#v(i)      RLCF            CEXreg+1, F

                variable i=i+1

                endw

                RLCF            CEXreg,W
                RLCF            EEXreg, F
                RLCF            EEXreg+1, F
                RLCF            EEXreg+2, F
                RLCF            EEXreg+3, F
                RLCF            TEMP, F
                MOVFP           DEXreg,WREG
                BTFSS           CEXreg+1,LSB
                GOTO            NADD2224
                SUBWF           EEXreg, F
                MOVFP           DEXreg+1,WREG
                SUBWFB  	EEXreg+1, F
                MOVFP           DEXreg+2,WREG
                SUBWFB  	EEXreg+2, F
                MOVFP           DEXreg+3,WREG
                SUBWFB  	EEXreg+3, F
                CLRF            WREG
                SUBWFB  	TEMP, F
                GOTO            NOK2224

NADD2224        ADDWF           EEXreg, F
                MOVFP           DEXreg+1,WREG
                ADDWFC  	EEXreg+1, F
                MOVFP           DEXreg+2,WREG
                ADDWFC  	EEXreg+2, F
                MOVFP           DEXreg+3,WREG
                ADDWFC  	EEXreg+3, F
                CLRF            WREG
                ADDWFC  	TEMP, F
        
NOK2224         RLCF            CEXreg, F

                variable i = D'25'

                while i < D'32'

                RLCF            CEXreg,W
                RLCF            EEXreg, F
                RLCF            EEXreg+1, F
                RLCF            EEXreg+2, F
                RLCF            EEXreg+3, F
                RLCF            TEMP, F
                MOVFP           DEXreg,WREG
                BTFSS           CEXreg,LSB
                GOTO            NADD22#v(i)
                SUBWF           EEXreg, F
                MOVFP           DEXreg+1,WREG
                SUBWFB  	EEXreg+1, F
                MOVFP           DEXreg+2,WREG
                SUBWFB  	EEXreg+2, F
                MOVFP           DEXreg+3,WREG
                SUBWFB  	EEXreg+3, F
                CLRF            WREG
                SUBWFB  	TEMP, F
                GOTO            NOK22#v(i)

NADD22#v(i)     ADDWF           EEXreg, F
                MOVFP           DEXreg+1,WREG
                ADDWFC  	EEXreg+1, F
                MOVFP           DEXreg+2,WREG
                ADDWFC  	EEXreg+2, F
                MOVFP           DEXreg+3,WREG
                ADDWFC  	EEXreg+3, F
                CLRF            WREG
                ADDWFC  	TEMP, F
        
NOK22#v(i)      RLCF            CEXreg, F

                variable i=i+1

                endw

                BTFSC           CEXreg,LSB
                GOTO            NOK22
                MOVFP           DEXreg,WREG
                ADDWF           EEXreg, F
                MOVFP           DEXreg+1,WREG
                ADDWFC  	EEXreg+1, F
                MOVFP           DEXreg+2,WREG
                ADDWFC  	EEXreg+2, F
                MOVFP           DEXreg+3,WREG
                ADDWFC  	EEXreg+3, F

NOK22
                endm


;**********************************************************************************************
;**********************************************************************************************
;
;       32/32 Bit Unsigned Fixed Point Divide 32/32 -> 32.32
;
;       Input:  32 bit unsigned fixed point dividend in CEXreg+3, CEXreg+2,CEXreg+1,CEXreg
;               32 bit unsigned fixed point divisor in DEXreg+3, DEXreg+2, DEXreg+1, DEXreg
;
;       Use:    CALL    FXD3232U
;
;       Output: 32 bit unsigned fixed point quotient in CEXreg+3, CEXreg+2,CEXreg+1,CEXreg
;               32 bit unsigned fixed point remainder in EEXreg+3, EEXreg+2, EEXreg+1, EEXreg
;
;       Result: AARG, REM  <--  AARG / BARG
;
;       Max Timing:     4+677+2 = 683 clks
;
;       Min Timing:     4+639+2 = 645 clks
;
;       PM: 4+925+1 = 930               DM: 13
;
Divide3232u
FXD3232U
		MOVLB		HIGH EEXreg
		CLRF            EEXreg+3
                CLRF            EEXreg+2
                CLRF            EEXreg+1
                CLRF            EEXreg

                NDIV3232

                RETLW           0x00
