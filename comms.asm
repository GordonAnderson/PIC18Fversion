;
; RS232 function. 
;	USART1 is used by a host computer to configure the transmitter
;	USART2 support three different modes of operation
;		1.) The buddy box system that allows two microstar
;		    systems to be used in a student and master mode.
;		2.) The FMS mode to support the free FMS flight simulator.
;		    This code is found in the FMS.asm file.
;		3.) The serial position data sending function. This mode
;		    sends the position data at full resolution. 
;
;
; This function is called in the main polling loop. This function
; reads and processes messages that are found in the command buffer.
; The command buffer is filled by the receiver interrupt service
; routine.
;
; Valid commands are:
; 	31 = Read general data from flash
;	32 = Read selected aircraft data from flash
;	33 = Write general data to flash
;	34 = Write selected aircraft data to flash
;	35 = Reset the flash programmed flag
;
ProcessCommand
	; Test the command flag and process any requests
		MOVLB	HIGH Cmd
		MOVLW	31		; Read general reg
		CPFSEQ	Cmd
		GOTO	Not31
		; Here if its a read general command
		CALL	LoadGeneral
		GOTO	CmdEnd
Not31
		MOVLW	32
		CPFSEQ	Cmd
		GOTO	Not32
		; Here if its a read aircraft data command
		MOVFF	Aircraft,WREG
		CALL	LoadAircraft
		GOTO	CmdEnd
Not32
		MOVLW	33		; Write general reg
		CPFSEQ	Cmd
		GOTO	Not33
		; Here if its a write general command
		CALL	SaveGeneral	
		GOTO	CmdEnd
Not33	
		MOVLW	34		; Write aircraft data
		CPFSEQ	Cmd
		GOTO	Not34
		; Here if its a write aircraft data command
		MOVFF	Aircraft,WREG
		CALL	SaveAircraft
Not34
		MOVLW	35		; Reset the boot flag in EEPROM, this
					; will enable the boot loader on reset
		CPFSEQ	Cmd
		GOTO	CmdEnd
		; Here if its reset the boot flag command, set location 1023 in
		; EEprom to FF hex.
		MOVEC	D'1023',AXreg
		MOVFF	WREG,AXreg+1
		MOVLW	0xFF
		CALL	EEPROMwriteByte
		GOTO	CmdEnd
CmdEnd
		CLRF	Cmd
		RETURN

; The following USART reset functions test the status bits and if
; an overrun error is detected the USART is reset
USART1reset
		MOVLB	HIGH RCSTA1
		BTFSS	RCSTA1,OERR
		RETURN
		; Here with an overrun
		BCF	RCSTA1,CREN
		BSF	RCSTA1,CREN
		; Empty the receive buffer
		MOVLB	HIGH RCREG1
		MOVF	RCREG1,W
		; Clear the message state
		MOVLB	HIGH MessState
		CLRF	MessState
		RETURN

USART2reset
		MOVLB	HIGH RCSTA2
		BTFSS	RCSTA2,OERR
		RETURN
		; Here with an overrun
		BCF	RCSTA2,CREN
		BSF	RCSTA2,CREN
		; Empty the receive buffer
		MOVLB	HIGH RCREG2
		MOVF	RCREG2,W
		RETURN

; This function configures USATRT1. The baud rate is set to 9600 and
; the receiver interrupts are enabled. UART 1 is used to communicate with
; The PC application.
USART1init
	; Baudrate generator
		MOVLW	D'12'		; 9600 baud
		MOVFF	WREG,SPBRG1
	; Enable transmitter
		MOVLW	22
		MOVFF	WREG,TXSTA1
	; Receiver
		MOVLW	90
		MOVFF	WREG,RCSTA1
	; Message receive variables
		MOVLB	HIGH MessState
		CLRF	MessState
	; Set interrupt priority to low and enable
		BCF	IPR1,RC1IP,A		; Low priority
		BSF	PIE1,RC1IE,A		; Enable the interrupt
		RETURN

USART1sendChar
	; Wait for xmit ready...
USC1
		BTFSS	TXSTA1,TRMT,A
		GOTO	USC1
	; Send it
		MOVFF	WREG,TXREG1
		RETURN

; This function configures USATRT2. The baud rate is set to 115200 and
; the receiver interrupts are enabled. UART 2 is used for the buddy box operation.
; USART2 is also used in the serial send mode, if this mode is selected
; the baud rate is set at 38400.
USART2init
	; Set baudrate to 38400 for the SendSerial mode
		MOVLW	D'12'			; 12 will give a 38400 baud rate, 3 is 115200
		MOVFF	WREG,SPBRG2
	; Test if SerialSend mode is enabled
		MOVFF	SerialSend,WREG
		TSTFSZ	WREG,A
		GOTO	U2set
 	; Set baudrate at 115200 baud for the buddy box mode
		MOVLW	D'3'			; 12 will give a 38400 baud rate, 3 is 115200
		MOVFF	WREG,SPBRG2
	; Disable 16 bit baudrate mode
U2set
		BCF	BAUDCON2,BRG16,A
	; Enable transmitter
		MOVLW	26
		MOVFF	WREG,TXSTA2
	; Receiver
		MOVLW	90
		MOVFF	WREG,RCSTA2
	; Set interrupt priority to low and enable
		BCF	IPR3,RC2IP,A		; Low priority
		BSF	PIE3,RC2IE,A		; Enable the interrupt
		RETURN

USART2sendEmpty
	; Wait for xmit ready...
USE2
		BTFSS	TXSTA2,TRMT,A
		GOTO	USE2
		RETURN

USART2sendChar
	; Wait for xmit ready...
USC2
		BTFSS	TXSTA2,TRMT,A
		GOTO	USC2
	; Send it
		MOVFF	WREG,TXREG2
		RETURN

;
; This function will send data out UART channel 1. The data will be
; read at the address in indirect register FSR1. FSR1 will be setup 
; by this call. The following registers are assumed defined
; when this call is made:
;
;	MessBank  = Bank for source
;	MessLoc   = Address of source data
;	MessLen   = Number of bytes to send
;
USART1send
    ; Save the FSR1 register data
		MOVFF	FSR1L, FSR1Lsave
		MOVFF	FSR1H, FSR1Hsave
	; Setup FSR1
		MOVLB	HIGH MessLoc
		MOVFF	MessLoc,FSR1L
		MOVLB	HIGH MessBank
		MOVFF	MessBank,FSR1H
		CLRF	CheckSum
	; Wait for Xmitter buffer to empty
US1
		BTFSS	TXSTA1,TRMT
		GOTO	US1
	; Now read the char from the buffer and send it
		MOVFF	POSTINC1,WREG
		MOVLB	HIGH CheckSum
		ADDWF	CheckSum
		MOVFF	WREG,TXREG1
	; Check the loop counter...
		MOVLB	HIGH MessLen
		DECFSZ	MessLen
		GOTO	US1
	; Restore regs...
		MOVFF	FSR1Lsave, FSR1L
		MOVFF	FSR1Hsave, FSR1H
		RETURN

;
; This function will receive data from UART channel 1. The data will be
; saved at the address in indirect register FSR1. FSR1 will be setup 
; by this call. The following registers are assumed defined
; when this call is made:
;
;	MessBank  = Bank for destination
;	MessLoc   = Address of destanation data
;	MessLen   = Number of bytes to receive
;
USART1in
    ; Save the FSR1 register data
		MOVFF	FSR1L, FSR1Lsave
		MOVFF	FSR1H, FSR1Hsave
	; Setup FSR1
		MOVLB	HIGH MessLoc
		MOVFF	MessLoc,FSR1L
		MOVLB	HIGH MessBank
		MOVFF	MessBank,FSR1H
		CLRF	CheckSum
;		MOVLW	0
;		CPFSGT	MessLen
;		RETURN
	; Wait for Receiver buffer to fill, or a timeout
UI1
		MOVLB	HIGH TimeOut
		MOVLW	d'5'
		MOVWF	TimeOut
		CLRF	WREG
UI1a
		CPFSGT	TimeOut
		GOTO	UI2
		BTFSS	PIR1,RC1IF
		GOTO	UI1a
	; Now read the char from the UART and save it
		MOVFF	RCREG1,WREG
		MOVFF	WREG,POSTINC1
		MOVLB	HIGH CheckSum
		ADDWF	CheckSum
	; Check the loop counter...
		MOVLB	HIGH MessLen
		DECFSZ	MessLen
		GOTO	UI1
	; Restore regs...
UI2
		MOVFF	FSR1Lsave, FSR1L
		MOVFF	FSR1Hsave, FSR1H
		RETURN

;Cmd		RES	1	; This flag is set by a host PC to
;   				; request an action.
;
; The following variables are used by USART1 serial receiver. Receive messages
; are in the following format:
;		1 byte, start of message = 0x55
;		1 byte, message type
;		1 byte, Bank address
;		1 byte, location
;		1 byte, data length
;		(optional data block if its a receive message)
;		1 byte, mod 256 checksum
; Valid message types are:
;	1 = Reveive message, from host
;	2 = Send message, to host
; Valid commands are:
; 	31 = Read general data from flash
;	32 = Read selected aircraft data from flash
;	33 = Write general data to flash
;	34 = Write selected aircraft data to flash
;	35 = Reset the flash programmed flag
;
;RECMESS	EQU	1
;SENDMESS	EQU	2
;ACK		EQU	D'12'
;NAK		EQU	D'13'
;
USART1rec
	; Look for a character in the input buffer
		BTFSS	PIR1,RC1IF
		RETURN
	; Here with a character, test state and jump to correct 
	; entry point
		MOVLB	HIGH MessState
		MOVLW   0
		CPFSEQ	MessState
		GOTO	UR1
	; Here if state is 0, looking for a start of message byte
		MOVFF	RCREG1,WREG
		MOVFF	WREG,MessStart
		MOVLW	55
		CPFSEQ	MessStart
		RETURN
		; Advance the state... and set the message timeout value
		MOVLW	D'40'
		MOVFF	WREG,TimeOut1
		INCF	MessState
		RETURN
UR1
		MOVLW	1
		CPFSEQ	MessState
		GOTO	UR2
	; Here if state is 1, looking for a message command
		MOVFF	RCREG1,WREG
		MOVFF	WREG,MessType
		INCF	MessState
		RETURN
UR2
		MOVLW	2
		CPFSEQ	MessState
		GOTO	UR3
	; Here if state is 2, looking for a bank address
		MOVFF	RCREG1,WREG
		MOVFF	WREG,MessBank
		INCF	MessState
		RETURN
UR3
		MOVLW	3
		CPFSEQ	MessState
		GOTO	UR4
	; Here if state is 3, looking for a location byte
		MOVFF	RCREG1,WREG
		MOVFF	WREG,MessLoc
		INCF	MessState
		RETURN

UR4
		MOVLW	4
		CPFSEQ	MessState
		GOTO	UR5
	; Here if state is 4, looking for number of bytes in message
		MOVFF	RCREG1,WREG
		MOVFF	WREG,MessLen
		INCF	MessState
	; Fall into state 5, no character input is needed for this state transistion
UR5
		MOVLW	5
		CPFSEQ	MessState
		GOTO	UR6
	; Here if state is 5, Now we send or receive the message
		; If message type is receive then call the message block
		; receive function here... else advance to the next state
		; and get the checksum...
		MOVLW	RECMESS
		CPFSEQ	MessType
		GOTO	UR5a
		; Here if its a rec message type so call the rec mess function
		CALL	USART1in
UR5a
		INCF	MessState
		RETURN
UR6
		MOVLW	6
		CPFSEQ	MessState
		GOTO	UR7
	; Here if state is 6, Read the checksum
		MOVFF	RCREG1,WREG
		MOVFF	WREG,MessCHK
	; Validate message and send the response:
	;   If we just received a message compare the checksums and send
	;   ACK or NAK.
	;   If this is a send message then igore the checksum and send the data
	;   followed by a checksum.
		MOVLW	SENDMESS
		CPFSEQ	MessType
		GOTO	UR6a
		CALL	USART1send
		MOVFF	CheckSum,WREG
		CALL	USART1sendChar
		CLRF	MessState
		RETURN
	; Compare the checksums on receive messages
UR6a
		MOVFF	CheckSum,WREG
		CPFSEQ	MessCHK
		GOTO	UR6b
		MOVLW	ACK
		CALL	USART1sendChar
		CLRF	MessState
		RETURN
UR6b
		MOVLW	NAK
		CALL	USART1sendChar
		CLRF	MessState
		RETURN
	; Exit and clear the state variable
UR7
		CLRF	MessState
		RETURN

; This function is used in the buddy box system. If this transmitter
; is in the student mode then channels 1 through 4 are sent out serial
; port 2. The normalized servo positions are sent, without the trims.
; This is only done in the RUN mode.
; This function is also called in master mode with a received char.
SendStudent
	; Look for a character in the input buffer
		BTFSS	PIR3,RC2IF
		RETURN
		MOVFF	RCREG2,WREG
	; If We are in the master mode then jump to its routine
		MOVLB	HIGH Master
		BTFSC	Master,0
		GOTO	MasterISR
	; Test for send position command
		XORLW	'S'
		BTFSS	ALUSTA,Z
		RETURN
	; Test if we are in student mode
		MOVLB	HIGH Student
		BTFSS	Student,0
		RETURN
	; Here if in student mode.....
		; Aileron
		MOVLB	HIGH Apos
		MOVLW	0F
		ANDWF	Apos+1,W
		IORLW	10
		CALL    USART2sendChar
		MOVFF	Apos,WREG
		CALL    USART2sendChar
		; Introduce a small delay to let the UART resync if needed. This will
		; allow for slight differences in CPU clocks 
		CALL	USART2sendEmpty
		MOVLW	D'5'
		CALL	Delay2uS
		; Elevator
		MOVLB	HIGH Epos
		MOVLW	0F
		ANDWF	Epos+1,W
		IORLW	20
		CALL    USART2sendChar
		MOVF	Epos,W
		CALL    USART2sendChar
		; Introduce a small delay to let the UART resync if needed. This will
		; allow for slight differences in CPU clocks 
		CALL	USART2sendEmpty
		MOVLW	D'5'
		CALL	Delay2uS
		; Rudder
		MOVLB	HIGH Rpos
		MOVLW	0F
		ANDWF	Rpos+1,W
		IORLW	30
		CALL    USART2sendChar
		MOVF	Rpos,W
		CALL    USART2sendChar
		; Introduce a small delay to let the UART resync if needed. This will
		; allow for slight differences in CPU clocks 
		CALL	USART2sendEmpty
		MOVLW	D'5'
		CALL	Delay2uS
		; Throttle
		MOVLB	HIGH Tpos
		MOVLW	0F
		ANDWF	Tpos+1,W
		IORLW	40
		CALL    USART2sendChar
		MOVF	Tpos,W
		CALL    USART2sendChar
		RETURN

MasterISR
	; Test State variable, if LSB is zero then save this value
	; and exit
		MOVLB	HIGH MasterState
		BTFSC	MasterState,0
		GOTO	MasterState1
		; Here with high byte of message
		MOVWF	MasterPos+1
		INCF	MasterState
		RETURN
MasterState1
		MOVWF	MasterPos
		INCF	MasterState
	; Test the state a process message
		MOVLW	2
		CPFSEQ	MasterState
		GOTO	MS2
	; Here if Aileron
		MOVF	MasterPos+1,W
		ANDLW	0F0
		XORLW	010
		BTFSS	ALUSTA,Z
		GOTO	MS5
		MOVLW	0F
		ANDWF	MasterPos+1,F
		BTFSS	MasterPos+1,3
		GOTO	MS1a
		MOVLW	0F0
		IORWF	MasterPos+1
MS1a
		MOVE	MasterPos,MApos
		GOTO	MS5
MS2
		MOVLW	4
		CPFSEQ	MasterState
		GOTO	MS3
	; Here if Elevator
		MOVF	MasterPos+1,W
		ANDLW	0F0
		XORLW	020
		BTFSS	ALUSTA,Z
		GOTO	MS5
		MOVLW	0F
		ANDWF	MasterPos+1,F
		BTFSS	MasterPos+1,3
		GOTO	MS2a
		MOVLW	0F0
		IORWF	MasterPos+1
MS2a
		MOVE	MasterPos,MEpos
		GOTO	MS5
MS3
		MOVLW	6
		CPFSEQ	MasterState
		GOTO	MS4
	; Here if Rudder
		MOVF	MasterPos+1,W
		ANDLW	0F0
		XORLW	030
		BTFSS	ALUSTA,Z
		GOTO	MS5
		MOVLW	0F
		ANDWF	MasterPos+1,F
		BTFSS	MasterPos+1,3
		GOTO	MS3a
		MOVLW	0F0
		IORWF	MasterPos+1
MS3a
		MOVE	MasterPos,MRpos
		GOTO	MS5
MS4
		MOVLW	8
		CPFSEQ	MasterState
		GOTO	MS5
	; Here if Throttle
		MOVF	MasterPos+1,W
		ANDLW	0F0
		XORLW	040
		BTFSS	ALUSTA,Z
		GOTO	MS5
		MOVLW	0F
		ANDWF	MasterPos+1,F
		BTFSS	MasterPos+1,3
		GOTO	MS4a
		MOVLW	0F0
		IORWF	MasterPos+1
MS4a
		MOVE	MasterPos,MTpos
		GOTO	MS5
MS5
		RETURN


;
; This function uses USART2 to send the position data using USART channel 2.
; This function supports connecting the encoder to a receiving device that
; can convert the serial data stream into servo position pulses. The number
; of channels sent are defined by the microstar number of channels 
; parameter.
; The position information is set at the framing rate of the encoder and each
; channel's data in send in two bytes, LS first.
;
; Data block format:
;	<SOT><SOT><channel 1 position, 2 bytes, LS first>...<channel n><Checksum><EOT><EOT>
;
;	<SOT> = Start of text character, 0xAA
;	<EOT> = End of text character, 0xED
;	Checksum is a mod 256 sum of all channel position data
;	Channel position data is sent in 2 bytes and the 4 MSB of the MS byte
;	contain the channel number
;
SOT	EQU	0xAA
EOT	EQU	0xED

SerialSendPositionData
	; Exit if the send flag is not set
		MOVFF	SerialSend,WREG
		COMF	WREG
		TSTFSZ	WREG
		RETURN
	; Send SOT characters
		MOVLW	SOT
		CALL	USART2sendChar
		MOVLW	SOT
		CALL	USART2sendChar
	; Send the channel data
		; Areg is the loop counter
		CLRF	Areg,A
		; Breg is the checksum
		CLRF	Breg,A
		; Areg contains current channel number. First use channel order
		; to determine the channel number to send.
SSPDnext
		MOVLW	HIGH ChannelOrder
		MOVWF	FSR1H
		MOVLW	LOW ChannelOrder
		MOVWF	FSR1L
		MOVFF	Areg,WREG
		MOVFF	PLUSW1,AXreg		; AXreg has channel number
		; Now get channel number
		MOVLW	HIGH CHtimes	
		MOVWF	FSR1H
		MOVLW	LOW CHtimes	
		MOVWF	FSR1L
		; Build prointer into CHtimes
		MOVFF	AXreg,WREG
		DECF	WREG
		BCF	ALUSTA,C
		RLCF	WREG	
		; Load value from CHtimes
		MOVFF	PLUSW1,AXreg
		INCF	WREG
		MOVFF	PLUSW1,AXreg+1		; Channel data is now in AXreg
		; Add channel sequence number to MS nibble in channel data word
		MOVLR	HIGH AXreg
		SWAPF	AXreg+1
		MOVLW	0xF0
		ANDWF	AXreg+1,F
		MOVFF	Areg,WREG
		INCF	WREG
		IORWF	AXreg+1,F
		SWAPF	AXreg+1
		; Add these bytes to the checksum
		MOVFF	Breg,WREG
		ADDWF	AXreg,W
		ADDWF	AXreg+1,W
		MOVFF	WREG,Breg
		; Send the channel position data
		MOVFF	AXreg,WREG
		CALL	USART2sendChar
		MOVFF	AXreg+1,WREG
		CALL	USART2sendChar
		; Advance the loop counter and continue till all channels are done, 8 channels max
		INCF	Areg,F,A
		MOVLW	8
		CPFSLT	Areg,A
		GOTO	SSPDdone
		MOVFF	MaxChannels,WREG
		BCF	ALUSTA,C
		RRCF	WREG
		CPFSGT	Areg,A
		GOTO	SSPDnext		
	; Send the checksum
SSPDdone
		MOVFF	Breg,WREG
		CALL	USART2sendChar
	; Send the EOT characters
		MOVLW	EOT
		CALL	USART2sendChar
		MOVLW	EOT
		CALL	USART2sendChar
	; Exit
		RETURN
		