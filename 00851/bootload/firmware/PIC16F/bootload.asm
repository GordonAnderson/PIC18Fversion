; *****************************************************************************
;        Software License Agreement				    
;		 						    
; The software supplied herewith by Microchip Technology 	    
; Incorporated (the “Company”) for its PICmicro® Microcontroller is 
; intended and supplied to you, the Company’s customer, for use     
; solely and exclusively on Microchip PICmicro Microcontroller	    
; products. The software is owned by the Company and/or its         
; supplier, and is protected under applicable copyright laws. All   
; rights are reserved. Any use in violation of the foregoing 	     
; restrictions may subject the user to criminal sanctions under	    
; applicable laws, as well as to civil liability for the breach of  
; the terms and conditions of this license.			    
;								    
; THIS SOFTWARE IS PROVIDED IN AN “AS IS” CONDITION. NO WARRANTIES, 
; WHETHER EXPRESS, IMPLIED OR STATUTORY, INCLUDING, BUT NOT LIMITED 
; TO, IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A 	    
; PARTICULAR PURPOSE APPLY TO THIS SOFTWARE. THE COMPANY SHALL NOT, 
; IN ANY CIRCUMSTANCES, BE LIABLE FOR SPECIAL, INCIDENTAL OR 	    
; CONSEQUENTIAL DAMAGES, FOR ANY REASON WHATSOEVER.		    
;								    
;					 			    
; Bootloader for PIC16F by Rodger Richey
; Adapted from PIC18F bootloader developed by Ross Fosler
; 03/18/2002	... First full implementation
; 03/25/2002	Modified receive & parse engine to vector to autobaud on a checksum 
;		error since a checksum error could likely be a communications problem.
; 		Modified the protocol to incorporate the autobaud as part of the 
;		first received <STX>. Doing this improves robustness by allowing
;		re-sync under any condition. Previously it was possible to enter a 
;		state where only a hard reset would allow re-syncing.
; 04/09/2002	Fixed bugs: 1) clear carry before shifting ABTIME in Autobaud
;		            2) Increment address in program memory write
;		            3) Increment address in program memory read
; 06/07/2002    Fixed bug in read, byte counter in code is word counter.  Needed
;               to multiply by 2 to get bytes.
;
; Memory Map
;	-----------------
;	|    0x0000	|	Reset vector
;	|        	|
;   	|    0x0004	|	Interrupt vector
;	|    		|	
;	|		|
;	|  Boot Block 	|	(this program)
; 	|		|
;	|    0x0200	|	Re-mapped Reset Vector
;	|    0x0204	|	Re-mapped High Priority Interrupt Vector
;	|		|
;	|	|	|
;	|		|
;    	|  Code Space 	|	User program space
;	|		|
;	|	|	|
;	|		|
;	|    0x3FFF     |
;	-----------------
;
;
; Incomming data format:
;
;	<STX><STX><DATA><CHKSUM><ETX>
;		  /    \
;	 ________/      \____________________________
;	/	                                     \
;	<COMMAND><DLEN><ADDRL><ADDRH><ADDRU><DATA>...
;
; Definitions:
;
; 	STX	-	Start of packet indicator
;	ETX	-	End of packet indicator
; 	LEN 	-	Length of incomming packet
; 	DATA	-	General data up to 255 bytes
; 	CHKSUM 	- 	The 8-bit two's compliment sum of LEN & DATA
; 	COMMAND - 	Base command
; 	DLEN	-	Length of data associated to the command
; 	ADDR	-	Address up to 24 bits
; 	DATA 	-	Data (if any)
;
;
; Commands:
;
; 	RD_VER		0x00	Read Version Information
; 	RD_MEM		0x01	Read Program Memory
; 	WR_MEM		0x02	Write Program Memory
; 	ER_MEM		0x03	Erase Program Memory (NOT supported by PIC16)
; 	RD_EE		0x04	Read EEDATA Memory 
; 	WR_EE		0x05	Write EEDATA Memory 
; 	RD_CONFIG	0x06	Read Config Memory (NOT supported by PIC16)
; 	WT_CONFIG	0x07	Write Config Memory (NOT supported by PIC16)
;
; *****************************************************************************

 

; *****************************************************************************
	#include P16F877A.INC		; Standard include
; *****************************************************************************

	errorlevel -302			; Do not show any banking warnings

; *****************************************************************************
#define	MINOR_VERSION	0x03		; Version
#define	MAJOR_VERSION	0x00

#define	RC_DLE		0x01
#define	RC_STX		0x02

#define	STX		0x0F
#define	ETX		0x04
#define	DLE		0x05

;#define DEBUGGING			; Debugging enabled with ICD
; *****************************************************************************



; *****************************************************************************
CHKSUM		equ	0x71		; Checksum accumulator
COUNTER		equ	0x72		; General counter
ABTIME		equ	0x73
RXDATA		equ	0x74
TXDATA		equ	0x75
TEMP		equ	0x76

PCLATH_TEMP	equ	0x7D		; Interrupt context
STATUS_TEMP	equ	0x7E		; save/restore registers
W_TEMP		equ	0x7F

; Frame Format
;
;  <STX><STX>[<COMMAND><DATALEN><ADDRL><ADDRH><ADDRU><...DATA...>]<CHKSUM><ETX>

DATA_BUFF	equ	0x10		; Start of receive buffer
	
COMMAND		equ	0x10		; Data mapped in receive buffer
DATA_COUNT	equ	0x11	
ADDRESS_L	equ	0x12
ADDRESS_H	equ	0x13
ADDRESS_U	equ	0x14
PACKET_DATA	equ	0x15	
; *****************************************************************************


 
; *****************************************************************************
	ORG	0x0000			; Re-map Reset vector
VReset
	bcf	STATUS,RP0							; B0/B2
	bsf	STATUS,RP1							; B2
	clrf	PCLATH								; B2
	goto	Setup								; B2

	ORG	0x0004
VInt
	movwf	W_TEMP								; ?
	swapf	STATUS,W							; ?
	movwf	STATUS_TEMP							; ?
	clrf	STATUS								; B0
	movf	PCLATH,W							; B0
	movwf	PCLATH_TEMP							; B0
	clrf	PCLATH								; B0
	goto	RVInt			; Re-map Interrupt vector		; B0

; *****************************************************************************



; *****************************************************************************
; Setup the appropriate registers.
Setup	clrwdt
	movlw	0xFF								; B2
	movwf	EEADR			; Point to last location		; B2
	bsf	STATUS,RP0							; B3
	clrf	EECON1								; B3
	bsf	EECON1,RD		; Read the control code			; B3
	bcf	STATUS,RP0							; B2
	incf	EEDATA,W							; B2
	btfsc	STATUS,Z							; B2
	goto	SRX								; B2

	bcf	STATUS,RP1							; B0
	goto	RVReset			; If not 0xFF then normal reset		; B0

SRX	bcf	STATUS,RP1							; B0
	movlw	b'10000000'		; Setup rx and tx, CREN disabled	; B0
	movwf	RCSTA								; B0
	bsf	STATUS,RP0							; B1
	bcf	TRISC,6			; Setup tx pin				; B1
	movlw	b'00100110'							; B1
	movwf	TXSTA								; B1
	bsf	STATUS,IRP							; B1
; *****************************************************************************




; *****************************************************************************
Autobaud
;
; ___	 __________            ________
;    \__/	   \__________/
;       |                     |
;       |-------- p ----------|
;
;	p = The number of instructions between the first and last
;           rising edge of the RS232 control sequence 0x0F. Other 
;	    possible control sequences are 0x01, 0x03, 0x07, 0x1F, 
; 	    0x3F, 0x7F.
;
;	SPBRG = (p / 32) - 1  	BRGH = 1
										; B0/B1/B2
	bcf	STATUS,RP1							; B0/B1
	bsf	STATUS,RP0							; B1
	movlw	b'00000011'							; B1
	movwf	OPTION_REG							; B1
	bcf	STATUS,RP0							; B0
	bcf	RCSTA,CREN							; B0

	call	WaitForRise							; B0
 
	clrf	TMR0			; Start counting			; B0

	call	WaitForRise							; B0

	movf	TMR0,W			; Read the timer			; B0
	movwf	ABTIME								; B0

	bcf	STATUS,C
	rrf	ABTIME,W							; B0
	btfss	STATUS,C		; Rounding				; B0
	addlw	0xFF								; B0

	bsf	STATUS,RP0							; B1
	movwf	SPBRG								; B1
	bcf	STATUS,RP0							; B0
	bsf	RCSTA,CREN		; Enable receive			; B0

	movf	RCREG,W								; B0
	movf	RCREG,W								; B0

	bsf	STATUS,RP0							; B1
	movlw	b'11111111'							; B1
	movwf	OPTION_REG							; B1
; *****************************************************************************



; *****************************************************************************
; Read and parse the data.
StartOfLine									; B1/B2/B0
	bcf	STATUS,RP0							; B0/B2
	bcf	STATUS,RP1							; B0
	call	RdRS232			; Look for a start of line		; B0
	xorlw	STX			; <STX><STX>				; B0
	btfss	STATUS,Z							; B0
	goto	Autobaud		;was StartOfline			; B0

	movlw	DATA_BUFF		; Point to the buffer			; B0
	movwf	FSR								; B0

	clrf	CHKSUM			; Reset checksum			; B0
		
GetNextDat				
	call	RdRS232			; Get the data				; B0
	xorlw	STX			; Check for a STX			; B0
	btfsc	STATUS,Z							; B0
	goto	StartOfLine		; Yes, start over			; B0

NoSTX	movf	RXDATA,W							; B0
	xorlw	ETX			; Check for a ETX			; B0
	btfsc	STATUS,Z							; B0
	goto	CheckSum		; Yes, examine checksum			; B0

NoETX	movf	RXDATA,W							; B0
	xorlw	DLE			; Check for a DLE			; B0
	btfss	STATUS,Z							; B0
	goto	NoDLE			; Check for a DLE			; B0

	call	RdRS232			; Yes, Get the next byte		; B0
	
NoDLE	movf	RXDATA,W							; B0
	movwf	INDF			; Store the data			; B0
	addwf	CHKSUM,F		; Get sum				; B0
	incf	FSR,F								; B0

	goto	GetNextDat							; B0

CheckSum	
	movf	CHKSUM,F		; Checksum test				; B0
	btfss	STATUS,Z							; B0
	goto	Autobaud							; B0
; ***********************************************



; ***********************************************
; Pre-setup, common to all commands.						; B0
	bsf	STATUS,RP1							; B2
	movf	ADDRESS_L,W		; Set all possible pointers		; B2
	movwf	EEADR								; B2
	movf	ADDRESS_H,W							; B2
	movwf	EEADRH								; B2

	movlw	PACKET_DATA							; B2
	movwf	FSR								; B2

	movf	DATA_COUNT,W 		; Setup counter				; B2
	movwf	COUNTER								; B2
	btfsc	STATUS,Z							; B2
	goto	VReset			; Non valid count (Special Command)	; B2
; ***********************************************

 

; ***********************************************
; Test the command field and sub-command.					; B2
CheckCommand
	movf	COMMAND,W		; Test for a valid command		; B2
	sublw	d'7'								; B2
	btfss	STATUS,C							; B2
	goto	Autobaud							; B2

	movf	COMMAND,W		; Perform calculated jump		; B2
	addwf	PCL,F								; B2
	
	goto	ReadVersion		; 0					; B2
	goto	ReadProgMem		; 1					; B2
	goto	WriteProgMem		; 2					; B2
	goto	StartOfLine		; 3					; B2
	goto	ReadEE			; 4					; B2
	goto	WriteEE			; 5					; B2
	goto	StartOfLine		; 6					; B2
	goto	StartOfLine		; 7					; B2
;maybe add jump to reset vector in this table
; ***********************************************



; ***********************************************
; Commands
; 
; In:	<STX><STX>[<0x00><0x02>]<0xFF><ETX>
; OUT:	<STX><STX>[<0x00><VERL><VERH>]<CHKSUM><ETX>
ReadVersion									; B2
	movlw	MINOR_VERSION							; B2
	movwf	DATA_BUFF + 2							; B2
	movlw	MAJOR_VERSION							; B2
	movwf	DATA_BUFF + 3							; B2

	movlw	0x04								; B2
	goto	WritePacket							; B2


; In:	<STX><STX>[<0x01><DLEN><ADDRL><ADDRH><ADDRU>]<CHKSUM><ETX>
; OUT:	<STX><STX>[<0x01><DLEN><ADDRL><ADDRH><ADDRU><DATA>...]<CHKSUM><ETX>
ReadProgMem									; B2
RPM1	bsf	STATUS,RP0							; B3
	bsf	EECON1,EEPGD							; B3
	bsf	EECON1,RD							; B3
	nop									; B3
	nop									; B3
	bcf	STATUS,RP0							; B2
	movf	EEDATA,W							; B2
	movwf	INDF								; B2
	incf	FSR,F								; B2
	movf	EEDATH,W							; B2
	movwf	INDF								; B2
	incf	FSR,F								; B2

	incf	EEADR,F								; B2
	btfsc	STATUS,Z							; B2
	incf	EEADRH,F							; B2

	decfsz	COUNTER,F							; B2
	goto	RPM1			; Not finished then repeat		; B2

	rlf	DATA_COUNT,W		; Setup packet length			; B2
	addlw	0x05								; B2
				
	goto	WritePacket							; B2


; In:	<STX><STX>[<0x02><DLENBLOCK><ADDRL><ADDRH><ADDRU><DATA>...]<CHKSUM><ETX>
; OUT:	<STX><STX>[<0x02>]<CHKSUM><ETX>
WriteProgMem									; B2
	bsf	STATUS,RP0							; B3
	movlw	b'10000100'		; Setup writes				; B3
	movwf	EECON1								; B3
	bcf	STATUS,RP0							; B2
	movlw	b'11111100'		; Force a boundry			; B2
	andwf	EEADR,F								; B2
 
	movlw	0x04								; B2
	movwf	TEMP								; B2

Lp1	
	movf	INDF,W								; B2
	movwf	EEDATA								; B2
	incf	FSR,F								; B2
	movf	INDF,W								; B2
	movwf	EEDATH								; B2
	incf	FSR,F								; B2
	call	StartWrite							; B2

	incf	EEADR,F								; B2
	btfsc	STATUS,Z							; B2
	incf	EEADRH,F							; B2

	decfsz	TEMP,F								; B2
	goto	Lp1								; B2

	decfsz	COUNTER,F							; B2
	goto	WriteProgMem		; Not finished then repeat		; B2

	goto	SendAcknowledge		; Send acknowledge			; B2


; In:	<STX><STX>[<0x04><DLEN><ADDRL><ADDRH><0x00>]<CHKSUM><ETX>
; OUT:	<STX><STX>[<0x04><DLEN><ADDRL><ADDRH><0x00><DATA>...]<CHKSUM><ETX>
ReadEE										; B2
	bsf	STATUS,RP0							; B3
	clrf	EECON1 								; B3

	bsf	EECON1,RD		; Read the data				; B3
	bcf	STATUS,RP0							; B2
	movf	EEDATA,W							; B2
	movwf	INDF								; B2
	incf	FSR,F								; B2
	
	incf	EEADR,F			; Adjust EEDATA pointer			; B2

	decfsz	COUNTER,F							; B2
	goto	ReadEE			; Not finished then repeat		; B2

	movf	DATA_COUNT,W		; Setup packet length			; B2
	addlw	0x05								; B2
				
	goto	WritePacket							; B2


; In:	<STX><STX>[<0x05><DLEN><ADDRL><ADDRH><0x00><DATA>...]<CHKSUM><ETX>
; OUT:	<STX><STX>[<0x05>]<CHKSUM><ETX>
WriteEE										; B2
	movf	INDF,W								; B2
	movwf	EEDATA								; B2
	incf	FSR,F								; B2
	call	WriteWaitEEData		; Write data				; B2

	incf	EEADR,F			; Adjust EEDATA pointer			; B2

	decfsz	COUNTER,F							; B2
	goto	WriteEE			; Not finished then repeat		; B2

	goto	SendAcknowledge		; Send acknowledge			; B2
; ***********************************************



; ***********************************************
; Send the data buffer back.
;
; <STX><STX>[<DATA>...]<CHKSUM><ETX>

SendAcknowledge									; B2
	movlw	0x01			; Send acknowledge			; B2
										; B2
WritePacket
	movwf	COUNTER								; B2

	movlw	STX			; Send start condition			; B2
	call	WrRS232								; B2
	call	WrRS232								; B0

	clrf	CHKSUM			; Reset checksum			; B0

	movlw	DATA_BUFF		; Setup pointer to buffer area		; B0
	movwf	FSR								; B0
	
SendNext				; Send DATA
	movf	INDF,W								; B0
	addwf	CHKSUM,F							; B0
	incf	FSR,F								; B0
	call	WrData								; B0
	decfsz	COUNTER,F							; B0
	goto	SendNext							; B0

	comf	CHKSUM,W		; Send checksum				; B0
	addlw	0x01								; B0
	call	WrData								; B0

	movlw	ETX			; Send stop condition			; B0
	call	WrRS232								; B0

	goto	Autobaud							; B0
; *****************************************************************************




; *****************************************************************************
; Write a byte to the serial port.

WrData										; B0
	movwf	TXDATA			; Save the data				; B0

	xorlw	STX			; Check for a STX			; B0
	btfsc	STATUS,Z							; B0
	goto	WrDLE			; No, continue WrNext			; B0

	movf	TXDATA,W							; B0
	xorlw	ETX			; Check for a ETX			; B0
	btfsc	STATUS,Z							; B0
	goto	WrDLE			; No, continue WrNext			; B0

	movf	TXDATA,W							; B0
	xorlw	DLE			; Check for a DLE			; B0
	btfss	STATUS,Z							; B0
	goto	WrNext			; No, continue WrNext			; B0

WrDLE
	movlw	DLE			; Yes, send DLE first			; B0
	call	WrRS232								; B0

WrNext
	movf	TXDATA,W		; Then send STX				; DC

WrRS232										; B2/B0
	clrwdt									; B2
	bcf	STATUS,RP1							; B0
	btfss	PIR1,TXIF		; Write only if TXREG is ready		; B0
	goto	$ - 1								; B0
	
	movwf	TXREG			; Start sending				; B0

	return									; B0
; *****************************************************************************




; *****************************************************************************
RdRS232										; B0
	clrwdt									; B0

	btfsc	RCSTA,OERR		; Reset on overun			; B0
	goto	VReset								; B0

	btfss	PIR1,RCIF		; Wait for data from RS232		; B0
	goto	$ - 1								; B0

	movf	RCREG,W			; Save the data				; B0
	movwf	RXDATA								; B0
 
	return									; B0
; *****************************************************************************




; *****************************************************************************
WaitForRise									; B0
	btfsc	PORTC,7			; Wait for a falling edge		; B0
	goto	WaitForRise							; B0
	clrwdt				;;; Do we need this?			; B0
WtSR	btfss	PORTC,7			; Wait for starting edge		; B0
	goto	WtSR								; B0
	return									; B0
; *****************************************************************************




; *****************************************************************************
; Unlock and start the write or erase sequence.

StartWrite									; B3
	clrwdt									; B2
	bsf	STATUS,RP0							; B3
	movlw	0x55			; Unlock				; B3
	movwf	EECON2								; B3
	movlw	0xAA								; B3
	movwf	EECON2								; B3
	bsf	EECON1,WR		; Start the write			; B3
	nop									; B3
	nop									; B3
	bcf	STATUS,RP0							; B2
	return									; B2
; *****************************************************************************




; *****************************************************************************
WriteWaitEEData									; B2
	bsf	STATUS,RP0							; B3
	movlw	b'00000100'		; Setup for EEData			; B3
	movwf	EECON1								; B3
	call	StartWrite							; B3
	btfsc	EECON1,WR		; Write and wait			; B3
	goto	$ - 1								; B3
	bcf	STATUS,RP0							; B2
	return									; B2
; *****************************************************************************


; *****************************************************************************
	ORG	0x100
RVReset					

	ORG	0x104
RVInt

; *****************************************************************************


	END
