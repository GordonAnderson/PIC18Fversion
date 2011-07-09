;
; MicroProStar test program
;

	list      p=18F8722            ; list directive to define processor
	#include <P18F8722.INC>         ; processor specific variable definitions
	errorlevel 2
	
#define	MicroProStar
	
	Include	<Constants.asm>
	Include	<RAM.asm>
	Include <Macros.asm>


;**********************************************************************
                ORG    OFFSET + 0x0
                GOTO	Start

;************   High Priority INTERRUPT VECTOR
                ORG    		0x008 + OFFSET
		GOTO		HIGHISRS

;************   Low Priority INTERRUPT VECTOR
                ORG		0x018 + OFFSET
		GOTO		LOWISRS

HIGHISRS
           	PUSHREGS              		;save specific registers

	   	POPREGS               		;restore specific registers
            	retfie            		;return from interrupt
               

LOWISRS
            	PUSHREGSLOW            		;save specific registers
	; Test for Timer4 interrupt and process
		BTFSC	PIR3,TMR4IF
		CALL	Timer4ISR
	; Exit	
		POPREGSLOW             		;restore specific registers
            	retfie            		;return from interrupt


; This function will load the ADC mux byte from the ADCaddTbl table located
; in the general data area, page 2.
; On call WREG contains the ADC channel request and on return the data is in 
; WREG.
ADClookup
   ; Compute the jump location
		ANDLW	0F
		MULLW	6
		MOVFF	PCL,WREG		; Refresh the program counter latch
		MOVF	PRODL,W,A
		ADDWF	PCL	

		MOVFF	ADCaddTbl, WREG
		RETURN
		MOVFF	ADCaddTbl+1, WREG
		RETURN
		MOVFF	ADCaddTbl+2, WREG
		RETURN
		MOVFF	ADCaddTbl+3, WREG
		RETURN
		MOVFF	ADCaddTbl+4, WREG
		RETURN
		MOVFF	ADCaddTbl+5, WREG
		RETURN
		MOVFF	ADCaddTbl+6, WREG
		RETURN
		MOVFF	ADCaddTbl+7, WREG
		RETURN
		MOVFF	ADCaddTbl+8, WREG
		RETURN
		MOVFF	ADCaddTbl+9, WREG
		RETURN
		MOVFF	ADCaddTbl+0A, WREG
		RETURN
		MOVFF	ADCaddTbl+0B, WREG
		RETURN
		MOVFF	ADCaddTbl+0C, WREG
		RETURN
		MOVFF	ADCaddTbl+0D, WREG
		RETURN
		MOVFF	ADCaddTbl+0E, WREG
		RETURN
		MOVFF	ADCaddTbl+0F, WREG
		RETURN
                
Start
	; Startup delay to let hardware stabalize
		MOVLW	D'100'
		CALL	Delay1mS
	; Init stuff
		CALL	MP8Kinit
		CALL	LCDinit
		; Port direction bits
		BCF	DDRA,BUZZER,A		
		BCF	DDRF,MOD,A	
		CALL	ProcessorType
	; Init the ADC table
		MOVLW	0x40
		MOVFF	WREG,ADCaddTbl+0
		MOVLW	0x41
		MOVFF	WREG,ADCaddTbl+1
		MOVLW	0x82
		MOVFF	WREG,ADCaddTbl+2
		MOVLW	0x83
		MOVFF	WREG,ADCaddTbl+3
		MOVLW	0x44
		MOVFF	WREG,ADCaddTbl+4
		MOVLW	0x45
		MOVFF	WREG,ADCaddTbl+5
		MOVLW	0x46
		MOVFF	WREG,ADCaddTbl+6
		MOVLW	0x47
		MOVFF	WREG,ADCaddTbl+7
		MOVLW	0x64
		MOVFF	WREG,ADCaddTbl+8
		MOVLW	0x65
		MOVFF	WREG,ADCaddTbl+9
		MOVLW	0x66
		MOVFF	WREG,ADCaddTbl+0x0A
		MOVLW	0x67
		MOVFF	WREG,ADCaddTbl+0x0B
		MOVLW	0x0C
		MOVFF	WREG,ADCaddTbl+0x0C
		MOVLW	0x0D
		MOVFF	WREG,ADCaddTbl+0x0D
	
	; Enable global interrups...
		BSF	INTCON,GIE
		BSF	INTCON,PEIE
		BSF	RCON,IPEN

		
	; Processing test loop
LOOP
		DualLine
	; Test if the option button and the preset button are pressed
	; If they are both pressed then enter the IO test routine
		Pressed	PORTE,OPTION
		BTFSC	ALUSTA,C
		GOTO	mainStartup
		Pressed	PORTD,PRESET
		BTFSS	ALUSTA,C
		GOTO	TestIO
mainStartup
		GOTO	mainStartup
;
; Delay subroutine. Delay = 2uS * WREG value
;
Delay2uS
		NOP
		DECFSZ	WREG
		GOTO	Delay2uS
		RETURN

;
; Delay subroutine. Delay = 1mS * Areg value
;
Delay1mS
		MOVWF	Areg
Delay1mS0
		MOVLW	D'250'
		CALL	Delay2uS
		MOVLW	D'250'
		CALL	Delay2uS
		DECFSZ	Areg
		GOTO	Delay1mS0
		RETURN
	
MES1		DB	"  MicroProStar  ",0
MES2		DB	"  Version 2.0n  ",0
MES3		DB	"ADC CH    = XXXX",0

		Include	<TestIO.asm>
		Include	<MP8000.asm>
		Include	<ADC.asm>
		Include	<Display.asm>
		Include	<math.asm>
		
		END
