#define		MOVFP	MOVF
#define		MOVLR	MOVLB
#define		MOVPF	MOVFF
#define		ALUSTA	STATUS

OFFSET	EQU	0x200		; For use with the bootloader
;OFFSET	EQU	0x0		; For stand along operation

; ADC channel assignments
;
;	CH	Use
;	0	Vpos monitor
;	1	Gnd
;	2	CH7
;	3	CH6
;	4	Aileron
;	5	Elevator
;	6	Rudder
;	7	Throttle
;	8	Aileron trim
;	9	Elevator trim
;	10	Rudder trim
;	11	Throttle trim
;	12	+5 volt monitor 
;       13	Receiver voltage monitor
;

NumAircraft	EQU	D'96'

BNK1	EQU	100
BNK2	EQU	200
BNK3	EQU	300
BNK4	EQU	400

; Misc constants
StickThres      EQU     D'400'
AutoTrimOStime	EQU	D'40'
VoltageLimit	EQU	D'8800'

; PLL constants
HICUR   EQU     10

; Display Line numbers
ifdef		LCD52display
LINE1      EQU       080
LINE2      EQU       0C0
LINE3      EQU       0C0
LCDRIGHT   EQU       08
CURSORON   EQU       0E
CURSOROFF  EQU       0C
YPOS       EQU       08
YNPOS      EQU       0C
NPOS       EQU       0F
ACFTPOS    EQU       0D
BYTEPOS    EQU       0D
PERCENTPOS EQU       0B
uSPOS      EQU       09
INTPOS     EQU       0B
SELCHPOS   EQU       0C
CVMPOS     EQU       0B
ONTIMEPOS  EQU       0B
CH53POS    EQU       08
CH50POS    EQU       0E
CH72POS    EQU       0D
CH50MHZPOS EQU       04
CH72MHZPOS EQU       04
TESTCHPOS  EQU       07
TESTVALPOS EQU       0C
TACHRPMPOS EQU       0B
RECVPOS    EQU       0B
endif

ifdef		MicroProStar
LINE1      EQU       080
LINE2      EQU       088
LINE3      EQU       088
LCDRIGHT   EQU       040
CURSORON   EQU       0E
CURSOROFF  EQU       0C
YPOS       EQU       040
YNPOS      EQU       044
NPOS       EQU       047
ACFTPOS    EQU       045
BYTEPOS    EQU       045
PERCENTPOS EQU       043
uSPOS      EQU       041
INTPOS     EQU       043
SELCHPOS   EQU       044
CVMPOS     EQU       043
ONTIMEPOS  EQU       043
CH53POS    EQU       040
CH50POS    EQU       046
CH72POS    EQU       045
CH50MHZPOS EQU       04
CH72MHZPOS EQU       04
TESTCHPOS  EQU       07
TESTVALPOS EQU       044
TACHRPMPOS EQU       043
RECVPOS    EQU       043
endif

ifdef           SED1230display
LINE1      EQU       0B0
LINE2      EQU       0C0
LINE3      EQU       0C0
LCDRIGHT   EQU       08
CURSORON   EQU       03F
CURSOROFF  EQU       031
YPOS       EQU       08
YNPOS      EQU       0C
NPOS       EQU       0F
ACFTPOS    EQU       0D
BYTEPOS    EQU       0D
PERCENTPOS EQU       0B
uSPOS      EQU       09
INTPOS     EQU       0B
SELCHPOS   EQU       0C
CVMPOS     EQU       0B
ONTIMEPOS  EQU       0B
CH53POS    EQU       08
CH50POS    EQU       0E
CH72POS    EQU       0D
CH50MHZPOS EQU       04
CH72MHZPOS EQU       04
TESTCHPOS  EQU       07
TESTVALPOS EQU       0C
TACHRPMPOS EQU       0B
RECVPOS    EQU       0B
endif

ifdef           ECMA1010display
LINE1     EQU        0B0
LINE2     EQU        0C0
LINE3     EQU        0D0
LINE4     EQU        0E0
CURSORON  EQU        03F
CURSOROFF EQU        031
YPOS      EQU        07
YNPOS     EQU        09
NPOS      EQU        0B
ACFTPOS    EQU       0A
BYTEPOS    EQU       09
PERCENTPOS EQU       07
uSPOS      EQU       05
INTPOS     EQU       07
SELCHPOS   EQU       08
CVMPOS     EQU       07
ONTIMEPOS  EQU       07
CH53POS    EQU       05
CH50POS    EQU       0B
CH72POS    EQU       0A
CH50MHZPOS EQU       03
CH72MHZPOS EQU       03
TESTCHPOS  EQU       05
TESTVALPOS EQU       08
TACHRPMPOS EQU       07  
RECVPOS    EQU       07
endif

; Button and signal definitions for the Transmitter controls
; PortA bits
BUZZER	EQU	4

; PortB bits
TACHIN	EQU	1
LED2	EQU	2
PLLRST	EQU	6		; PIC reset on RFDECK
SDObit	EQU	7		; Serial data out

; PortC bits
CFGMEM2	EQU	2
LED1	EQU	3
SDIbit	EQU	4
CLK	EQU	5		; Clock for PLL and config mem

; PortD bits
AilDR	EQU	0
EleDR	EQU	1
RudDR	EQU	2
PRESET	EQU	3
MIX1	EQU	4
MIX2	EQU	5
MIX3	EQU	6
CH5	EQU	7

; PortE bits
RUNCAL	EQU	0
AUTOT	EQU	1
OPTION	EQU	2
CH8A	EQU	3
CH8C	EQU	4
ALTAFK	EQU	5
SNAPR	EQU	6
SNAPL	EQU	7

; PortF bits
MOD	EQU	7

; PortG bits
CFGMEM1	EQU	0
PLLCS	EQU	3

; PortH bits
AUXOUT	EQU	0
TACHENA	EQU	1
RECCOMM	EQU	2

; LCD PORTS
LCDDATA		EQU	PORTJ
LCDDATADIR	EQU	DDRJ
LCDCTRL		EQU	PORTB
LCDCTRLDIR	EQU	DDRB

; ADC channel assignments
ADCch6		EQU	00
ADCch7		EQU	01
ADCgnd		EQU	02
ADCref		EQU	03
ADCail		EQU	04
ADCele		EQU	05
ADCrud		EQU	06
ADCthr		EQU	07
ADCailTrim	EQU	08
ADCeleTrim	EQU	09
ADCrudTrim	EQU	0A
ADCthrTrim	EQU	0B
ADCtest		EQU	0C
ADCrec		EQU	0D

NOMINALBAT	EQU	0x800

