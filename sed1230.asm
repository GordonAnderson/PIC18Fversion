;
; SED1230 LCD Driver
;
; This file contains the drivers for the OPTREX on glass LCD display. This
; display uses the SED1230 controller. This is not a very common controller.
; 
; This is the display used in the orginal MicroStar.
;
CSlcd	EQU	5		; LCD
A0	EQU	3		; LCD
ENA	EQU	4		; LCD

LCDinit
	; Set the direction of all bits and define initial state
		MOVLB	HIGH LCDDATA
		CLRF	LCDDATADIR	; Data output port
		CLRF	LCDDATA
	; Control lines...
		BCF	LCDCTRLDIR,ENA,A
		BCF	LCDCTRLDIR,A0,A
		BCF	LCDCTRLDIR,CSlcd,A	; Control lines are all outputs
		BSF	LCDCTRL,ENA,A
		BCF	LCDCTRL,CSlcd,A
		BCF	LCDCTRL,A0,A
		MOVLW	D'20'
		CALL	Delay1mS
		BSF	LCDCTRL,CSlcd,A
	; Now send the initalization data to the display
		MOVLW	D'20'
		CALL	Delay1mS	
		MOVLW	61
		CALL	LCDsendCMD
		MOVLW	61
		CALL	LCDsendCMD
		MOVLW	23
		CALL	LCDsendCMD
		MOVLW	31
		CALL	LCDsendCMD
		MOVLW	78
		CALL	LCDsendCMD
		MOVLW	42
		CALL	LCDsendCMD
		MOVLW	57
		CALL	LCDsendCMD
	; Init the charater generator for digital trims
		MOVLW		80
		CALL		LCDsendCMD
		MOVLW		D'16'
		PrintMessN	HCGtbl
	; Send the signon message and software version
		MOVLW	LINE1
		CALL	LCDsendCMD
		MOVLW	HIGH (MES1)
		MOVWF	TBLPTRH
		MOVLW	LOW (MES1)
		MOVWF	TBLPTRL
		CALL	LCDsendMess
		MOVLW	LINE2
		CALL	LCDsendCMD
		MOVLW	HIGH (MES2)
		MOVWF	TBLPTRH
		MOVLW	LOW (MES2)
		MOVWF	TBLPTRL
		CALL	LCDsendMess
		RETURN
		
LCDsendData
		MOVWF	LCDDATA,A
		BSF	LCDCTRL,A0,A
		BCF	LCDCTRL,ENA,A
		NOP
		NOP
		NOP
		BSF	LCDCTRL,ENA,A
		NOP
		NOP
		NOP
		RETURN

LCDsendCMD
		MOVWF	LCDDATA,A
		BCF	LCDCTRL,A0,A
		BCF	LCDCTRL,ENA,A
		NOP
		NOP
		NOP
		BSF	LCDCTRL,ENA,A
		NOP
		NOP
		NOP
		RETURN

; Custom character genertion table, used to create horizontal bars
; This table is used to setup two custom characters. These are used
; for the zero marks on the bar graphs, these zero marks serve as 
; a center indicator for the display.
;
; For a right going zero mark:
;	0
; For a left going zero mark:
;	1
HCGtbl
	; The first 2 symbols for the right side of the display
	DB	10,10,10,10,10,10,10,10
	DB	01,01,01,01,01,01,01,01
