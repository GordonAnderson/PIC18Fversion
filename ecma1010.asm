;
; ECM-A1010 LCD Driver
;
; This file contains the drivers for the SEIKO 4 line LCD display. This
; display uses the SED1230 controller. This is not a very common controller.
; 
; This is the display used in the orginal MicroStar.
;
CS	EQU	6		; LCD
A0	EQU	3		; LCD
ENA	EQU	4		; LCD

PMES1	DB	"Introducing ",0
PMES2	DB	"     the    ",0

LCDinit
	; Set the direction of all bits and define initial state
		MOVLB	HIGH LCDDATA
		MOVLW	0
		MOVPF	WREG,LOW LCDDATA-1	; Data output port
		MOVLW	0
		MOVPF	WREG,LCDDATA
	; Control lines...
		MOVLB	HIGH LCDCTRL
		MOVLW	LOW LCDCTRL - 1
		MOVWF	FSR0
		BCF	INDF0,ENA
		BCF	INDF0,A0
		BCF	INDF0,CS	; Control lines are all outputs
		BSF	LCDCTRL,ENA
		BCF	LCDCTRL,CS
		BCF	LCDCTRL,A0
		MOVLW	D'20'
		CALL	Delay1mS	
		BSF	LCDCTRL,CS
	; Now send the initalization data to the display
		MOVLW	D'20'
		CALL	Delay1mS	
		MOVLW	68
		CALL	LCDsendCMD
		MOVLW	68
		CALL	LCDsendCMD
		MOVLW	23
		CALL	LCDsendCMD
		MOVLW	31
		CALL	LCDsendCMD
		MOVLW	70
		CALL	LCDsendCMD
		MOVLW	42
		CALL	LCDsendCMD
		MOVLW	D'20'
		CALL	Delay1mS	
		MOVLW	57
		CALL	LCDsendCMD
		MOVLW	D'20'
        	CALL	Delay1mS
		MOVLW	0D0
		CALL	LCDsendCMD
                PrintMess MES0
		MOVLW	0E0
		CALL	LCDsendCMD
                PrintMess MES0
	; Send the signon message and software version
		MOVLW	LINE1
		CALL	LCDsendCMD
		PrintMess PMES1
		MOVLW	LINE2
		CALL	LCDsendCMD
		PrintMess PMES2
		MOVLW	LINE3
		CALL	LCDsendCMD
		PrintMess MES1
		MOVLW	LINE4
		CALL	LCDsendCMD
		PrintMess MES2
		MOVLW	0F0
		CALL	LCDsendCMD
		PrintMess MES0
		MOVLW	020
		CALL	LCDsendData

		MOVLW	0CC
		CALL	LCDsendCMD
		MOVLW	00
		CALL	LCDsendData
		MOVLW	0DC
		CALL	LCDsendCMD
		MOVLW	00
		CALL	LCDsendData
		MOVLW	0EC
		CALL	LCDsendCMD
		MOVLW	00
		CALL	LCDsendData

		RETURN

LCDsendData
		MOVLB	HIGH LCDDATA
		MOVPF	WREG,LCDDATA
		MOVLB	HIGH LCDCTRL
		BSF	LCDCTRL,A0
		BCF	LCDCTRL,ENA
		NOP
		NOP
		BSF	LCDCTRL,ENA
		NOP
		return

LCDsendCMD
		MOVLB	HIGH LCDDATA
		MOVPF	WREG,LCDDATA
		MOVLB	HIGH LCDCTRL
		BCF	LCDCTRL,A0
		BCF	LCDCTRL,ENA
		NOP
		NOP
		BSF	LCDCTRL,ENA
		NOP
		RETURN

