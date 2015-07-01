; *****************************************************************************
;        Software License Agreement				    
;								    
; The software supplied herewith by Microchip Technology 	    
; Incorporated (the �Company�) for its PICmicro� Microcontroller is 
; intended and supplied to you, the Company�s customer, for use     
; solely and exclusively on Microchip PICmicro Microcontroller	    
; products. The software is owned by the Company and/or its         
; supplier, and is protected under applicable copyright laws. All   
; rights are reserved. Any use in violation of the foregoing 	     
; restrictions may subject the user to criminal sanctions under	    
; applicable laws, as well as to civil liability for the breach of  
; the terms and conditions of this license.			    
;								    
; THIS SOFTWARE IS PROVIDED IN AN �AS IS� CONDITION. NO WARRANTIES, 
; WHETHER EXPRESS, IMPLIED OR STATUTORY, INCLUDING, BUT NOT LIMITED 
; TO, IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A 	    
; PARTICULAR PURPOSE APPLY TO THIS SOFTWARE. THE COMPANY SHALL NOT, 
; IN ANY CIRCUMSTANCES, BE LIABLE FOR SPECIAL, INCIDENTAL OR 	    
; CONSEQUENTIAL DAMAGES, FOR ANY REASON WHATSOEVER.		    
;								    
;					 			    
; Bootloader for PIC18F by Ross Fosler
; 03/01/2002	... First full implementation
; 03/07/2002	Changed entry method to use last byte of EEDATA.
;		Also removed all possible infinite loops w/ clrwdt.
; 03/07/2002	Added code for direct boot entry. I.E. boot vector.
; 03/09/2002	Changed the general packet format, removed the LEN field.
;
; Revisions by GA Anderson
; 2007 or so is the first use and no notes on updates.
; 01/10/2010	Added the startup switch tests for the MicroProStar. Added
;		conditional assembly switch.
;
; Memory Map
;	-----------------
;	|    0x0000	|
;	|    0x0002    	|	Boot vector
;   	|    0x0004	|	Unlock & write vector
;	|    		|	
;	|		|
;	|  Boot Block 	|	(this program)
; 	|		|
;	|    0x0200	|	Re-mapped Reset Vector
;	|    0x0208	|	Re-mapped High Priority Interrupt Vector
;	|    0x0218	|	Re-mapped Low Priority Interrupt Vector
;	|		|
;	|	|	|
;	|		|
;    	|  Code Space 	|
;	|		|
;	|	|	|
;	|		|
;	|    0x7FFE     |
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
; 	ER_MEM		0x03	Erase Program Memory
; 	RD_EE		0x04	Read EEDATA Memory 
; 	WR_EE		0x05	Write EEDATA Memory 
; 	RD_CONFIG	0x06	Read Config Memory 
; 	WT_CONFIG	0x07	Write Config Memory 
;
; *****************************************************************************

 

; *****************************************************************************
;	#include P18F452.INC		; Standard include
	list      p=18F8722            ; list directive to define processor
	#include <P18F8722.INC>         ; processor specific variable definitions
	errorlevel 2
; *****************************************************************************



; *****************************************************************************
#define	MINOR_VERSION	0x04		; Version
#define	MAJOR_VERSION	0x01

#define	RC_DLE		0x01
#define	RC_STX		0x02

#define	STX		0x0F
#define	ETX		0x04
#define	DLE		0x05

;#define	MicroProStar			; Uncomment this def to build MicroProStar
					; version.
; *****************************************************************************



; *****************************************************************************
CHKSUM		equ	0x00		; Checksum accumulator
COUNTER		equ	0x01		; General counter
ABTIME_H	equ	0x02
ABTIME_L	equ	0x03
RXDATA		equ	0x04
TXDATA		equ	0x05

; Frame Format
;
;  <STX><STX>[<COMMAND><DATALEN><ADDRL><ADDRH><ADDRU><...DATA...>]<CHKSUM><ETX>

DATA_BUFF	equ	0x08		; Start of receive buffer
	
COMMAND		equ	0x08		; Data mapped in receive buffer
DATA_COUNT	equ	0x09	
ADDRESS_L	equ	0x0A
ADDRESS_H	equ	0x0B
ADDRESS_U	equ	0x0C
PACKET_DATA	equ	0x0D	
; *****************************************************************************


 
; *****************************************************************************
	ORG	0x0000			; Re-map Reset vector
	bra	Setup	
	bra	BootMode
	bra	StartWrite
	bra	WriteWaitEEData		

	ORG	0x0008
VIntH
	bra	RVIntH			; Re-map Interrupt vector

	ORG	0x0018
VIntL
	bra	RVIntL			; Re-map Interrupt vector
; *****************************************************************************



; *****************************************************************************
; Setup the appropriate registers.
Setup	clrwdt
   ; If port E bits 0, 1, and 2 are low (Run/Cal, Auto Trim, and Option) then do
   ; not start, stay in bootloader. This is the port and bit numbers for the 
   ; rev 4.0 and later MicroStar.
   ; For the MicroProStar its Port J bits 1,3, and 7. The AND mask is 8A (hex).
ifdef	MicroProStar
	MOVF	PORTJ,W,A
	ANDLW	8A
else
	MOVF	PORTE,W,A
	ANDLW	03
endif
	BZ	Setup1
	clrf	EECON1
	setf	EEADR			; Point to last location
	setf	EEADRH			
	bsf	EECON1, RD		; Read the control code
	incfsz	EEDATA, W
	bra	RVReset			; If not 0xFF then normal reset
Setup1
	bcf	TRISC, 6		; Setup tx pin
;	bsf	TRISC, 7		; Setup rx pin

	movlw	b'10010000'		; Setup rx and tx
	movwf	RCSTA1
	movlw	b'00100110'		
	movwf	TXSTA1

;	clrf	TRISB
;	btg	LATB, 0
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

	movlw	b'00001111'
	movwf	T0CON
	clrf	TMR0H
	clrf	TMR0L

	rcall	WaitForRise
 
	bsf	T0CON, TMR0ON		; Start counting

	rcall	WaitForRise

	bcf	T0CON, TMR0ON		; Stop counting

	movff	TMR0L, ABTIME_L		; Read the timer
	movff	TMR0H, ABTIME_H

	movlw	0x05			; divide by 32
DivB32	rrcf	ABTIME_H, F
	rrcf	ABTIME_L, F
	decfsz	WREG, F
	bra	DivB32
	btfss	STATUS, C		; Rounding
	decf	ABTIME_L, F
	
	movff	ABTIME_L, SPBRG1	; Sync
; *****************************************************************************



; *****************************************************************************
; Read and parse the data.
StartOfLine
	rcall	RdRS232			; Look for a start of line
	xorlw	STX			; <STX><STX>
	bnz	StartOfLine		

HalfStart
	rcall	RdRS232			
	xorlw	STX
	bnz	StartOfLine		; Otherwise go back for another character

	lfsr	0, DATA_BUFF		; Point to the buffer

	clrf	CHKSUM			; Reset checksum		
	clrf	COUNTER			; Reset buffer count
		
GetNextDat				
	rcall	RdRS232			; Get the data
	xorlw	STX			; Check for a STX
	bz	HalfStart		; Yes, start over	

NoSTX	movf	RXDATA, W
	xorlw	ETX			; Check for a ETX
	bz	CheckSum		; Yes, examine checksum		

NoETX	movf	RXDATA, W
	xorlw	DLE			; Check for a DLE
	bnz	NoDLE

	rcall	RdRS232			; Yes, Get the next byte
	
NoDLE	movf	RXDATA, W

	addwf	CHKSUM, F		; Get sum
	movwf	POSTINC0		; Store the data

	dcfsnz	COUNTER, F		; Limit buffer to 256 bytes
	bra	StartOfLine

	bra	GetNextDat

CheckSum	
	movf	CHKSUM			; Checksum test
	bnz	StartOfLine
; ***********************************************



; ***********************************************
; Pre-setup, common to all commands.
	movf	ADDRESS_L, W		; Set all possible pointers
	movwf	TBLPTRL
	movwf	EEADR
	movf	ADDRESS_H, W
	movwf	TBLPTRH
	movwf	EEADRH
	movff	ADDRESS_U, TBLPTRU

	lfsr	FSR0, PACKET_DATA

	movf	DATA_COUNT, W 		; Setup counter
	movwf	COUNTER
	btfsc	STATUS, Z
	reset				; Non valid count (Special Command)
; ***********************************************

 

; ***********************************************
; Test the command field and sub-command.
CheckCommand
	movf	COMMAND, W		; Test for a valid command			
	sublw	d'7'
	bnc	StartOfLine

	clrf	PCLATH			; Setup for a calculated jump
	clrf	PCLATU
		
	rlncf	COMMAND, W		; Jump
	addwf	PCL, F
	
	bra	ReadVersion
	bra	ReadProgMem
	bra	WriteProgMem
	bra	EraseProgMem
	bra	ReadEE
	bra	WriteEE
	bra	ReadProgMem	;ReadConfig
	bra	WriteConfig
; ***********************************************



; ***********************************************
; Commands
; 
; In:	<STX><STX>[<0x00><0x02>]<0xFF><ETX>
; OUT:	<STX><STX>[<0x00><VERL><VERH>]<CHKSUM><ETX>
ReadVersion
	movlw	MINOR_VERSION
	movwf	DATA_BUFF + 2
	movlw	MAJOR_VERSION
	movwf	DATA_BUFF + 3

	movlw	0x03
	bra	WritePacket


; In:	<STX><STX>[<0x01><DLEN><ADDRL><ADDRH><ADDRU>]<CHKSUM><ETX>
; OUT:	<STX><STX>[<0x01><DLEN><ADDRL><ADDRH><ADDRU><DATA>...]<CHKSUM><ETX>
ReadProgMem
	tblrd	*+			; Fill buffer
	movff	TABLAT, POSTINC0

	decfsz	COUNTER, F		
	bra	ReadProgMem		; Not finished then repeat

	movf	DATA_COUNT, W		; Setup packet length
	addlw	0x05
				
	bra	WritePacket


; In:	<STX><STX>[<0x02><DLENBLOCK><ADDRL><ADDRH><ADDRU><DATA>...]<CHKSUM><ETX>
; OUT:	<STX><STX>[<0x02>]<CHKSUM><ETX>
WriteProgMem
	movlw	b'11111000'		; Force a boundry
	andwf	TBLPTRL, F
 
	movlw	0x08

Lp1	movff	POSTINC0, TABLAT	; Load the holding registers
	tblwt	*+
	decfsz	WREG, F
	bra	Lp1
 
	tblrd	*-			; Point back into the block

	movlw	b'10000100'		; Setup writes
	movwf	EECON1
	rcall	StartWrite		; Write the data

	tblrd	*+			; Point to the beginning of the next block

	decfsz	COUNTER, F		
	bra	WriteProgMem		; Not finished then repeat

	bra	SendAcknowledge		; Send acknowledge


; In:	<STX><STX>[<0x03><DLENROW><ADDRL><ADDRH><ADDRL>]<CHKSUM><ETX>
; OUT:	<STX><STX>[<0x03>]<CHKSUM><ETX>
EraseProgMem
	movlw	b'10010100'		; Setup writes
	movwf	EECON1

	rcall	StartWrite		; Erase the row

	movlw	0x40			; Point to next row
	addwf	TBLPTRL, F
	clrf	WREG
	addwfc	TBLPTRH, F
	addwfc	TBLPTRU, F

	decfsz	COUNTER, F
	bra	EraseProgMem	

	bra	SendAcknowledge		; Send acknowledge


; In:	<STX><STX>[<0x04><DLEN><ADDRL><ADDRH><0x00>]<CHKSUM><ETX>
; OUT:	<STX><STX>[<0x04><DLEN><ADDRL><ADDRH><0x00><DATA>...]<CHKSUM><ETX>
ReadEE
	clrf	EECON1 

	bsf	EECON1, RD		; Read the data
	movff	EEDATA, POSTINC0
	
	infsnz	EEADR, F		; Adjust EEDATA pointer
	incf	EEADRH, F

	decfsz	COUNTER, F
	bra	ReadEE			; Not finished then repeat

	movf	DATA_COUNT, W		; Setup packet length
	addlw	0x05
				
	bra	WritePacket


; In:	<STX><STX>[<0x05><DLEN><ADDRL><ADDRH><0x00><DATA>...]<CHKSUM><ETX>
; OUT:	<STX><STX>[<0x05>]<CHKSUM><ETX>
WriteEE	

	movff	POSTINC0, EEDATA
	rcall	WriteWaitEEData		; Write data

	infsnz	EEADR, F		; Adjust EEDATA pointer
	incf	EEADRH, F

	decfsz	COUNTER, F		
	bra	WriteEE			; Not finished then repeat

	bra	SendAcknowledge		; Send acknowledge
 

; In:	<STX><STX>[<0x06><DLEN><ADDRL><ADDRH><ADDRU>]<CHKSUM><ETX>
; OUT:	<STX><STX>[<0x06><DLEN><ADDRL><ADDRH><ADDRU><DATA>...]<CHKSUM><ETX>
;ReadConfig
;	movlw	b'11000000'
;	movwf	EECON1
;
;Lp5	tblrd	*+
;	movff	TABLAT, POSTINC0
;
;	decfsz	COUNTER, F
;	bra	Lp5			; Not finished then repeat
;
;	movf	DATA_COUNT, W		; Setup packet length
;	addlw	0x05
;
;	bra	WritePacket


; In:	<STX><STX>[<0x07><DLEN><ADDRL><ADDRH><ADDRU><DATA>...]<CHKSUM><ETX>
; OUT:	<STX><STX>[<0x07>]<CHKSUM><ETX>
WriteConfig
	movlw	b'11000100'
	movwf	EECON1

	movff	POSTINC0, TABLAT	; Write to config area
	tblwt	*+

	rcall	StartWrite

	decfsz	COUNTER, F
	bra	WriteConfig		; Not finished then repeat
		
	bra	SendAcknowledge		; Send acknowledge
; ***********************************************



; ***********************************************
; Send the data buffer back.
;
; <STX><STX>[<DATA>...]<CHKSUM><ETX>

SendAcknowledge
	movlw	0x01			; Send acknowledge

WritePacket
	movwf	COUNTER

	movlw	STX			; Send start condition
	rcall	WrRS232
	rcall	WrRS232

	clrf	CHKSUM			; Reset checksum

	lfsr	FSR0, DATA_BUFF		; Setup pointer to buffer area	
	
SendNext				; Send DATA
	movf	POSTINC0, W
	addwf	CHKSUM
	rcall	WrData
	decfsz	COUNTER, F
	bra	SendNext

	negf	CHKSUM			; Send checksum
	movf	CHKSUM, W
	rcall	WrData

	movlw	ETX			; Send stop condition
	rcall	WrRS232

	bra	StartOfLine
; *****************************************************************************




; *****************************************************************************
; Write a byte to the serial port.

WrData
	movwf	TXDATA			; Save the data
 
	xorlw	STX			; Check for a STX
	bz	WrDLE			; No, continue WrNext

	movf	TXDATA, W		
	xorlw	ETX			; Check for a ETX
	bz	WrDLE			; No, continue WrNext

	movf	TXDATA, W		
	xorlw	DLE			; Check for a DLE
	bnz	WrNext			; No, continue WrNext

WrDLE
	movlw	DLE			; Yes, send DLE first
	rcall	WrRS232

WrNext
	movf	TXDATA, W		; Then send STX

WrRS232
	clrwdt
	btfss	PIR1, TXIF		; Write only if TXREG is ready
	bra	$ - 2
	
	movwf	TXREG1			; Start sending

	return
; *****************************************************************************




; *****************************************************************************
RdRS232
	clrwdt

	btfsc	RCSTA1, OERR		; Reset on overun
	reset

	btfss	PIR1, RCIF		; Wait for data from RS232
	bra	$ - 2			

	movf	RCREG1, W		; Save the data
	movwf	RXDATA
 
	return
; *****************************************************************************




; *****************************************************************************
BootMode
	setf	EEADR			; Point to the last byte
	setf	EEADRH
	setf	EEDATA			; Bootmode control byte
	rcall	WriteWaitEEData
	reset
; *****************************************************************************




; *****************************************************************************
WaitForRise
	btfsc	PORTC, 7		; Wait for a falling edge
	bra	WaitForRise
	clrwdt
WtSR	btfss	PORTC, 7		; Wait for starting edge
	bra	WtSR
	return
; *****************************************************************************




; *****************************************************************************
; Unlock and start the write or erase sequence.

StartWrite
	clrwdt

	movlw	0x55			; Unlock
	movwf	EECON2
	movlw	0xAA
	movwf	EECON2
	bsf	EECON1, WR		; Start the write
	nop

	return
; *****************************************************************************




; *****************************************************************************
	ORG	0x000A

WriteWaitEEData
	movlw	b'00000100'		; Setup for EEData
	movwf	EECON1
	rcall	StartWrite		
	btfsc	EECON1, WR		; Write and wait
	bra	$ - 2		
	return
; *****************************************************************************








; *****************************************************************************
	ORG	0x200
RVReset					
;	clrf	TRISB
;	btg	LATB, 0
	


	ORG	0x208
RVIntH

	ORG	0x218
RVIntL
; *****************************************************************************


	END