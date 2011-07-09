; 
; FMS.asm
;
;  This file contains the routines needed to support the Flight Model simulator.
;  FMS is a free simulator that will accept RS232 position input data. FMS
;  expects the following:
;    0xF0 start of data block
;    One byte per data channel, 0=1mS, 239=2mS do not send a 0xF0 in the data block.
;  The number of channels sent is defined by the number of position bytes sent.
;  The baud rate is set at 9600, FMS supports 19200 but the PIC clock does not allow
;  this rate to be generated with enough accuracy.
;  

; This function initalizes the UART for FMS operation. The UART selected for initalization
; is defined via the FMSflag and FMSflagU1 values. FMSflag is set for UART2 and FMSflagU1 is 
; set for UART 1.
FMSinit
	; Test the flag to determine the UART to use.
		MOVLB	HIGH FMSflag		; This flag is set for UART 2
		TSTFSZ	FMSflag	
		GOTO	FMSinit1	
	;
	; Here for UART 1
	;
	; Disable 16 bit baudrate mode
		BCF	BAUDCON1,BRG16,A
	; Baudrate generator
		MOVLW	D'12'		; 9600 baud
		MOVLB	HIGH SPBRG1
		MOVWF	SPBRG1
	; Enable transmitter
		MOVLW	22
		MOVWF	TXSTA1
	; Receiver
		MOVLW	90
		MOVFF	WREG,RCSTA1
		RETURN
	;
	; Here for UART 2
	;
FMSinit1
	; Disable 16 bit baudrate mode
		BCF	BAUDCON2,BRG16,A
	; Baudrate generator
		MOVLW	D'12'		; 9600 baud
		MOVLB	HIGH SPBRG2
		MOVWF	SPBRG2
	; Enable transmitter
		MOVLW	22
		MOVWF	TXSTA2
	; Receiver
		MOVLW	90
		MOVFF	WREG,RCSTA2
		RETURN

; This function sends a centered channel using UART 2.
; The normalized position data is in AXreg. The range of
; this value is -1000 to 1000
FMScenter
	; Add 1000 to AXreg
		MOVLB	HIGH AXreg
		MOVLW	LOW D'1000'
		ADDWF	AXreg
		MOVLW	HIGH D'1000'
		ADDWFC	AXreg+1
		; If AXreg is negative then set it to zero
		BTFSS	AXreg+1,7
		GOTO	FMScNotZ
		CLRF	WREG
		MOVFF	WREG,AXreg
		MOVFF	WREG,AXreg+1
	; Limit test, if AX is greater than 1912 then send 239.
FMScNotZ
		MOVLW	LOW D'1912'
		SUBWF	AXreg,W
		MOVLW	HIGH D'1912'
		SUBWFB	AXreg+1,W
		BTFSS	ALUSTA,C
		GOTO	FMSdiv8
		MOVLW	D'239'
		GOTO	FMSsend
	; Divide by 8
FMSdiv8
		RRCF	AXreg+1
		RRCF	AXreg		; Devide by 2
FMSdiv4
		RRCF	AXreg+1
		RRCF	AXreg		; Devide by 4
		RRCF	AXreg+1
		RRCF	AXreg		; Devide by 8
		MOVF	AXreg,W
	; Send
FMSsend
	; Use the flag to select the proper uart to use
		MOVLB	HIGH FMSflag	; This flag is set for UART 2
		TSTFSZ	FMSflag	
		GOTO	USART2sendChar
		GOTO	USART1sendChar

; This function sends a non centered channel using UART 2.		
; The normalized position data is in AXreg. The range of
; this value is 0 to 1000
FMSnonCenter
	; If AXreg is negative then set it to zero
		MOVLR	HIGH AXreg
		BTFSS	AXreg+1,7
		GOTO	FMSNotZ
		CLRF	WREG
		MOVFF	WREG,AXreg
		MOVFF	WREG,AXreg+1
	; Limit test, if AX is greater than 956 then send 239.
FMSNotZ
		MOVLW	LOW D'956'
		SUBWF	AXreg,W
		MOVLW	HIGH D'956'
		SUBWFB	AXreg+1,W
		BTFSS	ALUSTA,C
		GOTO	FMSdiv4
		MOVLW	D'239'
		GOTO	FMSsend
	
		
; This function sends the data blocks using UART 2. The following 
; channels are send in the following order:
; 	Aileron
;	Elevator
;	Rudder
;	Throttle
;	CH5 (Retracts)
;	CH6
FMS
	; Send the sync character
		MOVLW	0F0
		CALL	FMSsend
		MOVLW	080
		CALL	FMSsend			; Don't know why I hade to send this byte?
	; Process Ail, Ele, and Rud
		MOVE16	Apos,AXreg
		CALL	FMScenter
		MOVE16	Epos,AXreg
		CALL	FMScenter
		MOVE16	Rpos,AXreg
		CALL	FMScenter
	; Process Throttle, and CH5, CH6
		MOVE16	Tpos,AXreg
		CALL	FMSnonCenter
		MOVE16	CH5pos,AXreg
		CALL	FMScenter
		MOVE16	CH6pos,AXreg
		CALL	FMScenter
	; Done!
		RETURN



