VERSION 5.00
Object = "{831FDD16-0C5C-11D2-A9FC-0000F8754DA1}#2.0#0"; "MSCOMCTL.OCX"
Object = "{F9043C88-F6F2-101A-A3C9-08002B2F49FB}#1.2#0"; "COMDLG32.OCX"
Begin VB.Form Fm_Bootload 
   Caption         =   "PIC18F/PIC16F Quick Programmer"
   ClientHeight    =   1335
   ClientLeft      =   165
   ClientTop       =   450
   ClientWidth     =   5595
   Icon            =   "Form100.frx":0000
   LinkTopic       =   "Form1"
   MaxButton       =   0   'False
   ScaleHeight     =   1335
   ScaleWidth      =   5595
   StartUpPosition =   3  'Windows Default
   Begin MSComDlg.CommonDialog CommonDialog1 
      Left            =   2760
      Top             =   480
      _ExtentX        =   847
      _ExtentY        =   847
      _Version        =   393216
   End
   Begin MSComctlLib.ImageList ImageList2 
      Left            =   600
      Top             =   480
      _ExtentX        =   1005
      _ExtentY        =   1005
      BackColor       =   -2147483643
      ImageWidth      =   16
      ImageHeight     =   16
      MaskColor       =   16711935
      _Version        =   393216
      BeginProperty Images {2C247F25-8591-11D1-B16A-00C0F0283628} 
         NumListImages   =   10
         BeginProperty ListImage1 {2C247F27-8591-11D1-B16A-00C0F0283628} 
            Picture         =   "Form100.frx":030A
            Key             =   ""
         EndProperty
         BeginProperty ListImage2 {2C247F27-8591-11D1-B16A-00C0F0283628} 
            Picture         =   "Form100.frx":065E
            Key             =   ""
         EndProperty
         BeginProperty ListImage3 {2C247F27-8591-11D1-B16A-00C0F0283628} 
            Picture         =   "Form100.frx":09B2
            Key             =   ""
         EndProperty
         BeginProperty ListImage4 {2C247F27-8591-11D1-B16A-00C0F0283628} 
            Picture         =   "Form100.frx":0D06
            Key             =   ""
         EndProperty
         BeginProperty ListImage5 {2C247F27-8591-11D1-B16A-00C0F0283628} 
            Picture         =   "Form100.frx":105A
            Key             =   ""
         EndProperty
         BeginProperty ListImage6 {2C247F27-8591-11D1-B16A-00C0F0283628} 
            Picture         =   "Form100.frx":13AE
            Key             =   ""
         EndProperty
         BeginProperty ListImage7 {2C247F27-8591-11D1-B16A-00C0F0283628} 
            Picture         =   "Form100.frx":1702
            Key             =   ""
         EndProperty
         BeginProperty ListImage8 {2C247F27-8591-11D1-B16A-00C0F0283628} 
            Picture         =   "Form100.frx":1A56
            Key             =   ""
         EndProperty
         BeginProperty ListImage9 {2C247F27-8591-11D1-B16A-00C0F0283628} 
            Picture         =   "Form100.frx":1DAA
            Key             =   ""
         EndProperty
         BeginProperty ListImage10 {2C247F27-8591-11D1-B16A-00C0F0283628} 
            Picture         =   "Form100.frx":20FE
            Key             =   ""
         EndProperty
      EndProperty
   End
   Begin MSComctlLib.Toolbar Toolbar1 
      Align           =   1  'Align Top
      Height          =   360
      Left            =   0
      TabIndex        =   1
      Top             =   0
      Width           =   5595
      _ExtentX        =   9869
      _ExtentY        =   635
      ButtonWidth     =   609
      ButtonHeight    =   582
      AllowCustomize  =   0   'False
      Appearance      =   1
      Style           =   1
      ImageList       =   "ImageList2"
      _Version        =   393216
      BeginProperty Buttons {66833FE8-8583-11D1-B16A-00C0F0283628} 
         NumButtons      =   14
         BeginProperty Button1 {66833FEA-8583-11D1-B16A-00C0F0283628} 
            Key             =   "Open"
            Object.ToolTipText     =   "Open HEX File"
            ImageIndex      =   1
         EndProperty
         BeginProperty Button2 {66833FEA-8583-11D1-B16A-00C0F0283628} 
            Key             =   "Save"
            Object.ToolTipText     =   "Save HEX File"
            ImageIndex      =   2
         EndProperty
         BeginProperty Button3 {66833FEA-8583-11D1-B16A-00C0F0283628} 
            Style           =   3
         EndProperty
         BeginProperty Button4 {66833FEA-8583-11D1-B16A-00C0F0283628} 
            Key             =   "Clear"
            Object.ToolTipText     =   "Clear Memory"
            ImageIndex      =   3
         EndProperty
         BeginProperty Button5 {66833FEA-8583-11D1-B16A-00C0F0283628} 
            Key             =   "View"
            Object.ToolTipText     =   "View Memory"
            ImageIndex      =   4
         EndProperty
         BeginProperty Button6 {66833FEA-8583-11D1-B16A-00C0F0283628} 
            Style           =   3
         EndProperty
         BeginProperty Button7 {66833FEA-8583-11D1-B16A-00C0F0283628} 
            Key             =   "Abort"
            Object.ToolTipText     =   "Abort Operation"
            ImageIndex      =   5
         EndProperty
         BeginProperty Button8 {66833FEA-8583-11D1-B16A-00C0F0283628} 
            Style           =   3
         EndProperty
         BeginProperty Button9 {66833FEA-8583-11D1-B16A-00C0F0283628} 
            Key             =   "Connect"
            Object.ToolTipText     =   "Connect to Device"
            ImageIndex      =   6
            Style           =   1
         EndProperty
         BeginProperty Button10 {66833FEA-8583-11D1-B16A-00C0F0283628} 
            Key             =   "Read"
            Object.ToolTipText     =   "Read Device"
            ImageIndex      =   7
         EndProperty
         BeginProperty Button11 {66833FEA-8583-11D1-B16A-00C0F0283628} 
            Key             =   "Write"
            Object.ToolTipText     =   "Write Device"
            ImageIndex      =   8
         EndProperty
         BeginProperty Button12 {66833FEA-8583-11D1-B16A-00C0F0283628} 
            Key             =   "Erase"
            Object.ToolTipText     =   "Erase Device"
            ImageIndex      =   9
         EndProperty
         BeginProperty Button13 {66833FEA-8583-11D1-B16A-00C0F0283628} 
            Style           =   3
         EndProperty
         BeginProperty Button14 {66833FEA-8583-11D1-B16A-00C0F0283628} 
            Key             =   "Run"
            Object.ToolTipText     =   "Normal Execution Mode"
            ImageIndex      =   10
         EndProperty
      EndProperty
   End
   Begin MSComctlLib.StatusBar StatusBar1 
      Align           =   2  'Align Bottom
      Height          =   255
      Left            =   0
      TabIndex        =   0
      Top             =   1080
      Width           =   5595
      _ExtentX        =   9869
      _ExtentY        =   450
      _Version        =   393216
      BeginProperty Panels {8E3867A5-8586-11D1-B16A-00C0F0283628} 
         NumPanels       =   5
         BeginProperty Panel1 {8E3867AB-8586-11D1-B16A-00C0F0283628} 
            AutoSize        =   1
            Object.Width           =   5238
            MinWidth        =   1058
            Text            =   "Status"
            TextSave        =   "Status"
            Key             =   "PStatus"
            Object.ToolTipText     =   "Right click for memory read/write settings."
         EndProperty
         BeginProperty Panel2 {8E3867AB-8586-11D1-B16A-00C0F0283628} 
            Alignment       =   1
            AutoSize        =   2
            Object.Width           =   556
            MinWidth        =   529
            Text            =   "NA"
            TextSave        =   "NA"
            Key             =   "FirmVer"
            Object.ToolTipText     =   "Firmware version."
         EndProperty
         BeginProperty Panel3 {8E3867AB-8586-11D1-B16A-00C0F0283628} 
            Alignment       =   1
            AutoSize        =   2
            Object.Width           =   1693
            MinWidth        =   706
            Text            =   "UNKNOWN"
            TextSave        =   "UNKNOWN"
            Object.ToolTipText     =   "PIC device, right click to select."
         EndProperty
         BeginProperty Panel4 {8E3867AB-8586-11D1-B16A-00C0F0283628} 
            Alignment       =   1
            AutoSize        =   2
            Object.Width           =   953
            MinWidth        =   706
            Text            =   "COM1"
            TextSave        =   "COM1"
            Key             =   "CommPort"
            Object.ToolTipText     =   "Right click to change COM port."
         EndProperty
         BeginProperty Panel5 {8E3867AB-8586-11D1-B16A-00C0F0283628} 
            Alignment       =   1
            AutoSize        =   2
            Object.Width           =   794
            MinWidth        =   706
            Text            =   "9600"
            TextSave        =   "9600"
            Key             =   "BitRate"
            Object.ToolTipText     =   "Right click to set bit rate."
         EndProperty
      EndProperty
   End
   Begin VB.Menu M_PortSettings 
      Caption         =   "PortSettings"
      Visible         =   0   'False
      Begin VB.Menu M_FPPort 
         Caption         =   "COM1"
         Checked         =   -1  'True
         Index           =   1
      End
      Begin VB.Menu M_FPPort 
         Caption         =   "COM2"
         Index           =   2
      End
      Begin VB.Menu M_FPPort 
         Caption         =   "COM3"
         Index           =   3
      End
      Begin VB.Menu M_FPPort 
         Caption         =   "COM4"
         Index           =   4
      End
   End
   Begin VB.Menu M_BitRateSettings 
      Caption         =   "BitRatetSettings"
      Visible         =   0   'False
      Begin VB.Menu M_FPBaud 
         Caption         =   "9600"
         Checked         =   -1  'True
         Index           =   1
      End
      Begin VB.Menu M_FPBaud 
         Caption         =   "19200"
         Index           =   2
      End
      Begin VB.Menu M_FPBaud 
         Caption         =   "38400"
         Index           =   3
      End
      Begin VB.Menu M_FPBaud 
         Caption         =   "57600"
         Index           =   4
      End
      Begin VB.Menu M_FPBaud 
         Caption         =   "115200"
         Index           =   5
      End
   End
   Begin VB.Menu M_Program 
      Caption         =   "Program"
      Visible         =   0   'False
      Begin VB.Menu M_PDevSelector 
         Caption         =   "Device Selector"
      End
      Begin VB.Menu space104 
         Caption         =   "-"
      End
      Begin VB.Menu M_MemAccess 
         Caption         =   "FLASH"
         Checked         =   -1  'True
         Index           =   1
      End
      Begin VB.Menu M_MemAccess 
         Caption         =   "EEDATA"
         Checked         =   -1  'True
         Index           =   2
      End
      Begin VB.Menu M_MemAccess 
         Caption         =   "CONFIG"
         Index           =   3
      End
      Begin VB.Menu M_MemAccess 
         Caption         =   "USERID"
         Index           =   4
      End
      Begin VB.Menu space102 
         Caption         =   "-"
      End
      Begin VB.Menu M_PSendCfg 
         Caption         =   "Send Config"
      End
      Begin VB.Menu space101 
         Caption         =   "-"
      End
      Begin VB.Menu M_About 
         Caption         =   "About"
      End
   End
End
Attribute VB_Name = "Fm_Bootload"
Attribute VB_GlobalNameSpace = False
Attribute VB_Creatable = False
Attribute VB_PredeclaredId = True
Attribute VB_Exposed = False


Const STATUS_NOT_CON As String = "Not connected..."
Const STATUS_DEVICE_FOUND As String = " detected..."
Const STATUS_DATA_FILE_NOT_FOUND As String = "Data file not found..."
Const STATUS_FAILED_TO_OPEN_PORT As String = "Failed to open port..."
Const STATUS_NO_VERSION_INFO As String = "No firmware version available..."
Const STATUS_FOUND_DEVICE As String = "Device found..."
Const STATUS_READ_FAILURE As String = "Failed to read device..."
Const STATUS_WRITE_FAILURE As String = "Failed to write device..."
Const STATUS_ABORT As String = "Operation aborted..."
Const STATUS_FINISHED As String = "Finished operation..."
Const STATUS_VERIFY_ERROR As String = "Verify error received..."
Const STATUS_RUNMODE_SET As String = "Run mode is set..."
Const STATUS_HEX_FORMAT As String = "HEX file not padded properly..."
Const STATUS_HEX_IMPORTED As String = "HEX file imported..."
Const STATUS_INVALID_HEX As String = "Invalid HEX file..."
Const STATUS_HEX_EXPORTED As String = "HEX file exported..."



Const MODE_NOT_CONNECTED As Integer = 0
Const MODE_CONNECTED_IDLE As Integer = 1
Const MODE_WORKING As Integer = 2

Const PANEL_STATUS As Integer = 1
Const PANEL_FWVER As Integer = 2
Const PANEL_DEVICE As Integer = 3
Const PANEL_PORT As Integer = 4
Const PANEL_BITRATE As Integer = 5


'Flag used for a
Dim PanelClicked As Integer
Dim HideToolFlag As Byte












Private Sub M_PDevSelector_Click()
    DisconnectDev

    D_SelectDevice.Cm_DevList.ListIndex = 0
    D_SelectDevice.Show vbModal, Fm_Bootload
End Sub


Private Sub M_PSendCfg_Click()
    D_WriteFuses.Show vbModal, Fm_Bootload
End Sub











Private Sub StatusBar1_MouseUp(Button As Integer, Shift As Integer, x As Single, y As Single)
    If Button = 2 Then
        If PanelClicked = 1 Then
            PopupMenu M_Program, vbPopupMenuRightButton
        End If
    
        If PanelClicked = 3 Then
            M_PDevSelector_Click
        End If
    
        If PanelClicked = 4 Then
            PopupMenu M_PortSettings, vbPopupMenuRightButton
        End If
    
        If PanelClicked = 5 Then
            PopupMenu M_BitRateSettings, vbPopupMenuRightButton
        End If
    End If
End Sub

Private Sub StatusBar1_PanelClick(ByVal Panel As Panel)
    PanelClicked = Panel.Index
End Sub

















'******************************************************************************
'Main Form related functions
'******************************************************************************
Private Sub Form_Load()

    On Error GoTo ErrorHandler

    'Set the size
    Me.Height = Toolbar1.Height + StatusBar1.Height + 600
    Me.Width = 5000
                
    SetDisplayMode MODE_NOT_CONNECTED
    
    PicBootS.ProgMemFile = GetSetting("PIC18FBOOT", "progmem")
    PicBootS.EEDataFile = GetSetting("PIC18FBOOT", "eedata")
    PicBootS.UserIDFile = GetSetting("PIC18FBOOT", "userid")
    PicBootS.ConfigFile = GetSetting("PIC18FBOOT", "config")
    PicBootS.ErrorLogFile = GetSetting("PIC18FBOOT", "errorlog")
    PicBootS.CommTimeOut = Val(GetSetting("PIC18FBOOT", "CommTimeOut"))
    PicBootS.DebugLevel = Val(GetSetting("PIC18FBOOT", "debuglevel"))
    PicBootS.DeviceMode = Val(GetSetting("PIC18FBOOT", "devicemode"))
    PicBootS.MaxRetry = Val(GetSetting("PIC18FBOOT", "maxretry"))
    PicBootS.EditorFile = GetSetting("PIC18FBOOT", "editor")
    
    If CInt(GetSetting("PIC18FBOOT", "selectdevwin")) Then
        D_SelectDevice.Cm_DevList.ListIndex = 0
        D_SelectDevice.Show vbModal, Fm_Bootload
    End If
        
    PicBootS.ProgMemAddrH = &H200
    PicBootS.ProgMemAddrL = &H200
    PicBootS.EEDataAddrH = 0
    PicBootS.EEDataAddrL = 0
    PicBootS.ConfigAddrH = &H300000
    PicBootS.ConfigAddrL = &H300000
    PicBootS.UserIDAddrH = &H200000
    PicBootS.UserIDAddrL = &H200000
    
       
    MyIndex = GetSetting("PIC18FBOOT", "portindex")
    M_FPPort_Click (CInt(MyIndex))
    MyIndex = GetSetting("PIC18FBOOT", "bitrateindex")
    M_FPBaud_Click (CInt(MyIndex))
    
    StatusBar1.Panels(PANEL_STATUS).Text = STATUS_NOT_CON
    
    Exit Sub
    
ErrorHandler:
    
    StatusBar1.Panels(PANEL_STATUS).Text = "Core error:  " & Err.Description
    Err.Clear
End Sub


Private Sub Form_Unload(Cancel As Integer)
    'Close port if open
    If PicBootS.PortHandle > 0 Then
        ClosePIC (PicBootS.PortHandle)
        PicBootS.PortHandle = 0
    End If

    'Kill Fuse configurator
    Unload D_WriteFuses
End Sub


Private Sub Form_Resize()

    On Error GoTo ErrorHandler

    Me.Height = Toolbar1.Height + StatusBar1.Height + 600
    If Me.Width < 5000 Then
        Me.Width = 5000
    End If
    
    Exit Sub
ErrorHandler:
    Err.Clear

End Sub
'******************************************************************************










Private Sub ConnectToPIC()
    Dim TempReturn As String
    Dim RetStat As Integer
    Dim picb As PIC
    Dim DevID(10) As Byte
        
    On Error GoTo ErrorHandler
    
    If PicBootS.PortHandle <= 0 Then
        PicBootS.PortHandle = OpenPIC(PicBootS.CommPort, PicBootS.BitRate, PicBootS.CommTimeOut)
    End If
    If PicBootS.PortHandle < 0 Then
        StatusBar1.Panels(PANEL_STATUS) = STATUS_FAILED_TO_OPEN_PORT
        Toolbar1.Buttons(9).Value = tbrUnpressed
        Exit Sub
    End If
    
    'Get firmware version
    StatusBar1.Panels(PANEL_FWVER) = ReadVersion
    If StatusBar1.Panels(PANEL_FWVER) = Empty Then
        StatusBar1.Panels(PANEL_STATUS) = STATUS_NO_VERSION_INFO
    End If
    
    'Read associated device name
    If PicBootS.DeviceMode = 0 Then 'manual or automatic
        PicBootS.DeviceCode = ReadDeviceID
        PicBootS.DeviceName = GetSetting("DEVICELIST", PicBootS.DeviceCode)
    End If
    
    'Read in the memory ranges
    PicBootS.ProgMemAddrL = Val("&H" & GetSetting(PicBootS.DeviceName, "pmrangelow"))
    PicBootS.ProgMemAddrH = Val("&H" & GetSetting(PicBootS.DeviceName, "pmrangehigh"))
    PicBootS.EEDataAddrL = Val("&H" & GetSetting(PicBootS.DeviceName, "eerangelow"))
    PicBootS.EEDataAddrH = Val("&H" & GetSetting(PicBootS.DeviceName, "eerangehigh"))
    PicBootS.UserIDAddrL = Val("&H" & GetSetting(PicBootS.DeviceName, "usrrangelow"))
    PicBootS.UserIDAddrH = Val("&H" & GetSetting(PicBootS.DeviceName, "usrrangehigh"))
    PicBootS.ConfigAddrL = Val("&H" & GetSetting(PicBootS.DeviceName, "cfgrangelow"))
    PicBootS.ConfigAddrH = Val("&H" & GetSetting(PicBootS.DeviceName, "cfgrangehigh"))
    
    PicBootS.DevBytesPerAddr = Val(GetSetting(PicBootS.DeviceName, "bytesperaddr"))
    PicBootS.MaxPacketSize = Val(GetSetting(PicBootS.DeviceName, "maxpacketsize"))
    PicBootS.DeviceErsBlock = Val(GetSetting(PicBootS.DeviceName, "eraseblock"))
    PicBootS.DeviceRdBlock = Val(GetSetting(PicBootS.DeviceName, "readblock"))
    PicBootS.DeviceWrtBlock = Val(GetSetting(PicBootS.DeviceName, "writeblock"))
    PicBootS.DeviceType = Val(GetSetting(PicBootS.DeviceName, "devicetype"))
 
    'Read in the config bytes
    D_WriteFuses.C_ConfigBytes.Clear
    For i = PicBootS.ConfigAddrL To PicBootS.ConfigAddrH
        TempReturn = GetSetting(PicBootS.DeviceName, Dec2Hex(CLng(i), 6))
        If StrComp(TempReturn, "") <> 0 Then
            D_WriteFuses.C_ConfigBytes.AddItem TempReturn
            D_WriteFuses.C_ConfigBytes.ItemData(MyCount) = i
            MyCount = MyCount + 1
        End If
    Next i
    StatusBar1.Panels(PANEL_DEVICE) = PicBootS.DeviceName
    StatusBar1.Panels(PANEL_STATUS) = STATUS_FOUND_DEVICE
    
    SetDisplayMode MODE_CONNECTED_IDLE
    
    Exit Sub

'Handle some errors
ErrorHandler:
     
    StatusBar1.Panels(PANEL_STATUS).Text = "Core error:  " & Err.Description
    Err.Clear
End Sub







Private Sub M_About_Click()
    frmAbout.Show vbModal, Fm_Bootload
End Sub





'******************************************************************************
'Data file related functions
'******************************************************************************
Private Sub EraseDataFiles()
    
    Open VB.App.Path & "\" & PicBootS.ProgMemFile For Output As #1
    Close #1
    
    Open VB.App.Path & "\" & PicBootS.EEDataFile For Output As #1
    Close #1
    
    Open VB.App.Path & "\" & PicBootS.UserIDFile For Output As #1
    Close #1
    
    Open VB.App.Path & "\" & PicBootS.ConfigFile For Output As #1
    Close #1
End Sub


Private Sub ViewDataFiles()
    'MsgBox VB.App.Path
    
    If M_MemAccess(1).Checked = True Then
        test = Shell(PicBootS.EditorFile & " " & VB.App.Path & "\" & PicBootS.ProgMemFile, vbNormalFocus)
    End If
    
    If M_MemAccess(2).Checked = True Then
        test = Shell(PicBootS.EditorFile & " " & VB.App.Path & "\" & PicBootS.EEDataFile, vbNormalFocus)
    End If
    
    If M_MemAccess(3).Checked = True Then
        test = Shell(PicBootS.EditorFile & " " & VB.App.Path & "\" & PicBootS.ConfigFile, vbNormalFocus)
    End If
    
    If M_MemAccess(4).Checked = True Then
        test = Shell(PicBootS.EditorFile & " " & VB.App.Path & "\" & PicBootS.UserIDFile, vbNormalFocus)
    End If
    
End Sub
'******************************************************************************







'******************************************************************************
'Port related setting functions
'******************************************************************************
Private Sub M_FPBaud_Click(Index As Integer)
    
    DisconnectDev
    
    M_FPBaud(1).Checked = Not CBool(Index Xor 1)
    M_FPBaud(2).Checked = Not CBool(Index Xor 2)
    M_FPBaud(3).Checked = Not CBool(Index Xor 3)
    M_FPBaud(4).Checked = Not CBool(Index Xor 4)
    M_FPBaud(5).Checked = Not CBool(Index Xor 5)
    
    PicBootS.BitRate = CLng(M_FPBaud(Index).Caption)
    
    StatusBar1.Panels(PANEL_BITRATE) = M_FPBaud(Index).Caption
    
    SetDisplayMode MODE_NOT_CONNECTED
            
End Sub


Private Sub M_FPPort_Click(Index As Integer)
        
    DisconnectDev
            
    M_FPPort(1).Checked = Not CBool(Index Xor 1)
    M_FPPort(2).Checked = Not CBool(Index Xor 2)
    M_FPPort(3).Checked = Not CBool(Index Xor 3)
    M_FPPort(4).Checked = Not CBool(Index Xor 4)
     
    PicBootS.CommPort = M_FPPort(Index).Caption
     
    StatusBar1.Panels(PANEL_PORT) = M_FPPort(Index).Caption
     
    SetDisplayMode MODE_NOT_CONNECTED
        
End Sub
'******************************************************************************




Private Sub M_MemAccess_Click(Index As Integer)
    If M_MemAccess(Index).Checked = True Then
        M_MemAccess(Index).Checked = False
    Else
        M_MemAccess(Index).Checked = True
    End If
End Sub









'******************************************************************************
'Toolbar related functions
'******************************************************************************
Private Sub Toolbar1_ButtonClick(ByVal Button As MSComctlLib.Button)
    Dim sFile As String


    Select Case Button.Key
        Case "Open"
                
            With CommonDialog1
                .DialogTitle = "Open HEX File"
                .CancelError = False
                'ToDo: set the flags and attributes of the common dialog control
                .Flags = cdlOFNHideReadOnly
                .Filter = "INHEX32 Files (*.HEX)|*.HEX|All Files (*.*)|*.*"
                .ShowOpen
                If Len(.FileName) = 0 Then
                    Exit Sub
                End If
            '    if .Action
                
                PicBootS.InFileName = .FileName
                .FileName = ""
            End With
            
            
        '    ConvertHEX PicBootS.InFileName, "TESTA.HEX"
            
            If PicBootS.DeviceType = 1 Then
                RetStat = ImportP18HEXFile(PicBootS.InFileName)
            Else
                RetStat = ImportP16HEXFile(PicBootS.InFileName)
            End If
            
            
            If RetStat = -2 Then
                StatusBar1.Panels(PANEL_STATUS).Text = STATUS_HEX_FORMAT
            Else
                If RetStat > 0 Then
                    StatusBar1.Panels(PANEL_STATUS).Text = STATUS_HEX_IMPORTED
                Else
                    StatusBar1.Panels(PANEL_STATUS).Text = STATUS_INVALID_HEX
                End If
            End If
            
        Case "Save"
            With CommonDialog1
                .DialogTitle = "Save HEX File"
                .CancelError = False
                'ToDo: set the flags and attributes of the common dialog control
                .Flags = cdlOFNHideReadOnly
                .Filter = "INHEX32 Files (*.HEX)|*.HEX|All Files (*.*)|*.*"
                .ShowSave
                If Len(.FileName) = 0 Then
                    Exit Sub
                End If
                PicBootS.OutFileName = .FileName
                .FileName = ""
            End With
            'ToDo: add code to process the opened file
        
            'crap = ConvertHEX(PicBootS.OutFileName, "D:\Crapp.HEX")
        
            If PicBootS.DeviceType = 1 Then
                ExportP18HEXFile PicBootS.OutFileName
            Else
                ExportP16HEXFile PicBootS.OutFileName
            End If
        
            StatusBar1.Panels(PANEL_STATUS).Text = STATUS_HEX_EXPORTED
        
        
        Case "Clear"
            EraseDataFiles
            
        Case "View"
            ViewDataFiles
            
        Case "Abort"
            AbortFlag = 0
            
        Case "Connect"
            If Toolbar1.Buttons(9).Value = tbrUnpressed Then
                DisconnectDev
            Else
                ConnectToPIC
            End If
            
        Case "Read"
            Fm_Bootload.MousePointer = 13
            SetDisplayMode MODE_WORKING
            
            'read program memory
            If M_MemAccess(1).Checked = True Then
                Select Case ReadRangeDevMem(PicBootS.ProgMemAddrL, PicBootS.ProgMemAddrH, PicBootS.DevBytesPerAddr, 1, PicBootS.ProgMemFile)
               ' Select Case ReadRangeDevMem(0, PicBootS.ProgMemAddrH, PicBootS.DevBytesPerAddr, 1, PicBootS.ProgMemFile)
                'Select Case ReadRangeDevMem(0, 511, 1, PicBootS.ProgMemFile)
                    Case -100
                        StatusBar1.Panels(PANEL_STATUS).Text = STATUS_ABORT
                        SetDisplayMode MODE_CONNECTED_IDLE
                        Fm_Bootload.MousePointer = 0
                        Exit Sub
                    Case 1
                        StatusBar1.Panels(PANEL_STATUS).Text = STATUS_FINISHED
                    Case Else
                        StatusBar1.Panels(PANEL_STATUS).Text = STATUS_READ_FAILURE
                End Select
            End If
                
            'read eedata
            If M_MemAccess(2).Checked = True Then
                Select Case ReadRangeDevMem(PicBootS.EEDataAddrL, PicBootS.EEDataAddrH, 1, 4, PicBootS.EEDataFile)
                    Case -100
                        StatusBar1.Panels(PANEL_STATUS).Text = STATUS_ABORT
                        SetDisplayMode MODE_CONNECTED_IDLE
                        Fm_Bootload.MousePointer = 0
                        Exit Sub
                    Case 1
                        StatusBar1.Panels(PANEL_STATUS).Text = STATUS_FINISHED
                    Case Else
                        StatusBar1.Panels(PANEL_STATUS).Text = STATUS_READ_FAILURE
                End Select
            End If
            
            'read config
            If M_MemAccess(3).Checked = True Then
                Select Case ReadRangeDevMem(PicBootS.ConfigAddrL, PicBootS.ConfigAddrH, 1, 1, PicBootS.ConfigFile)
                    Case -100
                        StatusBar1.Panels(PANEL_STATUS).Text = STATUS_ABORT
                        SetDisplayMode MODE_CONNECTED_IDLE
                        Fm_Bootload.MousePointer = 0
                        Exit Sub
                    Case 1
                        StatusBar1.Panels(PANEL_STATUS).Text = STATUS_FINISHED
                    Case Else
                        StatusBar1.Panels(PANEL_STATUS).Text = STATUS_READ_FAILURE
                End Select
            End If
            
            'read userID
            If M_MemAccess(4).Checked = True Then
                Select Case ReadRangeDevMem(PicBootS.UserIDAddrL, PicBootS.UserIDAddrH, 1, 1, PicBootS.UserIDFile)
                    Case -100
                        StatusBar1.Panels(PANEL_STATUS).Text = STATUS_ABORT
                        SetDisplayMode MODE_CONNECTED_IDLE
                        Fm_Bootload.MousePointer = 0
                        Exit Sub
                    Case 1
                        StatusBar1.Panels(PANEL_STATUS).Text = STATUS_FINISHED
                    Case Else
                        StatusBar1.Panels(PANEL_STATUS).Text = STATUS_READ_FAILURE
                End Select
            End If
                 
            SetDisplayMode MODE_CONNECTED_IDLE
            Fm_Bootload.MousePointer = 0
        
            
        Case "Write"
            Fm_Bootload.MousePointer = 13
            SetDisplayMode MODE_WORKING
            
            If M_MemAccess(1).Checked = True Then
                Select Case WriteRangeDevMem(PicBootS.DeviceWrtBlock, PicBootS.DevBytesPerAddr, 2, PicBootS.ProgMemFile)
                    Case -100
                        StatusBar1.Panels(PANEL_STATUS).Text = STATUS_ABORT
                        SetDisplayMode MODE_CONNECTED_IDLE
                        Fm_Bootload.MousePointer = 0
                        Exit Sub
                    Case -101
                        StatusBar1.Panels(PANEL_STATUS).Text = STATUS_VERIFY_ERROR
                        SetDisplayMode MODE_CONNECTED_IDLE
                        Fm_Bootload.MousePointer = 0
                        test = Shell(PicBootS.EditorFile & " " & VB.App.Path & "\" & PicBootS.ErrorLogFile, vbNormalFocus)
                        Exit Sub
                    Case 1
                        StatusBar1.Panels(PANEL_STATUS).Text = STATUS_FINISHED
                    Case Else
                        StatusBar1.Panels(PANEL_STATUS).Text = STATUS_WRITE_FAILURE
                End Select
            End If
            
            If M_MemAccess(2).Checked = True Then
                Select Case WriteRangeDevMem(1, 1, 5, PicBootS.EEDataFile)
                    Case -100
                        StatusBar1.Panels(PANEL_STATUS).Text = STATUS_ABORT
                        SetDisplayMode MODE_CONNECTED_IDLE
                        Fm_Bootload.MousePointer = 0
                        Exit Sub
                    Case -101
                        StatusBar1.Panels(PANEL_STATUS).Text = STATUS_VERIFY_ERROR
                        SetDisplayMode MODE_CONNECTED_IDLE
                        Fm_Bootload.MousePointer = 0
                        test = Shell(PicBootS.EditorFile & " " & VB.App.Path & "\" & PicBootS.ErrorLogFile, vbNormalFocus)
                        Exit Sub
                    Case 1
                        StatusBar1.Panels(PANEL_STATUS).Text = STATUS_FINISHED
                    Case Else
                        StatusBar1.Panels(PANEL_STATUS).Text = STATUS_WRITE_FAILURE
                End Select
            End If
            
            If M_MemAccess(4).Checked = True Then
                Select Case WriteRangeDevMem(PicBootS.DeviceWrtBlock, 1, 2, PicBootS.UserIDFile)
                    Case -100
                        StatusBar1.Panels(PANEL_STATUS).Text = STATUS_ABORT
                        SetDisplayMode MODE_CONNECTED_IDLE
                        Fm_Bootload.MousePointer = 0
                        Exit Sub
                    Case -101
                        StatusBar1.Panels(PANEL_STATUS).Text = STATUS_VERIFY_ERROR
                        SetDisplayMode MODE_CONNECTED_IDLE
                        Fm_Bootload.MousePointer = 0
                        test = Shell(PicBootS.EditorFile & " " & VB.App.Path & "\" & PicBootS.ErrorLogFile, vbNormalFocus)
                        Exit Sub
                    Case 1
                        StatusBar1.Panels(PANEL_STATUS).Text = STATUS_FINISHED
                    Case Else
                        StatusBar1.Panels(PANEL_STATUS).Text = STATUS_WRITE_FAILURE
                End Select
            End If
                
            SetDisplayMode MODE_CONNECTED_IDLE
            Fm_Bootload.MousePointer = 0
        
            
        Case "Erase"
            Fm_Bootload.MousePointer = 13
            SetDisplayMode MODE_WORKING
            
            If M_MemAccess(1).Checked = True Then
                Select Case EraseRangeDevMem(PicBootS.ProgMemAddrL, PicBootS.ProgMemAddrH)
                Case -100
                        StatusBar1.Panels(PANEL_STATUS).Text = STATUS_ABORT
                        SetDisplayMode MODE_CONNECTED_IDLE
                        Fm_Bootload.MousePointer = 0
                        Exit Sub
                    Case 1
                        StatusBar1.Panels(PANEL_STATUS).Text = STATUS_FINISHED
                    Case Else
                        StatusBar1.Panels(PANEL_STATUS).Text = STATUS_WRITE_FAILURE
                End Select
            End If
            
            If M_MemAccess(4).Checked = True Then
                Select Case EraseRangeDevMem(PicBootS.UserIDAddrL, PicBootS.UserIDAddrH)
                Case -100
                        StatusBar1.Panels(PANEL_STATUS).Text = STATUS_ABORT
                        SetDisplayMode MODE_CONNECTED_IDLE
                        Fm_Bootload.MousePointer = 0
                        Exit Sub
                    Case 1
                        StatusBar1.Panels(PANEL_STATUS).Text = STATUS_FINISHED
                    Case Else
                        StatusBar1.Panels(PANEL_STATUS).Text = STATUS_WRITE_FAILURE
                End Select
            End If
                   
            SetDisplayMode MODE_CONNECTED_IDLE
            Fm_Bootload.MousePointer = 0
                
        Case "Run"
            
            MyButtons = MsgBox("Disabling the bootloader will lock out boot mode. Be sure to have re-entry" & vbCrLf & "code within your firmware to use the bootloader in the future." & vbCrLf & vbCrLf & "Do you want to continue?", vbYesNo, "Disable Bootloader...")
            If MyButtons = vbNo Then   ' User chose Yes.
                Exit Sub   ' Perform some action.
            End If
            
            GotoRunMode
            DisconnectDev
            StatusBar1.Panels(PANEL_STATUS).Text = STATUS_RUNMODE_SET
            
    End Select
End Sub




Private Sub Toolbar1_MouseUp(Button As Integer, Shift As Integer, x As Single, y As Single)
    If Button = 2 Then
        MsConFlag = 2
        PopupMenu M_Program, vbPopupMenuRightButton
    End If
End Sub

'******************************************************************************





















Private Sub DisconnectDev()

    AbortFlag = 0
    DoEvents

    'close the port
    If PicBootS.PortHandle > 0 Then
        ClosePIC (PicBootS.PortHandle)
        PicBootS.PortHandle = -1
    End If
    
    Toolbar1.Buttons(9).Value = tbrUnpressed
    StatusBar1.Panels(PANEL_STATUS).Text = STATUS_NOT_CON
    StatusBar1.Panels(PANEL_FWVER).Text = " "
    StatusBar1.Panels(PANEL_DEVICE).Text = " "

    SetDisplayMode (MODE_NOT_CONNECTED)

End Sub






Private Sub SetDisplayMode(DspMode As Integer)
    
    Toolbar1.Buttons(1).Enabled = False
    Toolbar1.Buttons(2).Enabled = False
    Toolbar1.Buttons(4).Enabled = True
    Toolbar1.Buttons(5).Enabled = True
    Toolbar1.Buttons(7).Enabled = False
    Toolbar1.Buttons(9).Enabled = True
    Toolbar1.Buttons(10).Enabled = False
    Toolbar1.Buttons(11).Enabled = False
    Toolbar1.Buttons(12).Enabled = False
    Toolbar1.Buttons(14).Enabled = False
    
    M_FPPort(1).Enabled = True
    M_FPPort(2).Enabled = True
    M_FPPort(3).Enabled = True
    M_FPPort(4).Enabled = True
    
    M_FPBaud(1).Enabled = True
    M_FPBaud(2).Enabled = True
    M_FPBaud(3).Enabled = True
    M_FPBaud(4).Enabled = True
    M_FPBaud(5).Enabled = True
    
    M_MemAccess(1).Enabled = True
    M_MemAccess(2).Enabled = True
    M_MemAccess(3).Enabled = True
    M_MemAccess(4).Enabled = True
    
    M_PSendCfg.Visible = False
    space101.Visible = False
        
    
    
    
    If (DspMode And MODE_CONNECTED_IDLE) Then
        Toolbar1.Buttons(1).Enabled = True
        Toolbar1.Buttons(2).Enabled = True
        Toolbar1.Buttons(10).Enabled = True
        Toolbar1.Buttons(11).Enabled = True
        Toolbar1.Buttons(12).Enabled = True
        Toolbar1.Buttons(14).Enabled = True
        M_PSendCfg.Visible = True
        space101.Visible = True
        M_Program.Enabled = True
    End If
    
    If (DspMode And MODE_WORKING) Then
        M_PSendCfg.Visible = False
        Toolbar1.Buttons(7).Enabled = True
        Toolbar1.Buttons(1).Enabled = False
        Toolbar1.Buttons(2).Enabled = False
        Toolbar1.Buttons(4).Enabled = False
        Toolbar1.Buttons(5).Enabled = False
        M_MemAccess(1).Enabled = False
        M_MemAccess(2).Enabled = False
        M_MemAccess(3).Enabled = False
        M_MemAccess(4).Enabled = False
        M_FPBaud(1).Enabled = False
        M_FPBaud(2).Enabled = False
        M_FPBaud(3).Enabled = False
        M_FPBaud(4).Enabled = False
        M_FPBaud(5).Enabled = False
        M_FPPort(1).Enabled = False
        M_FPPort(2).Enabled = False
        M_FPPort(3).Enabled = False
        M_FPPort(4).Enabled = False
    End If
    
    
    If PicBootS.DeviceType = 0 Then
        M_MemAccess(3).Visible = False
        M_MemAccess(4).Visible = False
        Toolbar1.Buttons(12).Enabled = False
        M_MemAccess(3).Checked = False
        M_MemAccess(4).Checked = False
        M_PSendCfg.Visible = False
        space101.Visible = False
    Else
        M_MemAccess(3).Visible = True
        M_MemAccess(4).Visible = True
    End If
    
End Sub



