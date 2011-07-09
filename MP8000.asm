;
; MP8000.asm
;
; This file contains all the drivers and interface routines for the MP8000 interface
; PC board. This interface board is designed to plug into the 68HC11 socket and upgrade
; the MP8000 without the need for any hardware changes.
; 
; Gordon Anderson
;
; The mapping of the PIC processor to the MP8000 control signals is shown in
; the table below:
;
; PIC port		68CH11 port		Function
; E			C			Address / data
; D			B			High address
; 
; C3			A0			CH8 - A
; C4			A1			CH8 - C
; J1			A2			Option
; B5			A3			LCD-RS, ADC MUX
; B4			A4			LCD-RW
; B3			A5			LCD-E
; F7			A6			Mod
; J7			A7			Auto-Trim
;
; C7			D0			RS232, Rec
; C6			D1			RS232, Trans
; J2			D2			Alt Aircraft
; J3			D3			Run/Cal
; J4			D4
; J5			D5			Preset
;
; C1			AS			Address Strobe
; C2			R/W			Read / Write
; C0			E			Enable
;
; F0 AN5		E0			Ele, Ele trim
; A5 AN4		E1			Ail, Ail trim
; F1 AN6		E2			Rud, Rud trim
; F2 AN7		E3			Tht, Tht trim
; J0 			E4			CH5
; A0 AN0		E5			CH6
; A1 AN1		E6			CH7
; H6 AN14		E7 (pin 50)		Voltage ref?
;
; H7 AN15		VRH (pin 52)		Bat ref
;			VRL
;
; Notes:
;	1.) The MP8000 reference is generated from the battery and provides a high and low
;	    reference value. Thes are on the processor pins 52, and 51. The voltages are
;	    2.5 volts at pin 51 and 5 volts at pin 52 for a 10 volt source. The joystick
;	    pots vary between 2.5 and 5 volts.
;	2.) The reference generated from the regulated 5 volts on pin 50 is 3.15 volts,
;	    not sure what this is for.
;	3.) In the MicroStar when the Run/Cal swith is in cal mode and the Auto trim button
;	    and option button are pressed then the bootloader will not start the application 
;	    on powerup. In the MicroStar:
;				Port E bit 0 = Run/Cal
;				Port E bit 1 = Auto Trim
;				Port E bit 2 - Option
;	    A different version of the boot loader is needed for the MicroProStar if this 
;	    function is needed.
;
;	Port G bit 4 is used as a flag to indicate the IO system is busy on the MP8K
;	interface. This is needed to keep the interrupt IO from corrupting the 
;	polling loop IO.
;	Timer 4 is used to control the LCD display. The LCD display holds both line one 
;	line 2 of display data but can only display one line at a time. In the timer
;	function the display is flopped back and forth between line 1 and 2 every
;	half second.
;
; PIC18F8722 port and bit names

MP8K_AD		EQU	PORTE
MP8K_AD_LATCH	EQU	LATE
MP8K_HA		EQU	PORTD
MP8K_SW1	EQU	PORTC
MP8K_SW2	EQU	PORTJ
MP8K_LCD	EQU	PORTB

; Port bits assignments

;MP8K_LCD
MP8K_LCD_RS	EQU	5
MP8K_LCD_RW	EQU	4
MP8K_LCD_E	EQU	3


; MP8K_SW1
MP8K_E		EQU	0		; Output
MP8K_AS		EQU	1		; Output
MP8K_RW		EQU	2		; Output
MP8K_CH8A	EQU	3		; Input
MP8K_CH8C	EQU	4		; Input

; MP8K_SW2
MP8K_CH5	EQU	0		; Input
MP8K_OPT	EQU	1		; Input
MP8K_AAC	EQU	2		; Input
MP8K_RUNCAL	EQU	3		; Input
MP8K_PRESET	EQU	5		; Input


;
; This function is called at the framing rate, nominally 40 Hz, the call comes
; from the timer ISR used to generate the output pulse stream. This routine is
; used for the manual display mode switching using the Auto Trim switch
;
MPSrtc
	; Test the DisplayMode flag and exit if its not in the manual mode
		MOVLB	HIGH DisplayMode
		MOVF	DisplayMode,W
		BTFSC	ALUSTA,Z
		RETURN
	; If IO system is busy, exit
		MP8K_IsBusy
		BTFSC	ALUSTA,C
		RETURN
	; Here if in manual mode so set the display line
		MOVFF	DisplayLine,WREG
		TSTFSZ	WREG
		GOTO	MPSrtc0
		; Here to set line 1
		CALL	LCDshowLine1
		RETURN
		; Here to set line 2
MPSrtc0:
		CALL	LCDshowLine2
		RETURN

;
; This interrupt happens at about a 30 Hz rate. This routine is used to control the display
; line number. The line displayed is switched back and forth every half second.
;
Timer4ISR
	; If the interrupt is disabled then exit
		BTFSS	PIE3,TMR4IE
		RETURN
	; If the mode is manual then exit
		MOVLB	HIGH DisplayMode
		MOVF	DisplayMode,W
		BTFSS	ALUSTA,Z
		GOTO	Timer4exit
	; If the IO system is busy just exit without doing anything
		MP8K_IsBusy
		BTFSC	ALUSTA,C
		GOTO	Timer4exit
	; Count the interrupt number
		MOVLR	HIGH TMR4intNum
		INCF	TMR4intNum
		MOVLW	D'25'
		CPFSEQ	TMR4intNum
		GOTO	Timer4next
	; Here if count is 15 so display line 2
		CALL	LCDshowLine2
Timer4next
		MOVLW	D'50'
		CPFSEQ	TMR4intNum
		GOTO	Timer4exit
	; Here is count is 30 so display line 1
		CALL	LCDshowLine1	
		CLRF	TMR4intNum
	; Exit
Timer4exit
		BCF	PIR3,TMR4IF	; Clear the interupt flag
		RETURN

;
; This function initalizes the IO ports and hardware that is specific to the MP8000.
;
MP8Kinit
	; Setup Switch port 1, port C
		MOVLB	HIGH DDRC
		BCF	DDRC,MP8K_E
		BCF	DDRC,MP8K_AS
		BCF	DDRC,MP8K_RW
		BSF	DDRC,MP8K_CH8A
		BSF	DDRC,MP8K_CH8C
		MOVLB	HIGH MP8K_SW1
		BCF	MP8K_SW1,MP8K_E
		BSF	MP8K_SW1,MP8K_AS
		BSF	MP8K_SW1,MP8K_RW
	; Setup Switch port 2, port J
		MOVLB	HIGH DDRJ
		BSF	MP8K_SW2,MP8K_CH5	
		BSF	MP8K_SW2,MP8K_OPT	
		BSF	MP8K_SW2,MP8K_AAC	
		BSF	MP8K_SW2,MP8K_RUNCAL	
		BSF	MP8K_SW2,MP8K_PRESET	
	; Make Address / Data port an input port for now
		SETF	WREG
		MOVLB	HIGH DDRE
		MOVWF	DDRE		
	; High address port is always an output, set address at 0
		CLRF	WREG
		MOVLB	HIGH DDRD
		MOVWF	DDRD		
		MOVLB	HIGH MP8K_HA
		MOVWF	MP8K_HA	
	; Setup timer 4 to be used for display control
		CLRF	WREG
		MOVFF	WREG,TMR4intNum
		MOVLW	0x7F		; 1:16 postscal, timer on, prescaller = 16
		MOVWF	T4CON
		SETF	WREG
		MOVWF	PR4		; Set period register to 255
		; enable the interrupt
		BCF	PIE3,TMR4IE	; Disable the interrupt
		BCF	PIR3,TMR4IF	; Clear the interupt flag
		BCF	IPR3,TMR4IP	; Set priority to low
		RETURN

; This function reads the port that is defined at the address in WREG. The
; port data is returned in WREG and its written into the data port latch.
MP8KreadPort
	; Send the port address to high address IO port
		MOVWF	MP8K_HA,A
	; Set the data port to input
		SETF	DDRE,A
	; Enable the port
		BSF	MP8K_SW1,MP8K_E,A
	; Read the data
		NOP
		MOVF	MP8K_AD,W,A
	; Disable the port
		BCF	MP8K_SW1,MP8K_E,A
	; Save the data in the port latch
		MOVFF	WREG,MP8K_AD_LATCH
	; Exit
		RETURN
		
; This function writes the data in the data port to the address defined in
; WREG.
MP8KwritePort
	; Send the port address to high address IO port
		MOVFF	WREG,MP8K_HA
	; Set the data port to output
		CLRF	DDRE,A
	; Enable the port
		BSF	MP8K_SW1,MP8K_E,A
	; Disable the port
		BCF	MP8K_SW1,MP8K_E,A
	; Set the data port to input
		SETF	DDRE,A
	; Exit
		RETURN
	
; This function emulates the reading of portD and returns the data in the WREG
; register.
;
; PortD bits, returned in WREG
;AilDR		0
;EleDR		1
;RudDR		2
;PRESET		3
;MIX1		4
;MIX2		5
;MIX3		6
;CH5		7
;
MP8KreadD
		MP8K_SetBusy
	; Read the switch input port
		MOVLW	0x28
		CALL	MP8KreadPort
	; Mark the right bits in the output reg, WREG
		CLRF	WREG
		BTFSC	MP8K_AD_LATCH,3
		BSF	WREG,MIX1,A
		BTFSC	MP8K_AD_LATCH,4
		BSF	WREG,MIX2,A
		BTFSC	MP8K_AD_LATCH,5
		BSF	WREG,MIX3,A
		BTFSC	MP8K_AD_LATCH,0
		BSF	WREG,EleDR,A
		BTFSC	MP8K_AD_LATCH,1
		BSF	WREG,AilDR,A
		BTFSC	MP8K_AD_LATCH,2
		BSF	WREG,RudDR,A
	; Mark the bits using direct mapped ports
		BTFSC	MP8K_SW2,MP8K_CH5
		BSF	WREG,CH5,A
		BTFSC	MP8K_SW2,MP8K_PRESET
		BSF	WREG,PRESET,A
	; Exit
		MP8K_ResetBusy
		RETURN

; This function emulates the reading of portE and returns the data in the WREG
; register.
;
; PortE bits, returned in WREG
;RUNCAL		0
;AUTOT		1
;OPTION		2
;CH8A		3
;CH8C		4
;ALTAFK		5
;SNAPR		6
;SNAPL		7
;
MP8KreadE
		MP8K_SetBusy
	; Read the switch input port
		MOVLW	0x28
		CALL	MP8KreadPort
	; Mark the right bits in the output reg, WREG
		CLRF	WREG
		BTFSC	MP8K_AD_LATCH,7
		BSF	WREG,SNAPR,A
		BTFSC	MP8K_AD_LATCH,6
		BSF	WREG,SNAPL,A
	; Mark the bits using direct mapped ports
		BTFSC	MP8K_SW1,MP8K_CH8A
		BSF	WREG,CH8A,A
		BTFSC	MP8K_SW1,MP8K_CH8C
		BSF	WREG,CH8C,A
		BTFSC	MP8K_SW2,MP8K_RUNCAL
		BSF	WREG,RUNCAL,A
		BTFSC	MP8K_SW2,MP8K_OPT
		BSF	WREG,OPTION,A
		BTFSC	MP8K_SW2,MP8K_AAC
		BSF	WREG,ALTAFK,A
		BTFSC	PORTJ,7
		BSF	WREG,AUTOT,A
	; Exit
		MP8K_ResetBusy
		RETURN

; This function drives the MP8000 buzzer. This is done by using the MicroStar normal buzzer
; output pin and sending it to the proper MP8000 output pin.
MP8Kbuzzer
		MP8K_SetBusy
	; Read the MicroStar buzzer pin and build the MP8000 image
		MOVLW	0x20			; Port address
		CLRF	MP8K_AD,A
		BTFSS	LATA,BUZZER,A
		BSF	MP8K_AD,0,A
	; Send the image to the MP8000 port
		CALL	MP8KwritePort
		MP8K_ResetBusy
	; Exit
		RETURN
		
; *************** 
; LCD functions
; ***************

; The display used in the MP8000 is a single line model with 16 characters. It is treated as a two line by
; 8 character display through the programming interface. Line 1 starts at address 0x80 and line 2 starts
; at 0xC0. These display drivers emulate normal single line display with a starting address of 0x80.
; If data is written to the second display line it is treated as the first line of the display.
;
LCDinit
	; Control lines...
		BCF	DDRB,MP8K_LCD_E,A
		BCF	DDRB,MP8K_LCD_RS,A
		BCF	DDRB,MP8K_LCD_RW,A	; Control lines are all outputs
		BSF	MP8K_LCD,MP8K_LCD_E,A
		BSF	MP8K_LCD,MP8K_LCD_RS,A
		BSF	MP8K_LCD,MP8K_LCD_RW,A
		MOVLW	D'20'
		CALL	Delay1mS
	; Here for the standard HD44780 controller init
		MOVLW	0x3F
		CALL	LCDsendCMD0
		MOVLW	D'5'
		CALL	Delay1mS	
		MOVLW	0x3F
		CALL	LCDsendCMD0
		MOVLW	D'1'
		CALL	Delay1mS	
		MOVLW	0x3F
		CALL	LCDsendCMD0
		MOVLW	D'1'
		CALL	Delay1mS	
		MOVLW	0x3F
		CALL	LCDsendCMD

		MOVLW	0x0C
		CALL	LCDsendCMD
		MOVLW	0x06
		CALL	LCDsendCMD
		MOVLW	0x80
		CALL	LCDsendCMD
		MOVLW	0x01
		CALL	LCDsendCMD
	; Init the charater generator for digital trims
		SETF	WREG
		MOVFF	WREG,LCDcgFlag
		MOVLW	40
		CALL	LCDsendCMD
		MOVLW	D'64'
		PrintMessN HCGtbl
	; Send the signon message and software version
		CLRF	WREG
		MOVFF	WREG,LCDcgFlag
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
		MP8K_SetBusy
	; Wait for the display to be ready
		CALL	LCDwait
	; The display data is in the LCDwreg reg
	; Write the data to the display
		MOVLW	0x38			; Port address
		MOVFF	LCDwreg,MP8K_AD
		CALL	MP8KwritePort
	; Toggle the LCD write lines
		BSF	MP8K_LCD,MP8K_LCD_RS,A
		BCF	MP8K_LCD,MP8K_LCD_RW,A
		BSF	MP8K_LCD,MP8K_LCD_E,A
		NOP
		NOP
		BCF	MP8K_LCD,MP8K_LCD_E,A
		BSF	MP8K_LCD,MP8K_LCD_RW,A
		BCF	MP8K_LCD,MP8K_LCD_RS,A
		NOP
		CALL	LCDaddressAdjust
		MP8K_ResetBusy
		RETURN

LCDsendCMD
		MP8K_SetBusy
		CALL	LCDwait
LCDsendCMD0
		MP8K_SetBusy
		MOVFF	WREG,LCDwreg
	; The display data is in the LCDwreg reg
	; Write the data to the display
		MOVLW	0x38			; Port address
		MOVFF	LCDwreg,MP8K_AD
		CALL	MP8KwritePort
	; Toggle the LCD write lines
		BCF	MP8K_LCD,MP8K_LCD_RS,A
		BCF	MP8K_LCD,MP8K_LCD_RW,A
		BSF	MP8K_LCD,MP8K_LCD_E,A
		NOP
		NOP
		BCF	MP8K_LCD,MP8K_LCD_E,A
		BSF	MP8K_LCD,MP8K_LCD_RW,A
		MP8K_ResetBusy
		RETURN

; This function reads the LCD busy bit and the address data.
; Data is returned in WREG.
LCDread
		BSF	MP8K_LCD,MP8K_LCD_RW,A
		BCF	MP8K_LCD,MP8K_LCD_RS,A
		BSF	MP8K_LCD,MP8K_LCD_E,A
	; Read the LCD port
		MOVFF	WREG,LCDwreg
		MOVLW	0x30
		CALL	MP8KreadPort
		BCF	MP8K_LCD,MP8K_LCD_E,A
		RETURN

; This function reads the busy bit and waits till the display is not busy
LCDwait
	; Wait till its not busy
		CALL	LCDbusy
		BTFSC	ALUSTA,C,A
		GOTO	LCDwait
		Return

; This function reads the busy bit and sets the carry flag if the display
; is busy.
LCDbusy
	; Read the busy bit
		CALL	LCDread
	; Set the carry flag if the display is ready
		BCF	ALUSTA,C,A
		BTFSC	WREG,7,A
		BSF	ALUSTA,C,A
		MOVFF	LCDwreg,WREG
		RETURN		

; The function will read the display position and adjust address to make the
; display act like a normal 16 char two line display.
;
;	if its 0x8 set to 0x40 
;	if its 0x10 set to 0x48 
LCDaddressAdjust
	; Test the LCDcgFlag if we are sending data to the cg then exit
		MOVLB	HIGH LCDcgFlag
		TSTFSZ	LCDcgFlag
		RETURN
	;
		CALL	LCDwait
		CALL	LCDread
		ANDLW	0x7F		; Igore the busy bit
		MOVFF	WREG,LCDwreg	; Save it
		MOVLB	HIGH LCDwreg
		MOVLW	0x40
		CPFSLT	LCDwreg
		RETURN			; If address is 40 or higher we are done
		MOVLW	0x10
		CPFSEQ	LCDwreg
		GOTO	Try8
		; Here if the address is 16 so set to 48
		MOVLW	0xC8
		CALL	LCDsendCMD
		RETURN		
Try8
		MOVLW	0x08
		CPFSEQ	LCDwreg
		RETURN			; if address is less than 8 we are done
		; Here is the address is 8 so set to 40
		MOVLW	0xC0
		CALL	LCDsendCMD
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
		
