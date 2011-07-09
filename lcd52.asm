;
; LCD Drivers for displays using HD44780 controller
; or the ST7036 controller used in the DOG162 display
;
; This file contains the drivers for the common LCD Display controller. 
; These displays use a HD44780 controller, this is the most common
; LCD controller in use today.
;
; This driver also supports the ST7036 controller, The differences are
; very minor.
;
; The MicroStar will send position command to for the first and second lines of
; the display. It expect the first line address to start a B0 and the second
; at C0. This is not the same as the HD44780 and will see code in the LCDsendCMD
; function to map these position command into valid values.
;
RS	EQU	5		; LCD
ENA	EQU	3		; LCD
RW	EQU	4		; LCD


LCDinit
	; Set the direction of all bits and define initial state
		MOVLB	HIGH LCDDATA
		CLRF	LCDDATADIR	; Data output port
		CLRF	LCDDATA
	; Control lines...
		BCF	LCDCTRLDIR,ENA,A
		BCF	LCDCTRLDIR,RS,A
		BCF	LCDCTRLDIR,RW,A	; Control lines are all outputs
		BSF	LCDCTRL,ENA,A
		BSF	LCDCTRL,RS,A
		BSF	LCDCTRL,RW,A
		MOVLW	D'20'
		CALL	Delay1mS
	; Now send the initalization data to the display
		MOVFF	Dog162,WREG
		COMF	WREG
		TSTFSZ	WREG
		GOTO 	NoDog
	; Here to init for the DOG162 display, Controller is ST7036	
		MOVLW	39
		CALL	LCDsendCMD
		MOVLW	D'5'
		CALL	Delay1mS	
		MOVLW	39
		CALL	LCDsendCMD
		MOVLW	D'1'
		CALL	Delay1mS	
		MOVLW	39
		CALL	LCDsendCMD
		MOVLW	D'1'
		CALL	Delay1mS	
		MOVLW	39
		CALL	LCDsendCMD

		MOVLW	1C
		CALL	LCDsendCMD
		MOVLW	52
		CALL	LCDsendCMD
		MOVLW	69
		CALL	LCDsendCMD
		MOVLW	74			; Contrast
		CALL	LCDsendCMD
		MOVLW	0C
		CALL	LCDsendCMD
		MOVLW	01
		CALL	LCDsendCMD
		MOVLW	06
		CALL	LCDsendCMD
		
		MOVLW	38
		CALL	LCDsendCMD
	; Init the charater generator for digital trims
		MOVLW		40
		CALL		LCDsendCMD
		MOVLW		D'64'
		PrintMessN	HCGtbl
		GOTO	LCDinitDone
	; Here for the standard HD44780 controller init
NoDog	
		MOVLW	38
		CALL	LCDsendCMD
		MOVLW	D'5'
		CALL	Delay1mS	
		MOVLW	38
		CALL	LCDsendCMD
		MOVLW	D'1'
		CALL	Delay1mS	
		MOVLW	38
		CALL	LCDsendCMD
		MOVLW	D'1'
		CALL	Delay1mS	
		MOVLW	38
		CALL	LCDsendCMD

		MOVLW	06
		CALL	LCDsendCMD
		MOVLW	0C
		CALL	LCDsendCMD
		MOVLW	01
		CALL	LCDsendCMD
		MOVLW	80
		CALL	LCDsendCMD
	; Init the charater generator for digital trims
		MOVLW		40
		CALL		LCDsendCMD
		MOVLW		D'64'
		PrintMessN	HCGtbl
LCDinitDone
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
		Return

;
; This function is called to remap special characters to printable codes.
; This is used for non english options.
; The LCD print char is assumed to be in LCDwreg, the remaped result is
; put in the same location.
;
LCDspecialRemap
		MOVLB	HIGH LCDwreg
		MOVLW	'ó'
		CPFSEQ	LCDwreg
		GOTO	LCDsR01
LCDsR00
		MOVLW	'o'
		MOVWF	LCDwreg
		Return
LCDsR01	
		MOVLW	'ò'
		CPFSEQ	LCDwreg
		GOTO	LCDsR02
		GOTO	LCDsR00
LCDsR02
		MOVLW	'à'
		CPFSEQ	LCDwreg
		GOTO	LCDsR03
		MOVLW	'a'
		MOVWF	LCDwreg
		Return
LCDsR03
		MOVLW	'é'
		CPFSEQ	LCDwreg
		GOTO	LCDsR04
		MOVLW	'e'
		MOVWF	LCDwreg
		Return
LCDsR04
		MOVLW	'ç'
		CPFSEQ	LCDwreg
		GOTO	LCDsR05
		MOVLW	'c'
		MOVWF	LCDwreg
		Return
LCDsR05
		MOVLW	'í'
		CPFSEQ	LCDwreg
		GOTO	LCDsR06
		MOVLW	'i'
		MOVWF	LCDwreg
		Return
LCDsR06
		MOVLW	'è'
		CPFSEQ	LCDwreg
		GOTO	LCDsR07
		MOVLW	'e'
		MOVWF	LCDwreg
		Return
LCDsR07
		MOVLW	'ú'
		CPFSEQ	LCDwreg
		Return
		MOVLW	'u'
		MOVWF	LCDwreg
		Return
		
		
		
		
LCDsendData
		CALL	LCDwait
ifdef		Catalan
		CALL	LCDspecialRemap
		MOVFF	LCDwreg,WREG
endif
		CALL	LCDportOut
		BSF	LCDCTRL,RS,A
		BCF	LCDCTRL,RW,A
		NOP
		NOP
		BSF	LCDCTRL,ENA,A
		NOP
		NOP
		BCF	LCDCTRL,ENA,A
		NOP
		NOP
		Return

LCDsendCMD
		CALL	LCDwait
		CALL	LCDportOut
		BCF	LCDCTRL,RS,A
		BCF	LCDCTRL,RW,A
		NOP
		NOP
		BSF	LCDCTRL,ENA,A
		NOP
		NOP
		BCF	LCDCTRL,ENA,A
		NOP
		NOP
		Return

; This function reads the busy bit and waits till the display is not busy
LCDwait
	; Wait till its not busy
		CALL	LCDbusy
		BTFSC	ALUSTA,0,A
		GOTO	LCDwait
	; Make the data port, outputs
		CLRF	LOW LCDDATADIR,A
		Return

; This function reads the busy bit and sets the carry flag if the display
; is busy.
LCDbusy
	; Make the data port, inputs
		SETF	LCDDATADIR,A
	; Read the busy bit
		BSF	LCDCTRL,RW,A
		BCF	LCDCTRL,RS,A
		NOP
		NOP
		BSF	LCDCTRL,ENA,A
		NOP
		NOP
	; Now read bit and set Carry flag in CPU
		BCF	ALUSTA,0,A
		MOVFF	WREG,LCDwreg
		MOVFF	Adapter,WREG
		TSTFSZ	WREG
		GOTO	LCDbusyA
		; Here if not adapter
		BTFSC	LCDDATA,7,A
		BSF	ALUSTA,0,A
		BCF	LCDCTRL,ENA,A
		MOVFF	LCDwreg,WREG
		Return
LCDbusyA
		BTFSC	LCDDATA,0,A
		BSF	ALUSTA,0,A
		BCF	LCDCTRL,ENA,A
		MOVFF	LCDwreg,WREG
		Return


; This function output the data port value. The value to be sent is
; in Reg WREG on call. This fundtion sends the data to the data port.
LCDportOut
		MOVWF	LCDDATA,A
	; If this is the Adapter option we have more to do
		MOVFF	Adapter,WREG
		COMF	WREG
		TSTFSZ	WREG
		RETURN
	; Here if adapter mode
		MOVFF	LCDDATA,WREG
		CLRF	LCDDATA,A
		BTFSC	WREG,0,A
		BSF	LCDDATA,4,A
		BTFSC	WREG,1,A
		BSF	LCDDATA,5,A
		BTFSC	WREG,2,A
		BSF	LCDDATA,6,A
		BTFSC	WREG,3,A
		BSF	LCDDATA,7,A
		BTFSC	WREG,4,A
		BSF	LCDDATA,3,A
		BTFSC	WREG,5,A
		BSF	LCDDATA,2,A
		BTFSC	WREG,6,A
		BSF	LCDDATA,1,A
		BTFSC	WREG,7,A
		BSF	LCDDATA,0,A
		RETURN

; Custom character genertion table, used to create horizontal bars
; This table is used to setup the display for digital trim display.
; The second line of the display is used to indicate the trim
; position. The second line is divided in half and used for positive
; and negative trim positions. The custom characters need to be changed
; for right or left bar painting because 9 characters are needed and
; only 8 are posible. . 
;
; For a right going bar:
;	0,1,2,3,7
; For a left going bar:
;	4,5,6,7,3
HCGtbl
	; The first 4 symbols for the right side of the display
	DB	10,10,10,10,10,10,10,10
	DB	18,18,18,18,18,18,18,18
	DB	1C,1C,1C,1C,1C,1C,1C,1C
	DB	1E,1E,1E,1E,1E,1E,1E,1E
	; The second 4 symbols for the left side of the display
	DB	01,01,01,01,01,01,01,01
	DB	03,03,03,03,03,03,03,03
	DB	07,07,07,07,07,07,07,07
	DB	0F,0F,0F,0F,0F,0F,0F,0F
	; This is the pattern for all pixels on
	DB	1F,1F,1F,1F,1F,1F,1F,1F


