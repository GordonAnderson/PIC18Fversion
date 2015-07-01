
/******************************************************************************\
*	PIC16/18 Bootloader Communications Handler (header file)
*	by Ross M. Fosler
*	Microchip Technology Incorporated
\******************************************************************************/



//Packet control characters
#define STX		15
#define ETX		4
#define DLE		5

//Error conditions
#define ERROR_GEN_READWRITE		-1
#define	ERROR_READ_TIMEOUT		-2
#define ERROR_READ_LIMIT		-3
#define	ERROR_BAD_CHKSUM		-4
#define	ERROR_RETRY_LIMIT		-5
#define ERROR_INVALID_COMMAND	-6
#define ERROR_BLOCK_TOO_SMALL	-7
#define ERROR_PACKET_TOO_BIG	-8
#define ERROR_OFF_BOUNDRY		-9
#define ERROR_BPA_TOO_SMALL		-10
#define ERROR_BPA_TOO_BIG		-11	
#define ERROR_VERIFY_FAILED		-12

//Limits
#define MAX_PACKET			256

//Bootloader commands
#define COMMAND_READVER		0
#define COMMAND_READPM		1
#define COMMAND_WRITEPM		2
#define COMMAND_ERASEPM		3
#define COMMAND_READEE		4
#define COMMAND_WRITEEE		5
#define COMMAND_READCFG		6
#define COMMAND_WRITECFG	7


//PIC structure used for some functions
typedef struct _PIC {
	BYTE BootCmd;
	BYTE BootDatLen;		//Number of bytes to read/write
	DWORD BootAddr;			//24 bit memory address (Prog or EE)
	BYTE BytesPerBlock;
	BYTE BytesPerAddr;
	WORD MaxRetrys;			//Number of retries before failure
} PIC;


//Prototypes
HANDLE APIENTRY OpenPIC(LPSTR ComPort, DWORD BitRate, DWORD ReadTimeOut);
INT APIENTRY ClosePIC(HANDLE hComPort);
INT APIENTRY GetPacket(HANDLE hComPort, BYTE PacketData[], WORD ByteLimit);
INT APIENTRY SendPacket(HANDLE hComPort, BYTE PacketData[], WORD NumOfBytes);
INT APIENTRY SendGetPacket(HANDLE hComPort, BYTE PacketData[], WORD SendNumOfBytes, WORD RecvByteLimit, WORD NumOfRetrys);
INT APIENTRY ReadPIC(HANDLE hComPort, PIC *pic, BYTE PacketData[]);
INT APIENTRY WritePIC(HANDLE hComPort, PIC *pic, BYTE PacketData[]);
INT APIENTRY ErasePIC(HANDLE hComPort, DWORD PICAddr, BYTE nBlock, BYTE nRetry);
INT APIENTRY VerifyPIC(HANDLE hComPort, PIC *pic, BYTE PacketData[]);


