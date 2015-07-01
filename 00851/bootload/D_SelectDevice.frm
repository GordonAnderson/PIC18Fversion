VERSION 5.00
Begin VB.Form D_SelectDevice 
   BorderStyle     =   4  'Fixed ToolWindow
   Caption         =   "Select Microchip PIC Microcontroller"
   ClientHeight    =   810
   ClientLeft      =   45
   ClientTop       =   285
   ClientWidth     =   3330
   LinkTopic       =   "Form1"
   MaxButton       =   0   'False
   MinButton       =   0   'False
   ScaleHeight     =   810
   ScaleWidth      =   3330
   ShowInTaskbar   =   0   'False
   StartUpPosition =   3  'Windows Default
   Begin VB.PictureBox picIcon 
      AutoSize        =   -1  'True
      BorderStyle     =   0  'None
      ClipControls    =   0   'False
      Height          =   480
      Left            =   120
      Picture         =   "D_SelectDevice.frx":0000
      ScaleHeight     =   337.12
      ScaleMode       =   0  'User
      ScaleWidth      =   337.12
      TabIndex        =   3
      Top             =   120
      Width           =   480
   End
   Begin VB.CommandButton C_Cancel 
      Caption         =   "Cancel"
      Height          =   255
      Left            =   2160
      TabIndex        =   2
      Top             =   480
      Width           =   1095
   End
   Begin VB.CommandButton C_Select 
      Caption         =   "Select"
      Height          =   255
      Left            =   840
      TabIndex        =   1
      Top             =   480
      Width           =   1095
   End
   Begin VB.ComboBox Cm_DevList 
      Height          =   315
      ItemData        =   "D_SelectDevice.frx":030A
      Left            =   840
      List            =   "D_SelectDevice.frx":0320
      Style           =   2  'Dropdown List
      TabIndex        =   0
      Top             =   120
      Width           =   2415
   End
End
Attribute VB_Name = "D_SelectDevice"
Attribute VB_GlobalNameSpace = False
Attribute VB_Creatable = False
Attribute VB_PredeclaredId = True
Attribute VB_Exposed = False
Private Sub C_Cancel_Click()
    PicBootS.DeviceMode = 0
    Unload Me
End Sub

Private Sub C_Select_Click()
    If Cm_DevList.ListIndex = 0 Then
        PicBootS.DeviceMode = 0
    Else
        PicBootS.DeviceMode = 1             'Select manual mode
        PicBootS.DeviceName = Cm_DevList.List(Cm_DevList.ListIndex)
        PicBootS.DeviceCode = Cm_DevList.ItemData(Cm_DevList.ListIndex)
    End If
    
    Unload Me
End Sub

Private Sub Form_Load()
    DoEvents

    'get the current list of devices
    Cm_DevList.Clear
    Cm_DevList.AddItem ("Auto Detect Device")
    For i = 1 To 2176
        TempReturn = GetSetting("DEVICELIST", CStr(i))
        If StrComp(TempReturn, "") <> 0 Then
            Cm_DevList.AddItem TempReturn
            Cm_DevList.ItemData(MyCount) = i
            MyCount = MyCount + 1
        End If
    Next i
End Sub
