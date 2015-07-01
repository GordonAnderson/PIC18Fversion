Attribute VB_Name = "Module1"
Public Declare Function SendPacket Lib "PICBOOT.dll" (ByVal hComPort As Long, PacketData As Byte, ByVal NumOfBytes As Integer) As Integer
Public Declare Function GetPacket Lib "PICBOOT.dll" (ByVal hComPort As Long, PacketData As Byte, ByVal NumOfBytesLim As Integer) As Integer
Public Declare Function OpenPIC Lib "PICBOOT.dll" (ByVal ComPort As String, ByVal BitRate As Long, ByVal ReadTimeOut As Long) As Long
Public Declare Function ClosePIC Lib "PICBOOT.dll" (ByVal hComPort As Long) As Integer
Public Declare Function SendGetPacket Lib "PICBOOT.dll" (ByVal hComPort As Long, PacketData As Byte, ByVal NumOfBytes As Integer, ByVal NumOfBytesLim As Integer, ByVal NumOfRetrys As Integer) As Integer
Public Declare Function ReadPIC Lib "PICBOOT.dll" (ByVal hComPort As Long, LPpic As PIC, MemData As Byte) As Integer
Public Declare Function WritePIC Lib "PICBOOT.dll" (ByVal hComPort As Long, LPpic As PIC, MemData As Byte) As Integer
Public Declare Function VerifyPIC Lib "PICBOOT.dll" (ByVal hComPort As Long, LPpic As PIC, MemData As Byte) As Integer


Public Type PIC                 'structure used in communications DLL
    BootCmd As Byte
    BootDatLen As Byte
    BootAddr As Long
    BytesPerBlock As Byte
    BytesPerAddr As Byte
    MaxRetrys As Integer
End Type

Public Type PICBOOT
    PortHandle As Long          'port info
    BitRate As Long
    CommPort As String
    CommTimeOut As Long
    
    MaxPacketSize As Byte
    MaxRetry As Integer

    DeviceMode As Byte          'Auto or manual
    DeviceType As Byte          'PIC16 or PIC18
    DeviceName As String        'device info
    DeviceCode As String
    
    DeviceWrtBlock As Byte      'byte per block
    DeviceRdBlock As Byte
    DeviceErsBlock As Byte
    DevBytesPerAddr As Byte

    DebugLevel As Long
    
    InFileName As String        'file and path for load operation
    OutFileName As String       'file and path for save operation

    ProgMemFile As String       'Data files
    EEDataFile As String
    UserIDFile As String
    ConfigFile As String
    EditorFile As String
    ErrorLogFile As String

    ProgMemAddrH As Long        'Mem address limits (inclusive)
    ProgMemAddrL As Long
    EEDataAddrH As Long
    EEDataAddrL As Long
    ConfigAddrH As Long
    ConfigAddrL As Long
    UserIDAddrH As Long
    UserIDAddrL As Long
End Type


Public PicBootS As PICBOOT
Public bpic As PIC

Public MyFlag As Byte
Public DataPacket(256) As Byte
Public TimeOutFlag As Byte
Public AbortFlag As Byte







Function ReadRangeDevMem(AddrL As Long, AddrH As Long, BytsPerAddr As Byte, BCom As Byte, OutFile As String) As Integer
    ReDim InData(255) As Byte
    Dim RetStat As Integer
    Dim FileLine As String
    Dim BootDatLen As Integer
    Dim BootAddr As Long
    Dim picA As PIC
    
    'Setup data file creation
    Set fs = CreateObject("Scripting.FileSystemObject")
    Set a = fs.CreateTextFile(VB.App.Path & "\" & OutFile, True)
    
    'Translate to HEX address
    AddrL = AddrL * BytsPerAddr
    AddrH = AddrH * BytsPerAddr
    
    AbortFlag = 1
    BootAddr = AddrL
            
    Do While BootAddr < (AddrH + 1)
    
        DoEvents
        
        'check for an abort
        If AbortFlag = 0 Then
            ReadRangeDevMem = -100
            Exit Function
        End If
    
        'limit the packet size
        If (AddrH + 1) - BootAddr > PicBootS.MaxPacketSize Then
            picA.BootDatLen = PicBootS.MaxPacketSize
        Else
            picA.BootDatLen = (AddrH + 1) - BootAddr
        End If
               
        picA.BootAddr = BootAddr \ BytsPerAddr
        picA.BootCmd = BCom
        picA.BytesPerAddr = BytsPerAddr
        picA.BytesPerBlock = BytsPerAddr
        picA.MaxRetrys = PicBootS.MaxRetry
        
        RetStat = ReadPIC(PicBootS.PortHandle, picA, InData(0))
        If RetStat < 0 Then
            ReadRangeDevMem = RetStat
            Exit Function
        End If
                
        'Format the data
        For i = 0 To RetStat - 1
            If BootAddr Mod 16 = 0 Then
                FileLine = Dec2Hex(BootAddr, 6)
            End If
        
            FileLine = FileLine & " " & Dec2Hex(CLng(InData(i)), 2)
            BootAddr = BootAddr + 1
                   
            If BootAddr Mod 16 = 0 Then
                a.WriteLine (FileLine)
            End If
        Next i
        
        Fm_Bootload.StatusBar1.Panels(1).Text = "Reading: " & BootAddr
    
    Loop
    
    ReadRangeDevMem = 1
    a.Close
End Function

'                HEXLine = ":10" & Dec2Hex(tPIC.BootAddr And 65535, 4) & "00"
'                CheckSum = &H10 + (tPIC.BootAddr And 65535) \ 256 + (tPIC.BootAddr And 255)
'            HEXLine = HEXLine & Dec2Hex(CLng(InData(i)), 2)
'                HEXLine = HEXLine & Dec2Hex((256 - (CheckSum And 255)), 2)
'                b.WriteLine (HEXLine)

Function WriteRangeDevMem(BlockSize As Byte, BytsPerAddr As Byte, BCom As Byte, InFile As String) As Integer
    ReDim OutData(50) As Byte
    Dim RetStat As Integer
    Dim ProgressInd As Integer
    Dim FileLine As String
    Dim picA As PIC

    'Setup data file creation
    Set fs = CreateObject("Scripting.FileSystemObject")
    Set a = fs.OpenTextFile(VB.App.Path & "\" & InFile, 1, False, 0)
    Set b = fs.CreateTextFile(PicBootS.ErrorLogFile, True)
        
    AbortFlag = 1
    ProgressInd = 1

    Do While a.AtEndOfStream <> True
        DoEvents
        FileLine = a.ReadLine
        
        'check for an abort
        If AbortFlag = 0 Then
            If ProgressInd = -101 Then
                Exit Do
            End If
            
            ProgressInd = -100
            Exit Do
        End If
           
        picA.BootAddr = (CLng(Val("&H1" & Mid(FileLine, 1, 6))) And 16777215) \ BytsPerAddr
        picA.BootCmd = BCom
        picA.BytesPerAddr = BytsPerAddr
        picA.BytesPerBlock = BlockSize
        picA.MaxRetrys = PicBootS.MaxRetry
        picA.BootDatLen = 16
        
        For i = 0 To 15
            OutData(i) = CByte(Val("&H" & Mid(FileLine, i * 3 + 8, 2)))
        Next i
        
        RetStat = WritePIC(PicBootS.PortHandle, picA, OutData(0))
        If RetStat < 0 Then
            WriteRangeDevMem = RetStat
            Exit Function
        End If
        picA.BootCmd = BCom - 1
        RetStat = VerifyPIC(PicBootS.PortHandle, picA, OutData(0))
        If RetStat < 0 Then
            If RetStat = -12 Then
                b.WriteLine (FileLine)
                ProgressInd = -101
            Else
                WriteRangeDevMem = RetStat
                Exit Function
            End If
        Else
            ProgressInd = 1
        End If
               
        Fm_Bootload.StatusBar1.Panels(1).Text = "Writing: " & picA.BootAddr
    Loop

    
    WriteRangeDevMem = ProgressInd
    a.Close
    b.Close
End Function





Function EraseRangeDevMem(AddrL As Long, AddrH As Long) As Integer
    ReDim InData(10) As Byte
    Dim RetStat As Integer
    Dim FileLine As String
    Dim BootAddr As Long
    
    
    AbortFlag = 1
    BootAddr = AddrL
    
    Do While BootAddr < (AddrH + 1)
    
        DoEvents
        
        'check for an abort
        If AbortFlag = 0 Then
            EraseRangeDevMem = -100
            Exit Function
        End If
                   
        'build header
        InData(0) = 3 'command
        InData(1) = 1

        InData(2) = CByte((BootAddr) And 255)
        InData(3) = CByte(((BootAddr) And 65280) \ 256)
        InData(4) = CByte(((BootAddr) And 16711680) \ 65536)

        'Go get some data
        RetStat = SendGetPacket(PicBootS.PortHandle, InData(0), 5, 255, 5)
        If RetStat < 0 Then
            EraseRangeDevMem = RetStat
            Exit Function
        End If
        
        BootAddr = BootAddr + PicBootS.DeviceErsBlock
        
        Fm_Bootload.StatusBar1.Panels(1).Text = "Erasing: " & BootAddr
    
    Loop
    
    EraseRangeDevMem = 1

End Function


Function WriteConfig(CfgAddr As Long, CfgData As Byte) As Integer
    ReDim InData(10) As Byte

    InData(0) = 7 'command
    InData(1) = 1

    InData(2) = CByte((CfgAddr) And 255)
    InData(3) = CByte(((CfgAddr) And 65280) \ 256)
    InData(4) = CByte(((CfgAddr) And 16711680) \ 65536)
    InData(5) = CfgData

    RetStat = SendGetPacket(PicBootS.PortHandle, InData(0), 6, 255, 1)
    If RetStat < 0 Then
        WriteConfig = RetStat
        Exit Function
    End If

    Fm_Bootload.StatusBar1.Panels(1).Text = "Writing CONFIG: " & CfgAddr
    WriteConfig = 1
End Function


Function ReadConfig(CfgAddr As Long) As Integer
    ReDim InData(10) As Byte

    InData(0) = 6 'command
    InData(1) = 1

    InData(2) = CByte((CfgAddr) And 255)
    InData(3) = CByte(((CfgAddr) And 65280) \ 256)
    InData(4) = CByte(((CfgAddr) And 16711680) \ 65536)

    RetStat = SendGetPacket(PicBootS.PortHandle, InData(0), 5, 255, 1)
    If RetStat < 0 Then
        ReadConfig = RetStat
        Exit Function
    End If

    Fm_Bootload.StatusBar1.Panels(1).Text = "Reading CONFIG: " & CfgAddr
    ReadConfig = InData(5)
End Function




Function ReadVersion() As String
    ReDim DevID(10) As Byte
    Dim RetStat As Integer

    DevID(0) = 0
    DevID(1) = 2
    RetStat = SendGetPacket(PicBootS.PortHandle, DevID(0), 2, 10, 3)
    
    If RetStat <= 0 Then
        ReadVersion = Empty
    Else
        ReadVersion = "v" & DevID(3) & "." & DevID(2)
    End If
End Function



Function ReadDeviceID() As String
    ReDim DevID(10) As Byte
    Dim RetStat As Integer
    Dim picb As PIC
    
    DevID(0) = 0
    DevID(1) = 0
    picb.BootAddr = &H3FFFFE
    picb.BootCmd = 1
    picb.BootDatLen = 2
    picb.MaxRetrys = PicBootS.MaxRetry
    picb.BytesPerBlock = 1
    picb.BytesPerAddr = 1
    RetStat = ReadPIC(PicBootS.PortHandle, picb, DevID(0))
    If RetStat <= 0 Then
        ReadDeviceID = "0"
    Else
        ReadDeviceID = CStr(((DevID(1) * 256) + DevID(0)) \ 32)
    End If
End Function



Function GotoRunMode() As Integer
    ReDim DevID(10) As Byte
    Dim RetStat As Integer
    Dim picb As PIC

    DevID(0) = 0
    picb.BootAddr = &H7FFF
    picb.BootCmd = 5
    picb.BootDatLen = 1
    picb.MaxRetrys = PicBootS.MaxRetry
    picb.BytesPerBlock = 1
    picb.BytesPerAddr = 1
    GotoRunMode = WritePIC(PicBootS.PortHandle, picb, DevID(0))
End Function





Function Dec2Bin(MyByte As Byte) As String
    Dim CurrentData As Integer
    Dim OldData As Integer
    
    Dec2Bin = ""
    OldData = MyByte
    
    For i = 7 To 0 Step -1
     
        CurrentData = OldData - (2 ^ i)
        If CurrentData < 0 Then
            Dec2Bin = Dec2Bin & "0"
        Else
            OldData = CurrentData
            Dec2Bin = Dec2Bin & "1"
        End If
    
    Next i
    
End Function


Function Dec2Hex(MyInteger As Variant, MyWidth As Variant) As String
    Dim TempWork As String
    Dim TempWidth As Long
    Dim TempInt As Long
    
    TempWidth = CLng(MyWidth)
    TempInt = CLng(MyInteger)
    
    TempWork = Hex(TempInt)
    
    If Len(TempWork) > TempWidth Then
        Dec2Hex = Mid(TempWork, Len(TempWork) - TempWidth, TempWidth)
        Exit Function
    End If
    
    Do Until Len(TempWork) = TempWidth
        TempWork = "0" & TempWork
    Loop
    
    Dec2Hex = TempWork
End Function




