Attribute VB_Name = "Module2"
Private Declare Function GetPrivateProfileString Lib "kernel32" Alias "GetPrivateProfileStringA" (ByVal lpApplicationName As String, ByVal lpKeyName As Any, ByVal lpDefault As String, ByVal lpReturnedString As String, ByVal nSize As Long, ByVal lpFileName As String) As Long
Private Declare Function WritePrivateProfileString Lib "kernel32" Alias "WritePrivateProfileStringA" (ByVal lpApplicationName As String, ByVal lpKeyName As Any, ByVal lpString As Any, ByVal lpFileName As String) As Long









Public Function GetSetting(INISection As String, INIKey As String) As String
    Dim MyString As String
    
    'crap = VB.App.EXEName
    
    MyString = "                                                      "
    RetStat = GetPrivateProfileString(INISection, INIKey, "", MyString, 20, VB.App.Path & "\" & VB.App.EXEName & ".INI") '   "\P1618QP.INI")
    GetSetting = Mid(MyString, 1, InStr(1, MyString, Chr(0), vbBinaryCompare) - 1)
End Function


Public Function SetSetting(MySetting As String, INISection As String, INIKey As String) As Long
    SetSetting = WritePrivateProfileString(INISection, INIKey, MySetting, VB.App.Path & "\" & VB.App.EXEName & ".INI") ' "\P1618QP.INI")
End Function










Public Function ExportP18HEXFile(OutHEXFile As String) As Integer
    Dim Checksum As Long
    Dim Address As Long
    Dim OldAddress As Long
    Dim FileLine As String
    Dim OutFileLine As String

    
    Set fs = CreateObject("Scripting.FileSystemObject")
    Set OutFile = fs.CreateTextFile(OutHEXFile, True)
    Set PMIn = fs.OpenTextFile(VB.App.Path & "\" & PicBootS.ProgMemFile, 1, False, 0)
    Set EEIn = fs.OpenTextFile(VB.App.Path & "\" & PicBootS.EEDataFile, 1, False, 0)
    Set UIDIn = fs.OpenTextFile(VB.App.Path & "\" & PicBootS.UserIDFile, 1, False, 0)
    Set CFGIn = fs.OpenTextFile(VB.App.Path & "\" & PicBootS.ConfigFile, 1, False, 0)

    Address = &H7FFFFF
    Do While PMIn.AtEndOfStream <> True
        FileLine = PMIn.ReadLine
        OldAddress = Address
        
        Address = Val("&H1" & Mid(FileLine, 1, 6)) And 16777215
        
        If (Address And 16711680) <> (OldAddress And 16711680) Then
            OutFileLine = ":0200000400" & Dec2Hex((Address And 16711680) \ 65536, 2)
            Checksum = 0
            For i = 0 To 5
                Checksum = Checksum + Val("&H" & Mid(OutFileLine, (i * 2) + 2, 2))
            Next i
            OutFileLine = OutFileLine & Dec2Hex((256 - (Checksum And 255)) And 255, 2)
            OutFile.WriteLine (OutFileLine)
        End If
        
        OutFileLine = ":10" & Dec2Hex(Address And 65535, 4) & "00"
        For i = 0 To 15
            OutFileLine = OutFileLine & Mid(FileLine, (i * 3) + 8, 2)
        Next i
        
        Checksum = 0
        For i = 0 To 19
            Checksum = Checksum + Val("&H" & Mid(OutFileLine, (i * 2) + 2, 2))
        Next i
        
        OutFileLine = OutFileLine & Dec2Hex((256 - (Checksum And 255)) And 255, 2)
        OutFile.WriteLine (OutFileLine)
    Loop
    
    
    Do While UIDIn.AtEndOfStream <> True
        FileLine = UIDIn.ReadLine
        OldAddress = Address
        
        Address = Val("&H1" & Mid(FileLine, 1, 6)) And 16777215
        
        If (Address And 16711680) <> (OldAddress And 16711680) Then
            OutFileLine = ":0200000400" & Dec2Hex((Address And 16711680) \ 65536, 2)
            Checksum = 0
            For i = 0 To 5
                Checksum = Checksum + Val("&H" & Mid(OutFileLine, (i * 2) + 2, 2))
            Next i
            OutFileLine = OutFileLine & Dec2Hex((256 - (Checksum And 255)) And 255, 2)
            OutFile.WriteLine (OutFileLine)
        End If
        
        OutFileLine = ":10" & Dec2Hex(Address And 65535, 4) & "00"
        For i = 0 To 15
            OutFileLine = OutFileLine & Mid(FileLine, (i * 3) + 8, 2)
        Next i
        
        Checksum = 0
        For i = 0 To 19
            Checksum = Checksum + Val("&H" & Mid(OutFileLine, (i * 2) + 2, 2))
        Next i
        
        OutFileLine = OutFileLine & Dec2Hex((256 - (Checksum And 255)) And 255, 2)
        OutFile.WriteLine (OutFileLine)
    Loop
    
    
    Do While CFGIn.AtEndOfStream <> True
        FileLine = CFGIn.ReadLine
        OldAddress = Address
        
        Address = Val("&H1" & Mid(FileLine, 1, 6)) And 16777215
        
        If (Address And 16711680) <> (OldAddress And 16711680) Then
            OutFileLine = ":0200000400" & Dec2Hex((Address And 16711680) \ 65536, 2)
            Checksum = 0
            For i = 0 To 5
                Checksum = Checksum + Val("&H" & Mid(OutFileLine, (i * 2) + 2, 2))
            Next i
            OutFileLine = OutFileLine & Dec2Hex((256 - (Checksum And 255)) And 255, 2)
            OutFile.WriteLine (OutFileLine)
        End If
        
        OutFileLine = ":10" & Dec2Hex(Address And 65535, 4) & "00"
        For i = 0 To 15
            OutFileLine = OutFileLine & Mid(FileLine, (i * 3) + 8, 2)
        Next i
        
        Checksum = 0
        For i = 0 To 19
            Checksum = Checksum + Val("&H" & Mid(OutFileLine, (i * 2) + 2, 2))
        Next i
        
        OutFileLine = OutFileLine & Dec2Hex((256 - (Checksum And 255)) And 255, 2)
        OutFile.WriteLine (OutFileLine)
    Loop
    
    Do While EEIn.AtEndOfStream <> True
        FileLine = EEIn.ReadLine
        OldAddress = Address
        
        Address = (Val("&H1" & Mid(FileLine, 1, 6)) And 16777215) + 15728640
        
        If (Address And 16711680) <> (OldAddress And 16711680) Then
            OutFileLine = ":0200000400" & Dec2Hex((Address And 16711680) \ 65536, 2)
            Checksum = 0
            For i = 0 To 5
                Checksum = Checksum + Val("&H" & Mid(OutFileLine, (i * 2) + 2, 2))
            Next i
            OutFileLine = OutFileLine & Dec2Hex((256 - (Checksum And 255)) And 255, 2)
            OutFile.WriteLine (OutFileLine)
        End If
        
        OutFileLine = ":10" & Dec2Hex(Address And 65535, 4) & "00"
        For i = 0 To 15
            OutFileLine = OutFileLine & Mid(FileLine, (i * 3) + 8, 2)
        Next i
        
        Checksum = 0
        For i = 0 To 19
            Checksum = Checksum + Val("&H" & Mid(OutFileLine, (i * 2) + 2, 2))
        Next i
        
        OutFileLine = OutFileLine & Dec2Hex((256 - (Checksum And 255)) And 255, 2)
        OutFile.WriteLine (OutFileLine)
    Loop

    OutFile.WriteLine (":00000001FF")


    OutFile.Close
    PMIn.Close
    EEIn.Close
    UIDIn.Close
    CFGIn.Close
End Function


Public Function ExportP16HEXFile(OutHEXFile As String) As Integer
    Dim Checksum As Long
    Dim Address As Long
    Dim OldAddress As Long
    Dim FileLine As String
    Dim OutFileLine As String

    
    Set fs = CreateObject("Scripting.FileSystemObject")
    Set OutFile = fs.CreateTextFile(OutHEXFile, True)
    Set PMIn = fs.OpenTextFile(VB.App.Path & "\" & PicBootS.ProgMemFile, 1, False, 0)
    Set EEIn = fs.OpenTextFile(VB.App.Path & "\" & PicBootS.EEDataFile, 1, False, 0)
    
    Do While PMIn.AtEndOfStream <> True
        FileLine = PMIn.ReadLine
        OldAddress = Address
        
        Address = Val("&H1" & Mid(FileLine, 1, 6)) And 16777215
        
        If (Address And 16711680) <> (OldAddress And 16711680) Then
            OutFileLine = ":0200000400" & Dec2Hex((Address And 16711680) \ 65536, 2)
            Checksum = 0
            For i = 0 To 5
                Checksum = Checksum + Val("&H" & Mid(OutFileLine, (i * 2) + 2, 2))
            Next i
            OutFileLine = OutFileLine & Dec2Hex((256 - (Checksum And 255)) And 255, 2)
            OutFile.WriteLine (OutFileLine)
        End If
        
        OutFileLine = ":10" & Dec2Hex(Address And 65535, 4) & "00"
        For i = 0 To 15
            OutFileLine = OutFileLine & Mid(FileLine, (i * 3) + 8, 2)
        Next i
        
        Checksum = 0
        For i = 0 To 19
            Checksum = Checksum + Val("&H" & Mid(OutFileLine, (i * 2) + 2, 2))
        Next i
        
        OutFileLine = OutFileLine & Dec2Hex((256 - (Checksum And 255)) And 255, 2)
        OutFile.WriteLine (OutFileLine)
    Loop
    
    Do While EEIn.AtEndOfStream <> True
        FileLine = EEIn.ReadLine
        OldAddress = Address
        
        Address = (Val("&H1" & Mid(FileLine, 1, 6)) And 16777215) + 8448
        
        If (Address And 16711680) <> (OldAddress And 16711680) Then
            OutFileLine = ":0200000400" & Dec2Hex((Address And 16711680) \ 65536, 2)
            Checksum = 0
            For i = 0 To 5
                Checksum = Checksum + Val("&H" & Mid(OutFileLine, (i * 2) + 2, 2))
            Next i
            OutFileLine = OutFileLine & Dec2Hex((256 - (Checksum And 255)) And 255, 2)
            OutFile.WriteLine (OutFileLine)
        End If
        
        OutFileLine = ":10" & Dec2Hex(Address And 65535, 4) & "00"
        For i = 0 To 15
            OutFileLine = OutFileLine & Mid(FileLine, (i * 3) + 8, 2)
        Next i
        
        Checksum = 0
        For i = 0 To 19
            Checksum = Checksum + Val("&H" & Mid(OutFileLine, (i * 2) + 2, 2))
        Next i
        
        OutFileLine = OutFileLine & Dec2Hex((256 - (Checksum And 255)) And 255, 2)
        OutFile.WriteLine (OutFileLine)
    Loop

    OutFile.WriteLine (":00000001FF")


    OutFile.Close
    PMIn.Close
    EEIn.Close
End Function




Public Function ImportP18HEXFile(InHEXFile As String) As Integer
    Dim FileLine
    Dim InData(256) As Byte
    
    Dim LineData As String
    Dim LineDataCount As Byte
    Dim LineAddr As Long
    Dim LineCode As Byte
       
    Dim DataCount As Byte
    Dim OutAddr As Long
    Dim LongAddr As Long
    Dim Checksum As Long
    Dim OutOffset As Long
    
    Dim OutLine As String
    
    Dim LineAddrHigh As Long
    
    'Examine the HEX file for incompatability
    ImportP18HEXFile = ValidateHEXFile(InHEXFile)
    If ImportP18HEXFile < 0 Then
        Exit Function
    End If
    
    Set fs = CreateObject("Scripting.FileSystemObject")
    Set InFile = fs.OpenTextFile(InHEXFile, 1, False, 0)
    Set PMOut = fs.CreateTextFile(VB.App.Path & "\" & PicBootS.ProgMemFile, True)
    Set EEOut = fs.CreateTextFile(VB.App.Path & "\" & PicBootS.EEDataFile, True)
    Set UIDOut = fs.CreateTextFile(VB.App.Path & "\" & PicBootS.UserIDFile, True)
    Set CFGOut = fs.CreateTextFile(VB.App.Path & "\" & PicBootS.ConfigFile, True)
        
    Do While InFile.AtEndOfStream <> True
        FileLine = InFile.ReadLine
        
        'Init the array with 0xFF
        For i = 0 To 255
            InData(i) = 255
        Next i
        
        LineCode = 0
        If Mid(FileLine, 1, 1) = ":" Then
            'Parse the line
            LineDataCount = Val("&H" & Mid(FileLine, 2, 2))
            LineAddr = Val("&H1" & Mid(FileLine, 4, 4)) And 65535
            LineCode = Val("&H" & Mid(FileLine, 8, 2))
            LineData = Mid(FileLine, 10, (LineDataCount * 2))
        
        
            Select Case LineCode
                Case 0
                    'Get and order the data
                    OutOffset = LineAddr Mod 16
                    For i = 0 To LineDataCount - 1
                        InData(i + OutOffset) = Val("&H" & Mid(LineData, (i * 2) + 1, 2))
                    Next i
                
                    Select Case LineAddrHigh
                        Case 0 To 31                  ' regular program memory
                            
                            'Build one or more formatted lines
                            OutAddr = (LineAddrHigh * 65536) + (LineAddr And 65520)
                            DataCount = 0
                            Do While DataCount < LineDataCount
                                'Built a formatted line of data
                                OutLine = Dec2Hex(OutAddr, 6) & " "
                                For i = DataCount To DataCount + 15
                                    OutLine = OutLine & Dec2Hex(InData(i), 2) & " "
                                    OutAddr = OutAddr + 1
                                Next i
                                DataCount = DataCount + 16
                                PMOut.WriteLine (OutLine)
                            Loop
                                               
                        
                        Case 32                 ' user ID memory
                            'Build one or more formatted lines
                            OutAddr = (LineAddrHigh * 65536) + (LineAddr And 65520)
                            DataCount = 0
                            Do While DataCount < LineDataCount
                                'Built a formatted line of data
                                OutLine = Dec2Hex(OutAddr, 6) & " "
                                For i = DataCount To DataCount + 15
                                    OutLine = OutLine & Dec2Hex(InData(i), 2) & " "
                                    OutAddr = OutAddr + 1
                                Next i
                                DataCount = DataCount + 16
                                UIDOut.WriteLine (OutLine)
                            Loop
                            
                      
                        Case 48                ' config memory
                            'Build one or more formatted lines
                            OutAddr = (LineAddrHigh * 65536) + (LineAddr And 65520)
                            DataCount = 0
                            Do While DataCount < LineDataCount
                                'Built a formatted line of data
                                OutLine = Dec2Hex(OutAddr, 6) & " "
                                For i = DataCount To DataCount + 15
                                    OutLine = OutLine & Dec2Hex(InData(i), 2) & " "
                                    OutAddr = OutAddr + 1
                                Next i
                                DataCount = DataCount + 16
                                CFGOut.WriteLine (OutLine)
                            Loop
                            
                           
                        Case 240                ' EEDATA memory
                                                        
                            'Build one or more formatted lines
                            OutAddr = (LineAddr And 65520)
                            DataCount = 0
                            Do While DataCount < LineDataCount
                                'Built a formatted line of data
                                OutLine = Dec2Hex(OutAddr, 6) & " "
                                For i = DataCount To DataCount + 15
                                    OutLine = OutLine & Dec2Hex(InData(i), 2) & " "
                                    OutAddr = OutAddr + 1
                                Next i
                                DataCount = DataCount + 16
                                EEOut.WriteLine (OutLine)
                            Loop
                               
                    End Select
                    
                Case 1
                    Exit Do
                    
                Case 4
                    LineAddrHigh = (Val("&H1" & Mid(FileLine, 10, 4)) And 65535)
                                        
            End Select
        End If
    Loop
    
    InFile.Close
    PMOut.Close
    EEOut.Close
    UIDOut.Close
    CFGOut.Close
End Function









Public Function ImportP16HEXFile(InHEXFile As String) As Integer
    Dim FileLine
    Dim InData(256) As Byte
    
    Dim LineData As String
    Dim LineDataCount As Byte
    Dim LineAddr As Long
    Dim LineCode As Byte
       
    Dim DataCount As Byte
    Dim OutAddr As Long
    Dim LongAddr As Long
    Dim Checksum As Long
    Dim OutOffset As Long
    
    Dim OutLine As String
    
    Dim LineAddrHigh As Long
    
    'Examine the HEX file for incompatability
    ImportP16HEXFile = ValidateHEXFile(InHEXFile)
    If ImportP16HEXFile < 0 Then
        Exit Function
    End If
    
    Set fs = CreateObject("Scripting.FileSystemObject")
    Set InFile = fs.OpenTextFile(InHEXFile, 1, False, 0)
    Set PMOut = fs.CreateTextFile(VB.App.Path & "\" & PicBootS.ProgMemFile, True)
    Set EEOut = fs.CreateTextFile(VB.App.Path & "\" & PicBootS.EEDataFile, True)
    
    Do While InFile.AtEndOfStream <> True
        FileLine = InFile.ReadLine
        
        'Init the array with 0xFF
        For i = 0 To 255
            InData(i) = 255
        Next i
        
        LineCode = 0
        If Mid(FileLine, 1, 1) = ":" Then
            'Parse the line
            LineDataCount = Val("&H" & Mid(FileLine, 2, 2))
            LineAddr = Val("&H1" & Mid(FileLine, 4, 4)) And 65535
            LineCode = Val("&H" & Mid(FileLine, 8, 2))
            LineData = Mid(FileLine, 10, (LineDataCount * 2))
        
        
            Select Case LineCode
                Case 0
                    'Get and order the data
                    OutOffset = LineAddr Mod 16
                    For i = 0 To LineDataCount - 1
                        InData(i + OutOffset) = Val("&H" & Mid(LineData, (i * 2) + 1, 2))
                    Next i
                
                    If LineAddrHigh = 0 Then
                        Select Case Address
                            Case 0 To 8191                  ' regular program memory
                            
                                'Build one or more formatted lines
                                OutAddr = (LineAddrHigh * 65536) + (LineAddr And 65520)
                                DataCount = 0
                                Do While DataCount < LineDataCount
                                    'Built a formatted line of data
                                    OutLine = Dec2Hex(OutAddr, 6) & " "
                                    For i = DataCount To DataCount + 15
                                        OutLine = OutLine & Dec2Hex(InData(i), 2) & " "
                                        OutAddr = OutAddr + 1
                                    Next i
                                    DataCount = DataCount + 16
                                    PMOut.WriteLine (OutLine)
                                Loop
                                
                           
                            Case 8448 To 8959               ' EEDATA memory
                                OutAddr = (LineAddr And 65520)
                                DataCount = 0
                                Do While DataCount < LineDataCount
                                    'Built a formatted line of data
                                    OutLine = Dec2Hex(OutAddr, 6) & " "
                                    For i = DataCount To DataCount + 15
                                        OutLine = OutLine & Dec2Hex(InData(i), 2) & " "
                                        OutAddr = OutAddr + 1
                                    Next i
                                    DataCount = DataCount + 16
                                    EEOut.WriteLine (OutLine)
                                Loop
                               
                        End Select
                    End If
                    
                Case 1
                    Exit Do
                    
                Case 4
                    LineAddrHigh = (Val("&H1" & Mid(FileLine, 10, 4)) And 65535)
                    
            End Select
        End If
    Loop
    
    InFile.Close
    PMOut.Close
    EEOut.Close
End Function













Function ValidateHEXFile(InHEXFile As String) As Integer
    Dim Checksum As Integer
    Dim InFileLine As String
    Dim DataCount As Integer
    Dim AddrCode As Integer
    Dim Address As Long
    Dim DataByte As Integer
        
    On Error GoTo ErrorHandler
    
        
    Set fs = CreateObject("Scripting.FileSystemObject")
    ChDir VB.App.Path
    Set InFile = fs.OpenTextFile(InHEXFile, 1, False, 0)
    
    'Check for an empty file
    If InFile.AtEndOfStream = True Then
        ValidateHEXFile = -1
        InFile.Close
        Exit Function
    End If
    
    'Validate the file before using it
    Do While InFile.AtEndOfStream <> True
        InFileLine = InFile.ReadLine
        
        AddrCode = 0
        If Mid(InFileLine, 1, 1) = "" Then
            DataByte = Asc(" ")
        Else
            DataByte = Asc(Mid(InFileLine, 1, 1))
        End If
        
        'check the line
        Select Case DataByte
            Case Asc(":")
                AddrCode = Val("&H" & Mid(InFileLine, 8, 2))
                DataCount = Val("&H" & Mid(InFileLine, 2, 2))
                Address = Val("&H1" & Mid(InFileLine, 4, 4)) And 65535
                
                'check count and alignment of regular data
'                If AddrCode = 0 Then
'                    If DataCount Mod 16 <> 0 Then
'                        ValidateHEXFile = -2
'                    End If
'                    If Address Mod 16 <> 0 Then
'                        ValidateHEXFile = -2
'                    End If
'                End If
                    
            
                Checksum = 0
                For i = 0 To DataCount + 4
                    Checksum = Checksum + Val("&H" & Mid(InFileLine, (2 * i) + 2, 2))
                Next i
            
                If (Checksum And 255) <> 0 Then
                    ValidateHEXFile = -3
                    InFile.Close
                    Exit Function
                End If
            Case Asc(" "), Asc(vbTab), Asc(vbCr), Asc(vbLf)
            Case Else
                ValidateHEXFile = -4
                InFile.Close
                Exit Function
        End Select
        
        If AddrCode = 1 Then
            Exit Do
        End If
        
        If InFile.AtEndOfStream = True Then
            ValidateHEXFile = -5
            InFile.Close
            Exit Function
        End If
    Loop
    
    If ValidateHEXFile <> -2 Then
        ValidateHEXFile = 1
    End If
    
    InFile.Close
    Exit Function
    
ErrorHandler:
    Err.Clear
    ValidateHEXFile = -6
    InFile.Close
End Function





Function ConvertHEX(InHEXFile As String, OutHEXFile As String) As Integer
    Dim BufferData(256) As Byte
    Dim BufferCount As Integer
    Dim Checksum As Integer
    Dim InFileLine As String
    Dim OutFileLine As String
    Dim DataString As String
    Dim DataCount As Integer
    Dim DataCode As Integer
    Dim Address As Integer
    Dim HighAddress As Long
    Dim DataStr As String
    Dim NewAddr As Long

    'Open file objects
    Set fs = CreateObject("Scripting.FileSystemObject")
    ChDir VB.App.Path
    Set InFile = fs.OpenTextFile(InHEXFile, 1, False, 0)
    Set OutFile = fs.CreateTextFile(OutHEXFile, True)


    Do While InFile.AtEndOfStream <> True
        InFileLine = InFile.ReadLine
        
        If Mid(InFileLine, 1, 1) = ":" Then
            DataCount = Val("&H" & Mid(InFileLine, 2, 2))
            DataCode = Val("&H" & Mid(InFileLine, 8, 2))
            Address = Val("&H1" & Mid(InFileLine, 4, 4)) And 65535
            DataStr = Mid(InFileLine, 10, DataCount * 2)
            
            
            Select Case DataCode
                Case 0
                    For i = 0 To DataCount - 1
                        BufferData(i) = Val("&H" & Mid(DataStr, (i * 2) + 1, 2))
                    Next i
                    
                
                Case 1
                    Exit Do
                Case 4
                    HighAddress = Val("&H" & DataStr)
            
            End Select
        End If
    
    
    Loop


    InFile.Close
    OutFile.Close
End Function
