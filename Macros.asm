;
; MACROS.asm
;
; This file contains the marcos used by the MicroStar application.
;
; Gordon Anderson
;
 
GOTOF		MACRO	ADDRS
		GOTO	ADDRS
		ENDM

CALLF		MACRO 	ADDRS
		CALL	(ADDRS)
		ENDM

CALLFL		MACRO 	ADDRS,VAL
		MOVLW	(VAL)
		CALL	(ADDRS)
		ENDM

CALLFW		MACRO 	ADDRS
		CALL	(ADDRS)
		ENDM

CALLFF		MACRO 	ADDRS,VAL
		MOVFP	(VAL),WREG
		CALL	(ADDRS)
		ENDM

PUSHREGS        MACRO                 ;macro for saving registers, used in high priority ISRs
            	MOVFF   ALUSTA,TEMP_ALUSTA
            	MOVFF   BSR,TEMP_BSR
            	MOVWF   TEMP_WREG
		MOVFF	PRODL, TEMP_PRODL
		MOVFF	PRODH, TEMP_PRODH
            	ENDM

POPREGS         MACRO                 ;macro for restoring registers, used in high priority ISRs
		MOVFF	TEMP_PRODL, PRODL
		MOVFF	TEMP_PRODH, PRODH
            	MOVF    TEMP_WREG,W
            	MOVFF   TEMP_BSR,BSR
            	MOVFF   TEMP_ALUSTA,ALUSTA
            	ENDM

PUSHREGSLOW     MACRO                 ;macro for saving registers, used in low priority ISRs
            	MOVFF   ALUSTA,TEMP_ALUSTA_L
            	MOVFF   WREG,TEMP_WREG_L
            	MOVFF   BSR,TEMP_BSR_L
		MOVFF	PRODL, TEMP_PRODL_L
		MOVFF	PRODH, TEMP_PRODH_L
            	ENDM


POPREGSLOW      MACRO                 ;macro for restoring registers, used in low priority ISRs
		MOVFF	TEMP_PRODL_L, PRODL
		MOVFF	TEMP_PRODH_L, PRODH
            	MOVFF   TEMP_BSR_L,BSR
            	MOVFF   TEMP_WREG_L,WREG
            	MOVFF   TEMP_ALUSTA_L,ALUSTA
            	ENDM

PrintMess   	MACRO   MESSAGE
		MOVLW	UPPER (MESSAGE)
		MOVWF	TBLPTRU,A
		MOVLW	HIGH (MESSAGE)
		MOVWF	TBLPTRH,A
		MOVLW	LOW (MESSAGE)
		MOVWF	TBLPTRL,A
		CALL	LCDsendMess
	    	ENDM

PrintMessN   	MACRO   MESSAGE
		MOVFF	WREG,Areg
		MOVLW	UPPER (MESSAGE)
		MOVWF	TBLPTRU,A
		MOVLW	HIGH (MESSAGE)
		MOVWF	TBLPTRH,A
		MOVLW	LOW (MESSAGE)
		MOVWF	TBLPTRL,A
		MOVFF	Areg,WREG
		CALL	LCDsendMessN
	    	ENDM

ifdef	MicroProStar
; This macro sets the carry flag if the port's bit is set
State		MACRO	PORT,BIT
		if	PORT == PORTD
		CALL	MP8KreadD
		endif
		if	PORT == PORTE
		CALL	MP8KreadE
		endif
		BCF	ALUSTA,C
		BTFSC	WREG,BIT
		BSF	ALUSTA,C
		ENDM
; Carry flag is cleared if the button is pressed and remains pressed
; 10 mSec later
Pressed		MACRO	PORT,BIT
		Local	Done
		State	PORT,BIT
		BTFSC	ALUSTA,C
		GOTO	Done
		MOVLW	D'10'
		CALL	Delay1mS
		State	PORT,BIT
Done
		ENDM
; Waits for a button to be released and stay released for 10 mSec
Release		MACRO	PORT,BIT
		Local	Wait
Wait
		State	PORT,BIT
		BTFSS	ALUSTA,C
		GOTO	Wait
		MOVLW	D'10'
		CALL	Delay1mS
		State	PORT,BIT
		BTFSS	ALUSTA,C
		GOTO	Wait
		ENDM
else
; This macro sets the carry flag if the port's bit is set
State		MACRO	PORT,BIT
		MOVLB	HIGH PORT
		BCF	ALUSTA,C
		BTFSC	PORT,BIT
		BSF	ALUSTA,C
		ENDM

; Carry flag is cleared if the button is pressed and remains pressed
; 10 mSec later
Pressed		MACRO	PORT,BIT
		State	PORT,BIT
		BTFSC	ALUSTA,C
		GOTO	$ + D'14'
		MOVLW	D'10'
		CALL	Delay1mS
		State	PORT,BIT
		ENDM

; Waits for a button to be released and stay released for 10 mSec
Release		MACRO	PORT,BIT
		State	PORT,BIT
		BTFSS	ALUSTA,C
		GOTO	$ - D'10'
		MOVLW	D'10'
		CALL	Delay1mS
		State	PORT,BIT
		BTFSS	ALUSTA,C
		GOTO	$ - D'30'
		ENDM
endif

MOVEB		MACRO	REG1,REG2
		MOVFF	REG1,REG2
		ENDM
		
MOVE16		MACRO	REG1,REG2
		MOVFF	REG1,REG2
		MOVFF	(REG1+1),(REG2+1)
		ENDM
		
MOVE		MACRO	REG1,REG2
		MOVFF	REG1,REG2
		MOVFF	(REG1+1),(REG2+1)
		ENDM

MOVE24		MACRO	REG1,REG2
		MOVFF	REG1,REG2
		MOVFF	(REG1+1),(REG2+1)
		MOVFF	(REG1+2),(REG2+2)
		ENDM

MOVE32		MACRO	REG1,REG2
		MOVFF	REG1,REG2
		MOVFF	(REG1+1),(REG2+1)
		MOVFF	(REG1+2),(REG2+2)
		MOVFF	(REG1+3),(REG2+3)
		ENDM
		
MOVEC		MACRO	CONST,REG1
		MOVLR	HIGH (REG1)
		MOVLW	LOW (CONST)
		MOVWF	(REG1)
		MOVLW	HIGH (CONST)
		MOVWF	(REG1+1)
		ENDM     
		
MOVEC24		MACRO	CONST,REG
		MOVLR	HIGH (REG)
		MOVLW	LOW (CONST)
		MOVWF	(REG)
		MOVLW	HIGH (CONST)
		MOVWF	(REG+1)
		MOVLW	UPPER (CONST)
		MOVWF	(REG+2)
		ENDM

MOVEC32		MACRO	CONST,REG
		MOVLR	HIGH (REG)
		MOVLW	LOW (CONST)
		MOVWF	(REG)
		MOVLW	LOW (CONST/100)
		MOVWF	(REG+1)
		MOVLW	HIGH (CONST/100)
		MOVWF	(REG+2)
		MOVLW	UPPER (CONST/100)
		MOVWF	(REG+3)
		ENDM

; The following macros support indirect word movements

        ; Move from address to word
MOVEIW          MACRO   ADD,REG
                MOVLW   0F
                ANDWF   BSR,F
                MOVLR   HIGH ADD
                MOVFP   ADD,FSR1
                MOVFP   ADD+1,WREG
                SWAPF   WREG
                IORWF   BSR,F
                BCF     ALUSTA,FS3
                BSF     ALUSTA,FS2
                MOVPF   INDF1,REG
                MOVPF   INDF1,REG+1
                ENDM
                
        ; Move from word to address
MOVEWI          MACRO   REG,ADD
                MACRO   ADD,REG
                MOVLW   0F
                ANDWF   BSR,F
                MOVLR   HIGH ADD
                MOVFP   ADD,FSR1
                MOVFP   ADD+1,WREG
                SWAPF   WREG
                IORWF   BSR,F
                BCF     ALUSTA,FS3
                BSF     ALUSTA,FS2
                MOVFP   REG,INDF1
                MOVFP   REG+1,INDF1
                ENDM  
                
        ; Move from address to byte
MOVEIB          MACRO   ADD,REG
                MOVLW   0F
                ANDWF   BSR,F
                MOVLR   HIGH ADD
                MOVFP   ADD,FSR1
                MOVFP   ADD+1,WREG
                SWAPF   WREG
                IORWF   BSR,F
                MOVPF   INDF1,WREG
                MOVLR	HIGH REG
                MOVWF	REG
                ENDM
                
        ; Move from byte to address
MOVEBI          MACRO   REG,ADD
		MOVLR	HIGH REG
		MOVFP	REG,PRODH
                MOVLW   0F
                ANDWF   BSR,F
                MOVLR   HIGH ADD
                MOVFP   ADD,FSR1
                MOVFP   ADD+1,WREG
                SWAPF   WREG
                IORWF   BSR,F
                MOVFP   PRODH,INDF1
                ENDM

ifdef		MicroProStar
; The following set of macros support the flagging system used to mark
; the IO system as busy and test if its busy.
; Also LCD display macros are included.
MP8K_SetBusy	MACRO
		BSF	LATG,4,A
		ENDM
		
MP8K_ResetBusy	MACRO
		BCF	LATG,4,A
		ENDM
		
; Returns with the carry flag set if busy
MP8K_IsBusy	MACRO
		BCF	ALUSTA,C
		BTFSC	LATG,4,A
		BSF	ALUSTA,C
		ENDM
		
; Display macros
SingleLine	MACRO
		BCF	PIE3,TMR4IE,A	; disable the interrupt
		ENDM		
DualLine	MACRO
		BSF	PIE3,TMR4IE,A	; enable the interrupt
		BCF	PIR3,TMR4IF,A	; Clear the interupt flag
		ENDM
ShowLine1	MACRO
		CALL	LCDshowLine1
		ENDM
ShowLine2	MACRO
		CALL	LCDshowLine2
		SETF	WREG		; Make sure we point to line two of the display
		MOVFF	WREG,DisplayLine
		ENDM
NoAddCorrection	MACRO
		SETF	WREG
		MOVFF	WREG,LCDcgFlag
		ENDM
AddCorrection	MACRO
		CLRF	WREG
		MOVFF	WREG,LCDcgFlag
		ENDM
else

; Display macros, these macros do nothing they are included to keep
; code compatibility with the MicroStar version.
SingleLine	MACRO
		ENDM	
DualLine	MACRO
		ENDM
ShowLine1	MACRO
		ENDM
ShowLine2	MACRO
		ENDM
NoAddCorrection	MACRO
		ENDM
AddCorrection	MACRO
		ENDM
endif

