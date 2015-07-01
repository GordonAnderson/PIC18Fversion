
/******************************************************************************\
*	PIC16/18 Bootloader Communications Handler
*	by Ross M. Fosler
*	Microchip Technology Incorporated
\******************************************************************************/

/****************************************************************************

    PROGRAM:	P1618BOOT.c

    PURPOSE:	The purpose of this DLL is to provide a communications base for 
				quick and easy higher level development.

    FUNCTIONS:	HANDLE APIENTRY OpenPIC(LPSTR, DWORD, DWORD)
				INT APIENTRY ClosePIC(HANDLE)
				INT APIENTRY GetPacket(HANDLE, BYTE *, WORD)
				INT APIENTRY SendPacket(HANDLE, BYTE *, WORD)
				INT APIENTRY SendGetPacket(HANDLE, BYTE *, WORD, WORD, WORD)
				DWORD APIENTRY WritePIC(HANDLE, PIC *, BYTE *)
				DWORD APIENTRY ReadPIC(HANDLE, PIC *, BYTE *)     

*******************************************************************************/

#include "windows.h"
#include "PICBOOT.h"



/****************************************************************************
   FUNCTION: DllMain(HANDLE, DWORD, LPVOID)

   PURPOSE:  DllMain is called by Windows when
             the DLL is initialized, Thread Attached, and other times.
             Refer to SDK documentation, as to the different ways this
             may be called.
             
             The DllMain function should perform additional initialization
             tasks required by the DLL.  In this example, no initialization
             tasks are required.  DllMain should return a value of 1 if
             the initialization is successful.
           
*******************************************************************************/
BOOL APIENTRY DllMain(HANDLE hInst, DWORD ul_reason_being_called, LPVOID lpReserved)
{
    return 1;
        UNREFERENCED_PARAMETER(hInst);
        UNREFERENCED_PARAMETER(ul_reason_being_called);
        UNREFERENCED_PARAMETER(lpReserved);
}


/****************************************************************************

    FUNCTION:	OpenPIC

    PURPOSE:	This function is provided to open communications to the
				PIC through a serial port. The function returns a handle 
				to the opened port or returns a negative number on an error.

****************************************************************************/
HANDLE APIENTRY OpenPIC(LPSTR ComPort, DWORD BitRate, DWORD ReadTimeOut)
{
	HANDLE hComm;
	DCB dcb = {0};
	COMMTIMEOUTS CommTmOut = {0};
	
	// Get a handle to the port.
	hComm = CreateFile( ComPort,  
                       GENERIC_READ | GENERIC_WRITE, 
                       0, 
                       NULL, 
                       OPEN_EXISTING,
                       FILE_ATTRIBUTE_NORMAL,
                       0);
	if (hComm == INVALID_HANDLE_VALUE)
		return INVALID_HANDLE_VALUE;

	// Get the current state of the port
	FillMemory(&dcb, sizeof(dcb), 0);

	if (!GetCommState(hComm, &dcb)){
		return INVALID_HANDLE_VALUE;
	}
	else{
		dcb.BaudRate = BitRate;
		dcb.Parity = NOPARITY;
		dcb.StopBits = ONESTOPBIT;
		dcb.fDtrControl = DTR_CONTROL_DISABLE;
		dcb.fRtsControl = RTS_CONTROL_DISABLE;
		dcb.fOutX = FALSE;
		dcb.fInX = FALSE;
		dcb.fOutxCtsFlow = FALSE;
		dcb.fOutxDsrFlow = FALSE;
		dcb.ByteSize = 8;
	}
		
	if (!SetCommState(hComm, &dcb))
		return INVALID_HANDLE_VALUE;


	//Set the timeout conditions
	if (!GetCommTimeouts(hComm, &CommTmOut)){
		return INVALID_HANDLE_VALUE;
	}
	else{
		CommTmOut.ReadIntervalTimeout = MAXDWORD;
		CommTmOut.ReadTotalTimeoutMultiplier = MAXDWORD;
		CommTmOut.ReadTotalTimeoutConstant = ReadTimeOut;
	}

	if (!SetCommTimeouts(hComm, &CommTmOut))
		return INVALID_HANDLE_VALUE;

	return hComm;
}



/****************************************************************************

    FUNCTION:	ClosePIC

    PURPOSE: 

****************************************************************************/
INT APIENTRY ClosePIC(HANDLE hComPort)
{
	return CloseHandle(hComPort);
}








/****************************************************************************

    FUNCTION:	GetPacket

    PURPOSE:	This function captures data from the opened source and 
				strips out special control characters. The length of the 
				packet is returned.

****************************************************************************/

INT APIENTRY GetPacket(HANDLE hComPort, BYTE PacketData[], WORD ByteLimit)
{
	WORD PacketCount;
	DWORD Checksum = 0;
	DWORD BytesRead;
	BYTE DataByte;
	BYTE Flags = 2;

	//Scan for a start condition
StartOfPacket:
	while (Flags){

		BytesRead = 0;
		if (!ReadFile(hComPort, &DataByte, 1, &BytesRead, NULL)) return ERROR_GEN_READWRITE;
		if (!BytesRead) return ERROR_READ_TIMEOUT;

		if (DataByte == STX) Flags--;
		else Flags = 2;
	}

	//Get the data and unstuff when necessary
	PacketCount = 0;
	Flags = 1;
	while (Flags){

		BytesRead = 0;
		if (!ReadFile(hComPort, &DataByte, 1, &BytesRead, NULL)) return ERROR_GEN_READWRITE;
		if (!BytesRead) return ERROR_READ_TIMEOUT;

		switch (DataByte){
			case STX: 
			{
				goto StartOfPacket;
			}
			case ETX: 
			{
				Flags = 0;
				continue;
			}
			case DLE: 
			{
				BytesRead = 0;
				if (!ReadFile(hComPort, &DataByte, 1, &BytesRead, NULL)) return ERROR_GEN_READWRITE;
				if (!BytesRead) return ERROR_READ_TIMEOUT;
			}
			default:
			{
				if (PacketCount > ByteLimit) return ERROR_READ_LIMIT;
				PacketData[PacketCount] = DataByte;
				Checksum = Checksum + (DWORD)DataByte;
				PacketCount++;
			}
		}
	}

	//Test the checksum
	DataByte =  (BYTE)(((~(Checksum)) + 1) & 255);
	if (DataByte) return ERROR_BAD_CHKSUM;
	
	return PacketCount;
}






/****************************************************************************

    FUNCTION:	SendPacket

    PURPOSE:	This function translates and transmitts a packet of data to 
				communicate with the bootloader firmware on the PIC
				microcontroller.

****************************************************************************/
INT APIENTRY SendPacket(HANDLE hComPort, 
						BYTE PacketData[],  
						WORD NumOfBytes)
{
	UINT PacketCount;
	DWORD Checksum = 0;
	DWORD BytesWritten;
	BYTE DataByte;
	
	//Send the start condition
	DataByte = STX;
	for(PacketCount = 0; PacketCount < 2; PacketCount++){
		if (!WriteFile(hComPort, &DataByte, 1, &BytesWritten, NULL)){
			return ERROR_GEN_READWRITE;
		}
	}

	//Send the packet data and stuff byte if necessary
	for(PacketCount = 0; PacketCount < NumOfBytes; PacketCount++)
	{
		switch (PacketData[PacketCount])
		{
			case STX:
			case ETX:
			case DLE:
			{
				DataByte = DLE;
				if (!WriteFile(hComPort, &DataByte, 1, &BytesWritten, NULL)) return ERROR_GEN_READWRITE;
				break;
			}
		}
		
		DataByte = PacketData[PacketCount]; 
		Checksum = Checksum + (DWORD)DataByte; 
		if (!WriteFile(hComPort, &DataByte, 1, &BytesWritten, NULL)) return ERROR_GEN_READWRITE;
	}
	
	//Send the checksum
	DataByte =  (BYTE)(((~(Checksum)) + 1) & 255);
	switch (DataByte)
	{
		case STX:
		case ETX:
		case DLE:
		{
			DataByte = DLE;
			if (!WriteFile(hComPort, &DataByte, 1, &BytesWritten, NULL)) return ERROR_GEN_READWRITE;
			break;
		}
	}
	DataByte =  (BYTE)(((~(Checksum)) + 1) & 255);
	if (!WriteFile(hComPort, &DataByte, 1, &BytesWritten, NULL)) return ERROR_GEN_READWRITE;


	//Send the stop condition
	DataByte = ETX;
	if (!WriteFile(hComPort, &DataByte, 1, &BytesWritten, NULL)) return ERROR_GEN_READWRITE;

	return	PacketCount;
}






/****************************************************************************

    FUNCTION:	SendGetPacket

    PURPOSE:	This function is a combined function of the SendPacket and
				GetPacket functions. A retry option has been added to allow
				retransmission and reception in the event of normal 
				communications failure. 

****************************************************************************/
INT APIENTRY SendGetPacket(HANDLE hComPort, 
							BYTE PacketData[],
							WORD SendNumOfBytes,
							WORD RecvByteLimit,
							WORD NumOfRetrys)
{
	INT RetStatus;
	INT RetryCount;

	RetryCount = NumOfRetrys;

	while (TRUE){
		if(!RetryCount) return ERROR_RETRY_LIMIT;
		RetryCount--;

		RetStatus = SendPacket(hComPort, PacketData, SendNumOfBytes);
		if(RetStatus < 0) return RetStatus;

		RetStatus = GetPacket(hComPort, PacketData, RecvByteLimit);
		switch (RetStatus){
			case	ERROR_READ_TIMEOUT:
			case	ERROR_BAD_CHKSUM:
				continue;

			default: return RetStatus;
		}
		
		break;
	}

	return RetStatus;
}





/****************************************************************************

    FUNCTION:	ReadPIC

    PURPOSE:	This is a simple read function. 

****************************************************************************/
INT APIENTRY ReadPIC(HANDLE hComPort, PIC *pic, BYTE PacketData[])
{
	BYTE InData[MAX_PACKET];		//Allocate for one packet
	INT RetStatus;
	INT DatCount;
	INT DatCount2 = 0;

	switch (pic->BootCmd){
		case COMMAND_READPM: 
		case COMMAND_READEE: 
		case COMMAND_READCFG: 
			break;
		default: return ERROR_INVALID_COMMAND;
	}
	
	//Limit to 1 or 2 bytes per addr
	if(!pic->BytesPerAddr) return ERROR_BPA_TOO_SMALL;
	if(pic->BytesPerAddr > 2) return ERROR_BPA_TOO_BIG;

	if(pic->BytesPerBlock < pic->BytesPerAddr) return ERROR_BLOCK_TOO_SMALL;
	if(pic->BootDatLen > MAX_PACKET - 6) return ERROR_PACKET_TOO_BIG;

	//Build header
	InData[0] = pic->BootCmd;
	InData[1] = pic->BootDatLen / pic->BytesPerAddr;
	InData[2] = (BYTE)(pic->BootAddr & 0xFF);
	InData[3] = (BYTE)((pic->BootAddr & 0xFF00) / 0x100);
	InData[4] = (BYTE)((pic->BootAddr & 0xFF0000) / 0x10000);

	RetStatus = SendGetPacket(hComPort, InData, 5, MAX_PACKET, pic->MaxRetrys);

	if(RetStatus < 0) return RetStatus;

	for (DatCount = 5; DatCount < RetStatus - 1; DatCount++){
		PacketData[DatCount2] = InData[DatCount];
		DatCount2++;
	}
	
	return DatCount2;
}



/****************************************************************************

    FUNCTION:	

    PURPOSE: 

****************************************************************************/
INT APIENTRY WritePIC(HANDLE hComPort, PIC *pic, BYTE PacketData[])
{
	BYTE OutData[MAX_PACKET];		//Allocate for one packet
	INT RetStatus;
	INT DatCount;
	INT DatCount2;

	switch (pic->BootCmd){
		case COMMAND_WRITEPM: 
		case COMMAND_WRITEEE: 
		case COMMAND_WRITECFG: 
			break;
		default: return ERROR_INVALID_COMMAND;
	}

	//Limit to 1 or 2 bytes per addr
	if(!pic->BytesPerAddr) return ERROR_BPA_TOO_SMALL;
	if(pic->BytesPerAddr > 2) return ERROR_BPA_TOO_BIG;

	if(pic->BytesPerBlock < pic->BytesPerAddr) return ERROR_BLOCK_TOO_SMALL;
	if(pic->BootDatLen > MAX_PACKET - 6) return ERROR_PACKET_TOO_BIG;

	if(pic->BootAddr % pic->BytesPerBlock) return ERROR_OFF_BOUNDRY;
	if(pic->BootDatLen % pic->BytesPerBlock) return ERROR_OFF_BOUNDRY;

	//Build header
	OutData[0] = pic->BootCmd;
	OutData[1] = pic->BootDatLen / pic->BytesPerBlock;
	OutData[2] = (BYTE)(pic->BootAddr & 0xFF);
	OutData[3] = (BYTE)((pic->BootAddr & 0xFF00) / 0x100);
	OutData[4] = (BYTE)((pic->BootAddr & 0xFF0000) / 0x10000);

	DatCount = 5;
	for (DatCount2 = 0; DatCount2 < pic->BootDatLen; DatCount2++){
		OutData[DatCount] = PacketData[DatCount2];
		DatCount++;
	}

	RetStatus = SendGetPacket(hComPort, OutData, (BYTE)DatCount, MAX_PACKET, pic->MaxRetrys);

	if(RetStatus < 0) return RetStatus;

	return DatCount2;
}








/****************************************************************************

    FUNCTION:	ErasePIC

    PURPOSE:	Simple erase function.

****************************************************************************/
INT APIENTRY ErasePIC(HANDLE hComPort, DWORD PICAddr, BYTE nBlock, BYTE nRetry)
{
	BYTE InData[MAX_PACKET];		//Allocate for one packet
	INT RetStatus;
	
		
	//Build header
	InData[0] = COMMAND_ERASEPM;
	InData[1] = nBlock;
	InData[2] = (BYTE)(PICAddr & 0xFF);
	InData[3] = (BYTE)((PICAddr & 0xFF00) / 0x100);
	InData[4] = (BYTE)((PICAddr & 0xFF0000) / 0x10000);

	RetStatus = SendGetPacket(hComPort, InData, 5, MAX_PACKET, nRetry);

	if(RetStatus < 0) return RetStatus;

	return InData[1];
}













/****************************************************************************

    FUNCTION:	

    PURPOSE: 

****************************************************************************/
INT APIENTRY VerifyPIC(HANDLE hComPort, PIC *pic, BYTE PacketData[]){
	INT RetStatus;
	BYTE InData[MAX_PACKET];
	INT i;

	switch (pic->BootCmd){
		case COMMAND_READPM: 
		case COMMAND_READEE: 
		case COMMAND_READCFG: 
			break;
		default: return ERROR_INVALID_COMMAND;
	}
	
	RetStatus = ReadPIC(hComPort, pic, InData);
	if(RetStatus < 0) return RetStatus;

	for(i = 0; i < RetStatus; i++){
		if(PacketData[i] != InData[i]) return ERROR_VERIFY_FAILED;
	}

	return i;
}



