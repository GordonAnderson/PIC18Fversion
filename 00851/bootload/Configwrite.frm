VERSION 5.00
Begin VB.Form D_WriteFuses 
   BorderStyle     =   4  'Fixed ToolWindow
   Caption         =   "Send Config Settings"
   ClientHeight    =   795
   ClientLeft      =   2760
   ClientTop       =   3705
   ClientWidth     =   3255
   LinkTopic       =   "Form1"
   MaxButton       =   0   'False
   MinButton       =   0   'False
   ScaleHeight     =   795
   ScaleWidth      =   3255
   ShowInTaskbar   =   0   'False
   Begin VB.TextBox Text1 
      Alignment       =   2  'Center
      Height          =   285
      Left            =   1560
      TabIndex        =   5
      Text            =   "FF"
      Top             =   360
      Width           =   495
   End
   Begin VB.ComboBox C_ConfigBytes 
      Height          =   315
      ItemData        =   "Configwrite.frx":0000
      Left            =   120
      List            =   "Configwrite.frx":0002
      Style           =   2  'Dropdown List
      TabIndex        =   4
      Top             =   360
      Width           =   1335
   End
   Begin VB.CommandButton CancelButton 
      Caption         =   "Close"
      Height          =   255
      Left            =   2280
      TabIndex        =   1
      Top             =   480
      Width           =   855
   End
   Begin VB.CommandButton SendButton 
      Caption         =   "Send"
      Height          =   255
      Left            =   2280
      TabIndex        =   0
      Top             =   120
      Width           =   855
   End
   Begin VB.Label Label2 
      Alignment       =   2  'Center
      Caption         =   "Data"
      Height          =   255
      Left            =   1560
      TabIndex        =   3
      Top             =   120
      Width           =   495
   End
   Begin VB.Label Label1 
      Alignment       =   2  'Center
      Caption         =   "Address"
      Height          =   255
      Left            =   120
      TabIndex        =   2
      Top             =   120
      Width           =   1335
   End
End
Attribute VB_Name = "D_WriteFuses"
Attribute VB_GlobalNameSpace = False
Attribute VB_Creatable = False
Attribute VB_PredeclaredId = True
Attribute VB_Exposed = False

Option Explicit







Private Sub C_ConfigBytes_Click()
    Dim RetStat As Long

    RetStat = ReadConfig(C_ConfigBytes.ItemData(C_ConfigBytes.ListIndex))
    If RetStat < 0 Then
        Exit Sub
    End If
     
    Text1.Text = Dec2Hex(RetStat, 2)
     
End Sub

Private Sub CancelButton_Click()
    Me.Hide
End Sub

Private Sub Form_QueryUnload(Cancel As Integer, UnloadMode As Integer)
    If UnloadMode = vbFormControlMenu Then
        Cancel = 1
        Me.Hide
    End If
End Sub



Private Sub SendButton_Click()
    Dim RetStat As Long

    RetStat = WriteConfig(C_ConfigBytes.ItemData(C_ConfigBytes.ListIndex), Val("&H" & Text1.Text))
    If RetStat < 0 Then
        Exit Sub
    End If
     
End Sub

Private Sub Text1_KeyPress(KeyAscii As Integer)
    Dim TempText As String
    Dim OldSel As Long
    Dim CodeStat As Boolean
    
    'Remember the last value
    TempText = Text1.Text
    OldSel = Text1.SelStart
    
    'Ignore invalid characters
    CodeStat = (KeyAscii >= Asc("0") And KeyAscii <= Asc("9"))
    CodeStat = CodeStat Or (KeyAscii >= Asc("A") And KeyAscii <= Asc("F"))
    CodeStat = CodeStat Or (KeyAscii >= Asc("a") And KeyAscii <= Asc("f"))
    If Not CodeStat Then
        KeyAscii = 0
        Exit Sub
    End If

    'Prevent more than two
    If Text1.SelLength = 0 Then
        If Len(Text1.Text) > 1 Then
            Text1.Text = Mid(Text1.Text, 2, 1)
            Text1.SelStart = Len(Text1.Text)
        End If
    End If
End Sub





Private Sub Text1_DblClick()
    Text1.SelStart = 0
    Text1.SelLength = Len(Text1.Text)
End Sub

